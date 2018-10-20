Voronoi
=======

![voronoi demo sm](https://user-images.githubusercontent.com/186680/47255581-7e327980-d441-11e8-9e43-d5cdddb646e5.png)

An Objective-C port of Java implementation of the S-Hull algorithm, for Delaunay triangulation and Voronoi Cell generation, in 2 dimensions.

The original C++ source, by inventor Dr. David Sinclair, can be found here: http://www.s-hull.org. The same site includes a link to a C# implementation.

The primary reference for this port was the Java implementation, found here: http://code.google.com/p/jshull/

The project includes a very simple demonstration application. CMD-N to make a new image. It is document-based, but save/load not supported yet.

The project includes code from other, private libraries, but are considered to have the same license as the rest of the project when used for this project or in projects derived from this project.

The content of this project is released under a BSD-style license. Use it as you see fit. No warranty explicit or implied. No promises, no guarantees. Use at your own risk.

New Version
-----------

The basic strategy is being re-implemented from scratch in the voronoi library, without reference to any other sources, only the paper that roughly describes the algorithm. I am exploring different approaches to some aspects of the strategy, including a structural induction approach, performing triangle flipping after each new point is added to the set. (New work is on the `rewrite` branch.)
