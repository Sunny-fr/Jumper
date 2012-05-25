--[[
Copyright (c) 2012 Roland Yonaba

Permission is hereby granted, free of charge, to any person obtaining a
copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be included
in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
--]]

module(...,package.seeall)

local insert = table.insert
local ipairs = ipairs
local max, abs = math.max, math.abs
local assert = assert

-- Loads dependancies
local Heuristic = require (_PACKAGE .. '.core.heuristics')
local Grid = require (_PACKAGE ..'.core.grid')
local Heap = require (_PACKAGE .. '.core.third-party.binary_heap')
local LCS = require (_PACKAGE .. '.core.third-party.LCS')

_M.Heuristic = nil
_M.Grid = nil
_M.Heap = nil
_M.LCS = nil

-- Local helpers, to keep these routines private

-- Rebuilds a path when found
local function traceBackPath(self)
	local sx,sy = self.startNode.x,self.startNode.y
	local x,y
	local grid = self.grid
	local path = {{x = self.endNode.x, y = self.endNode.y}}
	local node

	while true do
		x,y = path[1].x,path[1].y
		node = grid:getNodeAt(x,y)
		if node.parent then
			x,y = node.parent.x,node.parent.y
			insert(path,1,{x = x,y = y})
		else
			return path
		end
	end
	return nil
end

-- Neighbours pruning rules
local function findNeighbours(self,node)
	local grid = self.grid
	local parent = node.parent
	local neighbours = {}
	local _neighbours
	local x,y = node.x,node.y
	local px,py,dx,dy

	if parent then
	-- Node have a parent, we will prune some neighbours
	px,py = parent.x,parent.y
	dx = (x-px)/max(abs(x-px),1)
	dy = (y-py)/max(abs(y-py),1)

		if dx~=0 and dy~=0 then -- Diagonal move
			if grid:isWalkableAt(x,y+dy) then
				insert(neighbours,{x = x, y = y+dy})
			end
			if grid:isWalkableAt(x+dx,y) then
				insert(neighbours,{x = x+dx, y = y})
			end
			if grid:isWalkableAt(x,y+dy) or grid:isWalkableAt(x+dx,y) then
				insert(neighbours,{x = x+dx, y = y+dy})
			end
			if (not grid:isWalkableAt(x-dx,y)) and grid:isWalkableAt(x,y+dy) then
				insert(neighbours,{x = x-dx, y = y+dy})
			end
			if (not grid:isWalkableAt(x,y-dy)) and grid:isWalkableAt(x+dx,y) then
				insert(neighbours,{x = x+dx, y = y-dy})
			end
		else -- Move along Y
			if dx==0 then
				if grid:isWalkableAt(x,y+dy) then
					if grid:isWalkableAt(x,y+dy) then
					insert(neighbours,{x = x, y = y +dy})
					end
					if (not grid:isWalkableAt(x+1,y)) then
					insert(neighbours,{x = x+1, y = y+dy})
					end
					if (not grid:isWalkableAt(x-1,y)) then
					insert(neighbours,{x = x-1, y = y+dy})
					end
				end
			else -- Move along X
				if grid:isWalkableAt(x+dx,y) then
					if grid:isWalkableAt(x+dx,y) then
					insert(neighbours,{x = x+dx, y = y})
					end
					if (not grid:isWalkableAt(x,y+1)) then
					insert(neighbours,{x = x+dx, y = y+1})
					end
					if (not grid:isWalkableAt(x,y-1)) then
					insert(neighbours,{x = x+dx, y = y-1})
					end
				end
			end
		end

	else
	-- Node do not have parent, we return all neighbouring nodes
		_neighbours = grid:getNeighbours(node,self.allowDiagonal)
		for i,_neighbour in ipairs(_neighbours) do
			insert(neighbours,_neighbour)
		end
	end
	return neighbours
end

