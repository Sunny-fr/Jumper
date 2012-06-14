#Jumper#

*Jumper* is a pathfinding library designed for uniform-cost 2D grid-based games.<br/>
It is written in pure Lua and features [Jump Point Search][] algorithm.<br/>
*Jumper* is (very) fast, lightweight and generates almost no memory overhead. As such, it might be an interesting option
for pathfinding computation on 2D maps.
Plus, *Jumper* offers a clean API which makes it very friendly and easy-to-use.

##Files##

* [Jumper][] contains the library itself.
* [Jumper_(Demo).love][] | [Jumper_(Demo).rar][] is a visual interactive demo.
* [Jumper_(Tests).love][] | [Jumper_(Tests).rar][] is another demo which performs a set of benchmark tests.
  
##Usage##

Place the folder 'Jumper' inside your projet. Use *require* to load it.

    local Jumper = require('Jumper.init')

*Note : If your LUA path includes search for "init.lua" on folder opening, as [Löve][] Framework do, you can simply use: require('Jumper')*

Now you must now setup a 2D matrix of integers or strings representing your world. Values stored in this matrix
should represent whether or not a cell on the matrix is walkable or not. If you choose for instance
*0* for walkable tiles, any other values will be considered as non walkable.

    local map = {
          {0,0,0},
          {0,2,0},
          {0,0,1},
          }

To initialize the pathfinder, you will have to pass four values. Only the first one is required, others are optional.

    local walkable = 0
    local allowDiagonal = true
    local pather = Jumper(map,walkable,allowDiagonal,heuristic
  
Only the first one is required, the three others are optional.
* *map* refers to the matrix representing the 2D world.
* *walkable* refers to the value representing walkable tiles. Will be considered as *0* if not given.
* *allowDiagonal* is a boolean saying whether or not diagonal moves are allowed. Will be considered as *true* if not given.
* *heuristic* is a constant representing the heuristic function to be used for path computation).

##Heuristics##

*Jumper* features 4 types of heuristics.
* MANHATTAN Distance
* EUCLIDIAN Distance
* DIAGONAL Distance
* CHEBYSHEV Distance , which is a simple alias to DIAGONAL Distance.

Each of these heuristics are packed inside Jumper's core. By default, when initializing  *Jumper*, MANHATTAN Distance is used if 
no heuristic was specified. If you need to use another Heuristic, you will need to require *Heuristics* first.

    local walkable = 0
    local allowDiagonal = true
    local Heuristics. = require 'Jumper.core.heuristics'
    local Jumper = require('Jumper.init')
    local pather = Jumper(map,walkable,allowDiagonal,Heuristics.EUCLIDIAN)

You can aso use *setHeuristic(Name)*. This way, requiring *Heuristics* is no more relevant.
Heuristic name must be passed as a string in this case.

    local walkable = 0
    local allowDiagonal = true
    local Jumper = require('Jumper.init')
    local pather = Jumper(map,walkable,allowDiagonal)
    pather:setheuristic('EUCLIDIAN')

##API##

Once loaded and initialized properly, you can now used one of the following methods listed below.
Assuming *pather* represents an instance of *Jumper* class.
	
	pather:setHeuristic(NAME) : Will change the heuristic to be used. NAME must be passed as a string. Possible values are *MANHATTAN*,*EUCLIDIAN*,*DIAGONAL*,*CHEBYSHEV* (case-sensitive!).
	pather:getHeuristic() : Will return a reference to the internal heuristic function used.	
	pather:setDiagonalMoves(bool): Argument must be a boolean. True will authorize diagonal moves, False will authorize only straight-moves.
	pather:getDiagonalMoves() : Returns a boolean saying whether or not diagonal moves are allowed.
	pather:getGrid() : Returns a reference to the internal grid used by the pathfinder. This grid is *not* the map matrix given on initialization, but a virtual representation used internally.
	pather:searchPath(startX,startY,endX,endY) : Main function, returns a path from [startX,startY] to [endX,endY] as an array of tables ({x = ...,y = ...})or *nil* if there is no valid path. Returns a second value representing total cost of the move if a path was found.
	pather:smooth(path) : Polishes a path
	
Using *getGrid()* returns a reference to the internal grid used by the pathfinder. On this reference, you can use one of the following methods.
Assuming *grid*	holds the returned value from *pather:getGrid()*

	grid:getNodeAt(x,y) : Returns a reference to the node (X,Y) on the grid
	grid:isWalkableAt(x,y) : Returns a boolean saying whether or not the node (X,Y) exists and is walkable
	grid:setWalkableAt(x,y,boolean) : Sets the node (X,Y) walkable or not depending on the boolean given. *True* makes the node walkable, while *false* makes it unwalkable.
	grid:getNeighbours(node,allowDiagonal) : Returns an array list of nodes neighbouring location (X,Y), skippking or not adjacent nodes regards to the boolean allowDiagonal.
	grid:reset() : Resets the grid. Called internally before each path computation, should not be used explicitely.
	
