__Jumper__ is a pathfinding library designed for __uniform-cost 2D grid-based__ games featuring [Jump Point Search][] algorithm.<br/>
__Jumper__ is (very) fast, lightweight and generates almost no memory overhead. As such, it might be an interesting option
for pathfinding computation on 2D maps.
Plus, *Jumper* offers a clean API which makes it very friendly and easy-to-use.<br/>

__Jumper__ is written in pure [Lua][]. Thus, it is not __framework-related__ and can be used in __any project__ embedding [Lua][] code.

##Files##

* [Jumper][] contains the library itself.
* [Jumper_(Demo).love][] | [Jumper_(Demo).rar][] is a visual interactive demo.
* [Jumper_(Tests).love][] | [Jumper_(Tests).rar][] is another demo which performs a set of benchmark tests.
  
##Usage##

Place the folder [Jumper][] inside your projet. Use *require* to load it.

    local Jumper = require('Jumper.init')

*Note : If your LUA path includes search for "init.lua" on folder opening, as [Löve][] Framework do, you can simply use: require('Jumper')*

Now you must now setup a 2D matrix of __integers__ or __strings__ representing your world. Values stored in this matrix
should represent whether or not a cell on the matrix is walkable or not. If you choose for instance
*0* for walkable tiles, __any other value__ will be considered as non walkable.

    local map = {
          {0,0,0},
          {0,2,0},
          {0,0,1},
          }

To initialize the pathfinder, you will have to pass __four values__. 

    local walkable = 0
    local allowDiagonal = true
    local pather = Jumper(map,walkable,allowDiagonal,heuristic)
  
Only the first argument is __required__, the __three others__ left are __optional__.
* __map__ refers to the matrix representing the 2D world.
* __walkable__ refers to the value representing walkable tiles. Will be considered as *0* if not given.
* __allowDiagonal__ is a boolean saying whether or not diagonal moves are allowed. Will be considered as __true__ if not given.
* __heuristic__ is a predefined constant representing the heuristic function to be used for path computation.

##Distance heuristics##

*Jumper* features 4 types of distance heuristics.

* MANHATTAN Distance : <em>|dx| + |dy|</em>
* EUCLIDIAN Distance : <em>sqrt(dx*dx + dy*dy)</em>
* DIAGONAL Distance : <em>max(|dx|, |dy|)</em>
* CHEBYSHEV Distance : <em>DIAGONAL(dx,dy)</em>

Each of these distance heuristics are packed inside Jumper's core. By default, when initializing  *Jumper*, __MANHATTAN__ Distance is used if 
no heuristic was specified.<br/>
If you need to use __another distance heuristic__, you will need to __require all distance heuristics__ first.
All distance heuristics are defined inside [heuristics.lua][].

    local walkable = 0
    local allowDiagonal = true
    local Heuristics. = require 'Jumper.core.heuristics'
    local Jumper = require('Jumper.init')
    local pather = Jumper(map,walkable,allowDiagonal,Heuristics.EUCLIDIAN)

You can __alternatively__ use *setHeuristic(Name)*. This way, __requiring distance heuristics is no more relevant__.
The __heuristic name__ to be passed to *setHeuristic()* method must be one of these following, with quotes:

* __"MANHATTAN"__ (referring to MANHATTAN Distance)
* __"EUCLIDIAN"__ (referring to EUCLIDIAN Distance)
* __"DIAGONAL"__ or __"CHEBYSHEV"__ (referring to DIAGONAL Distance)

As an example :
 
    local walkable = 0
    local allowDiagonal = true
    local Jumper = require('Jumper.init')
    local pather = Jumper(map,walkable,allowDiagonal)
    pather:setheuristic('EUCLIDIAN')

##API##

###Main Pathfinder Class API

Once loaded and initialized properly, you can now used one of the following methods listed below.<br/>
__Assuming *pather* represents an instance of *Jumper* class.__
	
