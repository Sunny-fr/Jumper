#Jumper#
*Jumper* is a pathfinding library designed for uniform cost 2D grid-based games.<br/>
It is written in pure Lua and features [Jump Point Search][] algorithm.

##Files##
* The folder [Lib][] contains the entire Library.
* The file [Jumper_(Demo).love][] is a visual interactive demo.
* The file [Jumper_(Tests).love][] is also a demo which performs a set of benchmark tests.
  
##Usage##
Place the folder 'Lib' inside your projet. Use *require* command to load.

    local Jumper = require('Lib')
    
You must now setup a 2D matrix of integers representing your world. Values stored in this matrix
should represent whether or not a cell on the matrix is walkable or not. If you choose for instance
*0* for walkable tiles, any other values will be considered as non walkable.

    local map = {
          {0,0,0},
          {0,2,0},
          {0,0,1},
          }

To initialize the pathfinder, you will have to pass four values.

    local walkable = 0
    local allowDiagonal = true
    local pather = Jumper(map,walkable,allowDiagonal,Jumper.HEURISTIC.MANHATTAN)
  
Only the first one is required, the three others are optional.
* *map* refers to the matrix representing the 2D world.
* *walkable* refers to the value representing walkable tiles. Will be considered as *0* if not given.
* *allowDiagonal* is a boolean saying whether or not diagonal moves are allowed. Will be considered as *true* if not given.
* The fourth argument is a constant representing the heuristic to be used for path computation. The possible values are *Jumper.HEURISTIC.MANHATTAN*, *Jumper.HEURISTIC.EUCLIDIAN*, *Jumper.HEURISTIC.DIAGONAL*, *Jumper.HEURISTIC.CHEBYSHEV* (same as *Jumper.HEURISTIC.DIAGONAL*). When not given, the pathfinder will use *Jumper.HEURISTIC.MANHATTAN* by default.

##API##
Once loaded and initialized properly, you can now used one of the following methods provided:
	
	pather:setHeuristic(NAME) : Will change the heuristic to be used. NAME must be passed as a string. Possible values are *MANHATTAN*,*EUCLIDIAN*,*DIAGONAL*,*CHEBYSHEV* (case-sensitive!).
	pather:getHeuristic() : Will return a reference to the internal heuristic function used.	
	pather:setDiagonalMoves(bool): Argument must be a boolean. True will authorize diagonal moves, False will authorize only straight-move (actually not working, see Know Issues)
	pather:getDiagonalMoves() : Returns a boolean saying whether or not diagonal moves are allowed.
	pather:getGrid() : Returns a reference to the internal grid used by the pathfinder. This grid is *not* the map matrix given on initialization.
	pather:searchPath(startX,startY,endX,endY) : Main function, returns a path as a table representing the route from cell (startX,startY) to cell (startX,startY), or *nil* if there is no valid path. Returns a second value representing total cost of the move.

Using *getGrid()* returns a reference to the internal grid use by the pathfinder. On this reference, you can use one of the following methods.
	
	grid:getNodeAt(x,y) : Returns a reference to the node (X,Y) on the grid
	grid:isWalkableAt(x,y) : Returns a boolean saing whether or not the node (X,Y) exists and is walkable
	grid:setWalkableAt(x,y,boolean) : Sets the node (X,Y) walkable or not 
	grid:getNeighbours(node,allowDiagonal) : Returns an array list of nodes neighbouring location (X,Y), skippking or not diagonal nodes according to the argument allowDiagonal
	grid:reset() : Resets the grid. Call internally before each path computation, should not be used explicitely.
	
##Handling paths##
Using *searchPath()* will return a table representing a path from one node to another.<br/>
The path is stored in a table using the form given below:

	path = {
				{x = 1,y = 1},
				{x = 2,y = 2},
				{x = 3,y = 3},
				...
				{x = n,y = n},
			}
You will have to make your own use of this to route your entities on the 2D map along this path.
Note that the path could contains some *holes* because of the algorithm used.<br/>
This should not cause a serious issue as the move from one step to another along the path is always straight.

##Known Issues##
* *Paths Holes*: paths returned may contains holes. This will be fiexed in a next version by implementing an internal path smoother.
* *Diagonal moves*: as there is some strange behaviour when diagonal moves are disabled, I made them allowed by default. Even using *setDiagonalMoves(false)* will not disable them. Will be fixed in a next version.

##Participating Libraries##
* [Lua Class System][]
* [Binary heaps][]

##About Visual Demo##
[Jumper (Demo).love][] is a visual demo of for the current library.<br/>
You can run it on Windows, MAC & Linux using [Löve][] Framework<br/>
Command Keys:
* *Left Mouse* : Place the start node.
* *Right Mouse* : Place the end node.
* *Left Mouse Down + o (Keyboard)* : Sets unwalkable nodes.
* *Left Mouse Down + w (Keyboard)* : Sets walkable nodes.
* *Space (Keyboard)* : Computes the path.

##About Tests##
[Jumper_(Tests).love][] is a demo featuring bencharking tests of the current library.<br/>
You can run it on Windows, MAC & Linux using [Löve][] Framework.<br/>
Remote control is achieved through a console window.<br/>
Maps included for benchmarking come from [Dragon Age : Origins][] and were taken on [Moving AI][].

While running Tests, you will be asked for outputting results.<br/>
You will find these outputs on different locations according to your operating system
* Windows XP : *C:\Documents and Settings\Your_Username\Application Data\Love\Jumper\* or *%appdata%\Love\Jumper\*
* Windows Vista and 7 : *C:\Users\Your_Username\AppData\Roaming\LOVE\Jumper\* or *%appdata%\Love\Jumper\*
* Linux : *$XDG_DATA_HOME/love/ or ~/.local/share/love/Jumper/*
* Mac : */Users/Your_Username/Library/Application Support/LOVE/*


##Credits##
* [Daniel Harabor][], [Alban Grastien][] : for [technical papers][].<br/>
* [XueXiao Xu][], [Nathan Witmer][]: for their amazing [port][] in Javascript<br/>

##License##
This work is under [MIT-LICENSE][]<br/>
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

[Jump Point Search]: http://harablog.wordpress.com/2011/09/07/jump-point-search/
[Lua Class System]: https://github.com/Yonaba/Lua-Class-System
[Binary heaps]: https://github.com/Yonaba/Binary-Heaps
[Löve]: https://love2d.org
[Dragon Age : Origins]: http://dragonage.bioware.com
[Moving AI]: http://movingai.com
[Nathan Witmer]: https://github.com/aniero
[XueXiao Xu]: https://github.com/qiao
[port]: https://github.com/qiao/PathFinding.js
[Alban Grastien]: http://www.grastien.net/ban/
[Daniel Harabor]: http://users.cecs.anu.edu.au/~dharabor/home.html
[technical papers]: http://users.cecs.anu.edu.au/~dharabor/data/papers/harabor-grastien-aaai11.pdf
[MIT-LICENSE]: http://www.opensource.org/licenses/mit-license.php
[Lib]: https://github.com/Yonaba/Jumper/Lib
[Jumper_(Demo).love]: https://github.com/Yonaba/Jumper/Lib
[Jumper_(Tests).love]: https://github.com/Yonaba/Jumper/Lib