##Handling paths##

###Using native *searchPath()* method###

Using *searchPath()* will return a table representing a path from one node to another.<br/>
The path is stored in a table using the form given below:

    path = {
              {x = 1,y = 1},
              {x = 2,y = 2},
              {x = 3,y = 3},
              ...
              {x = n,y = n},
            }
			
You will have to make your own use of this to route your entities on the 2D map along this path.<br/>
Note that the path could contains some *holes* because of the algorithm used.<br/>
However, this should not cause a serious issue as the move from one step to another along the path is always straight.

###Using path smoother###

*Jumper* provides a path smoother that can be used to polish a path early computed, filling the holes it may contain.
As it directly alters the path given, both of these syntax works:

    local walkable = 0
    local allowDiagonal = true
    local Jumper = require('Jumper.init')
    -- Assuming map is defined
    local pather = Jumper(map,walkable,allowDiagonal)
    local path, length = pather:searchPath(1,1,3,3)
    -- Capturing the returned value
    path = pather:smooth(path)
	
    -- OR
    local walkable = 0
    local allowDiagonal = true
    local Jumper = require('Jumper.init')
    -- Assuming map is defined
    local pather = Jumper(map,walkable,allowDiagonal)
    local path, length = pather:searchPath(1,1,3,3)
    -- Just passing the path to the smoother.
    pather:smooth(path)
	
##Known Issues##

* *Straight moves* : you may find paths with only straight moves allowed somewhat odd under some circumstances. This is something I am aware of, and expecting to fix next.

##Participating Libraries##

* [Lua Class System][]
* [Binary heaps][]

##About Visual Demo##

*Jumper_(Demo)* is a visual demo of for the current library.<br/>
You can run it on Windows, MAC & Linux and experience the full amazing capabilities of *Jumper*.<br/>
* Love version : [Jumper_(Demo).love][] (Requires [Löve 0.8.0 Framework][] to run, Compatible Windows, Mac OSX, Linux)
* Compiled Version for Windows (Stand-alone) : [Jumper_(Demo).rar][]

##About Benchmarking Tests##

*Jumper_(Tests)* is a demo featuring benchmarking tests using the current library.<br/>
You can run it on Windows, MAC & Linux.<br/>
Maps included come from [Dragon Age : Origins][] and were taken on [Moving AI][].
* Love version : [Jumper_(Tests).love][] (Requires [Löve 0.8.0 Framework][] to run, Compatible Windows, Mac OSX, Linux)
* Compiled Version for Windows (Stand-alone) : [Jumper_(Tests).rar][]

While running Tests, you might be asked for outputting results.<br/>
You will find these outputs on different locations of your hard drive according to your operating system :
* Windows XP : *C:\Documents and Settings\Your_Username\Application Data\Love\Jumper\* or *%appdata%\Love\Jumper\*
* Windows Vista and 7 : *C:\Users\Your_Username\AppData\Roaming\LOVE\Jumper\* or *%appdata%\Love\Jumper\*
* Linux : *$XDG_DATA_HOME/love/Jumper/* or ~/.local/share/love/Jumper/*
* Mac : */Users/Your_Username/Library/Application Support/LOVE/Jumper/*

##Credits and Thanks##

* [Daniel Harabor][], [Alban Grastien][] : for [technical papers][].<br/>
* [XueXiao Xu][], [Nathan Witmer][]: for their amazing [port][] in Javascript<br/>
* [Löve][] Development Team

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
[Löve 0.8.0 Framework]: https://love2d.org
[Dragon Age : Origins]: http://dragonage.bioware.com
[Moving AI]: http://movingai.com
[Nathan Witmer]: https://github.com/aniero
[XueXiao Xu]: https://github.com/qiao
[port]: https://github.com/qiao/PathFinding.js
[Alban Grastien]: http://www.grastien.net/ban/
[Daniel Harabor]: http://users.cecs.anu.edu.au/~dharabor/home.html
[technical papers]: http://users.cecs.anu.edu.au/~dharabor/data/papers/harabor-grastien-aaai11.pdf
[MIT-LICENSE]: http://www.opensource.org/licenses/mit-license.php
[Jumper]: https://github.com/Yonaba/Jumper/tree/master/Jumper
[Jumper_(Demo).love]: https://github.com/downloads/Yonaba/Jumper/Jumper_(Demo).love
[Jumper_(Tests).love]: https://github.com/downloads/Yonaba/Jumper/Jumper_(Tests).love
[Jumper_(Demo).rar]: https://github.com/downloads/Yonaba/Jumper/Jumper_(Demo)_(Compiled%20For%20Windows).rar
[Jumper_(Tests).rar]: https://github.com/downloads/Yonaba/Jumper/Jumper_(Tests)_(Compiled%20For%20Windows).rar