####pather:setHeuristic(NAME)
Will change the heuristic to be used.<br/>
__NAME__ must be passed as a string.<br/>
Possible values are __"MANHATTAN"__,__"EUCLIDIAN"__,__"DIAGONAL"__,__"CHEBYSHEV"__ (case-sensitive!).
* __Argument NAME__: a string
* __Returns:__ Nothing

####pather:getHeuristic() 
Will return a reference to the __heuristic function__ internally used.<br/>
* __Argument__: Nothing
* __Returns:__ a function

####pather:setDiagonalMoves(Bool)
Argument must be a boolean. __true__ will authorize __diagonal moves__, __false__ will allow __only straight-moves__.<br/>
* __Argument Bool__: a boolean
* __Returns:__ Nothing

####pather:getDiagonalMoves()
Returns __a boolean__ saying whether or not diagonal moves are allowed.
* __Argument__: Nothing
* __Returns:__ a boolean

####pather:getGrid()
Returns a reference to the __internal grid__ used by the pathfinder.
This grid is __not__ the map matrix given on initialization, but a __virtual representation__ used internally.
* __Argument__: Nothing
* __Returns:__ a grid (regular Lua table)

####pather:searchPath(startX,startY,endX,endY)
Main function, returns a path from [startX,startY] to [endX,endY] as an __ordered array__ of locations ({x = ...,y = ...}).
Otherwise returns __nil__ if there is __no valid path__.
Also returns a __second value__ representing __total cost of the move__ if a path was found.
* __Argument startX__: The X coordinate of the starting node (positive non zero integer)
* __Argument startY__: The Y coordinate of the starting node (positive non zero integer)
* __Argument endX__: The X coordinate of the goal node (positive non zero integer)
* __Argument endY__: The Y coordinate of the goal node (positive non zero integer)
* __Returns:__ a path (regular Lua table) or nil
* __Returns:__ the path cost (positive number) or nil

####pather:smooth(Path)
Polishes a path
* __Argument Path__: a path (regular Lua table)
* __Returns:__ a path (regular Lua table)

###Grid Class API

Using *getGrid()* returns a reference to the internal grid used by the pathfinder.
On this reference, you can use one of the following methods.<br/>
__Assuming *grid* holds the return value from *pather:getGrid()*__

####grid:getNodeAt(x,y)
Returns a reference to the node (X,Y) on the grid.

* __Argument x__: the X coordinate of the requested node (positive non zero integer)
* __Argument y__: the Y coordinate of the requested node (positive non zero integer)
* __Returns:__ a node (regular Lua table)

####grid:isWalkableAt(x,y)
Returns a boolean saying whether or not the node (X,Y) __exists on the grid and is walkable__.
* __Argument x__: the X coordinate of the requested node (positive non zero integer)
* __Argument y__: the Y coordinate of the requested node (positive non zero integer)
* __Returns:__ a boolean

####grid:setWalkableAt(x,y,boolean)
Sets the node (X,Y) __walkable or not__ depending on the boolean given.
__true__ makes the node walkable, while __false__ makes it unwalkable.
* __Argument x__: the X coordinate of the requested node (positive non zero integer)
* __Argument y__: the Y coordinate of the requested node (positive non zero integer)
* __Argument boolean__: a boolean
* __Returns:__ Nothing

####grid:getNeighbours(node,allowDiagonal)
Returns an array list of nodes __neighbouring location (X,Y)__.
The list will include or not adjacent nodes regards to the boolean __allowDiagonal__.
* __Argument node__: a node (regular Lua table)
* __Argument allowDiagonal__: a boolean
* __Returns:__ list of neighbours (regular Lua table)

####grid:reset()
Resets the grid. Called internally before each path computation, should not be used explicitely.
* __Argument__: Nothing
* __Returns:__ Nothing
 
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
			
You will have to make your own use of this to __route your entities__ on the 2D map along this path.<br/>
Note that the path could contains some *holes* because of the algorithm used.<br/>
However, this should not cause a serious issue as the move from one step to another along the path is always straight.
You can accomodate of this by yourself, or use the __path smoother__.