-- Jump point search
local function jump(self,x,y,px,py)
	local grid = self.grid
	local dx, dy = x - px,y - py
	local jx,jy

	if not grid:isWalkableAt(x,y) then
		return nil
	else
		if grid:getNodeAt(x,y) == self.endNode then
		return {x = x, y = y}
		end
	end

	if dx~=0 and dy~=0 then -- Diagonal move
		if (grid:isWalkableAt(x-dx,y+dy) and (not grid:isWalkableAt(x-dx,y))) or
		(grid:isWalkableAt(x+dx,y-dy) and (not grid:isWalkableAt(x,y-dy))) then
		return {x = x, y = y}
		end
	else
		if dx~=0 then -- Moving along x
			if (grid:isWalkableAt(x+dx,y+1) and (not grid:isWalkableAt(x,y+1))) or
			   (grid:isWalkableAt(x+dx,y-1) and (not grid:isWalkableAt(x,y-1))) then
				return {x = x, y = y}
			end
		else -- Moving along y
			if (grid:isWalkableAt(x+1,y+dy) and (not grid:isWalkableAt(x+1,y))) or
			   (grid:isWalkableAt(x-1,y+dy) and (not grid:isWalkableAt(x-1,y))) then
				return {x = x, y = y}
			end
		end
	end

	-- Diagonal move made, recursive search for jump point
	if dx~=0 and dy~=0 then
		jx = jump(self,x+dx,y,x,y)
		jy = jump(self,x,y+dy,x,y)
		if jx or jy then
			return {x = x, y = y}
		end
	end

	-- recursive search for jump point diagonally
	if grid:isWalkableAt(x+dx,y) or grid:isWalkableAt(x,y+dy) then
		return jump(self,x+dx,y+dy,x,y)
	else
		return nil
	end
end

-- Looks for successors of a given node
local function identifySuccessors(self,node)
	local grid = self.grid
	local heuristic = self.heuristic
	local openList = self.openList
	local endX,endY = self.endNode.x,self.endNode.y

	local x,y = node.x,node.y
	local jumpPoint,jx,jy,jumpNode
	local neighbours = findNeighbours(self,node)
		for i,neighbour in ipairs(neighbours) do
			jumpPoint = jump(self,neighbour.x,neighbour.y,x,y)
			if jumpPoint then
			jx,jy = jumpPoint.x,jumpPoint.y
			jumpNode = grid:getNodeAt(jx,jy)
				if not jumpNode.closed then
				dist = Heuristic.euclidian(jx-x,jy-y)
				ng = node.g + dist
					if not jumpNode.opened or ng < jumpNode.g then
					jumpNode.g = ng
					jumpNode.h = jumpNode.h or (heuristic(jx-endX,jy-endY))
					jumpNode.f = jumpNode.g+jumpNode.h
					jumpNode.parent = node
						if not jumpNode.opened then
							openList:insert(jumpNode)
							jumpNode.opened = true
						else
							openList:heap()
						end
					end
				end
			end
		end
end


-- Jump Point Searcher Class
local JPS = LCS.class {
				heuristic = nil, -- heuristic used
				startNode = nil, -- startNode
				endNode = nil, -- endNode
				grid = nil, -- the grid
				allowDiagonal = true, -- By default, allows diagonal moves
				HEURISTIC = { 
								MANHATTAN = Heuristic.manhattan,
								DIAGONAL = Heuristic.diagonal,
								EUCLIDIAN = Heuristic.euclidian,
								CHEBYSHEV = Heuristic.diagonal,
							},
}

-- Custom initializer (walkable, allowDiagonal,heuristic are both optional)
function JPS:init(map,walkable,allowDiagonal,heuristic)
	self.walkable = walkable or 0
	self.grid = Grid(map,self.walkable)
	self.allowDiagonal = true
	self.heuristic = heuristic or Heuristic.manhattan
end

-- Changes the heuristic
function JPS:setHeuristic(distance)
	assert(JPS.HEURISTIC[distance],'Not a valid heuristic!')
	self.heuristic = JPS.HEURISTIC[distance]
end

-- Gets a pointer to the heuristic currently used
function JPS:getHeuristic()
	return self.heuristic
end

-- Enables or disables diagonal moves (DISABLED)
function JPS:setDiagonalMoves(bool)
	assert(type(bool) == 'boolean','Argument must be a boolean')
	self.allowDiagonal = true
end

-- Checks whether diagonal moves are enabled or not
function JPS:getDiagonalMoves()
	return self.allowDiagonal
end

-- Access to the internal grid
function JPS:getGrid()
	return self.grid
end

-- Search for a valid path from Node(sx,sy) to Node(ex,ey)
function JPS:searchPath(sx,sy,ex,ey)
	local grid = self.grid
	self.openList = Heap()
	self.startNode = grid:getNodeAt(sx,sy)
	self.endNode = grid:getNodeAt(ex,ey)
	local openList = self.openList
	local startNode, endNode = self.startNode,self.endNode
	local node

	grid:reset()

	startNode.g, startNode.f = 0,0
	openList:insert(startNode)
	startNode.opened = true

	while not openList:empty() do
		node = openList:pop()
		node.closed = true
			if node == endNode then
				return traceBackPath(self),endNode.f
			end
		identifySuccessors(self,node)
	end
	return nil
end

return JPS