###Using the path smoother###

__Jumper__ provides a __path smoother__ that can be used to polish a path early computed, filling the holes it may contain.
As it directly alters the path given, both of these syntax works:

    local walkable = 0
    local allowDiagonal = true
    local Jumper = require('Jumper.init')
    -- Assuming map is defined
    local pather = Jumper(map,walkable,allowDiagonal)
    local path, length = pather:searchPath(1,1,3,3)
    -- Capturing the returned value
    path = pather:smooth(path)
	
  
    local walkable = 0
    local allowDiagonal = true
    local Jumper = require('Jumper.init')
    -- Assuming map is defined
    local pather = Jumper(map,walkable,allowDiagonal)
    local path, length = pather:searchPath(1,1,3,3)
    -- Just passing the path to the smoother.
    pather:smooth(path)
	
##Known Issues##

* __Straight moves__ : you may find paths with only straight moves allowed somewhat odd under some circumstances (too much zigzags). This is something I am aware of, and expecting to fix next.

##Participating Libraries##

* [Lua Class System][]
* [Binary heaps][]

##About Visual Demo##

*Jumper_(Demo)* is a visual demo of for the current library.<br/>
You can run it on __Windows__, __MAC__ & __Linux__ to experience the full amazing capabilities of __Jumper__.<br/>

* __Love version__: [Jumper_(Demo).love][] (Requires [Löve 0.8.0 Framework][] to run, *Compatible Windows, Mac OSX, Linux*)
* __Compiled Version for Windows (Stand-alone)__: [Jumper_(Demo).rar][]

##About Benchmarking Tests##

*Jumper_(Tests)* is a demo featuring benchmarking tests using the current library.<br/>
You can run it on __Windows__, __MAC__ & __Linux__.<br/>
Maps included come from [Dragon Age : Origins][] and were taken on [Moving AI][].

* __Love version__: [Jumper_(Tests).love][] (Requires [Löve 0.8.0 Framework][] to run, *Compatible Windows, Mac OSX, Linux*)
* __Compiled Version for Windows (Stand-alone)__: [Jumper_(Tests).rar][]

__Note:__While running Tests, you might be asked for outputting results.<br/>
You will find these outputs as __log files__ (regular Text files) on __different locations__ of your hard drive according to your __operating system__ :
* __Windows XP__ : *C:\Documents and Settings\Your_Username\Application Data\Love\Jumper\* or *%appdata%\Love\Jumper\*
* __Windows Vista__ and __Win7__ : *C:\Users\Your_Username\AppData\Roaming\LOVE\Jumper\* or *%appdata%\Love\Jumper\*
* __Linux__ : *$XDG_DATA_HOME/love/Jumper/* or ~/.local/share/love/Jumper/*
* __Mac__ : */Users/Your_Username/Library/Application Support/LOVE/Jumper/*

##Credits and Thanks##

* [Daniel Harabor][], [Alban Grastien][] : for [technical papers][].<br/>
* [XueXiao Xu][], [Nathan Witmer][]: for their amazing [port][] in Javascript<br/>
* [Löve][] Development Team, for [Löve][] Framework.

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
[Lua Class System]: http://yonaba.github.com/Lua-Class-System/
[Lua]: http://lua.org
[Binary heaps]: http://yonaba.github.com/Binary-Heaps/
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
[heuristics.lua]: https://github.com/Yonaba/Jumper/blob/master/Jumper/core/heuristics.lua
[Jumper_(Demo).love]: https://github.com/downloads/Yonaba/Jumper/Jumper_(Demo).love
[Jumper_(Tests).love]: https://github.com/downloads/Yonaba/Jumper/Jumper_(Tests).love
[Jumper_(Demo).rar]: https://github.com/downloads/Yonaba/Jumper/Jumper_(Demo)_(Compiled%20For%20Windows).rar
[Jumper_(Tests).rar]: https://github.com/downloads/Yonaba/Jumper/Jumper_(Tests)_(Compiled%20For%20Windows).rar