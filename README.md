# Raycaster
A simple raycaster engine. Raycasting is an old technique for rendering pseudo 3d graphics. You may know this technique from [Wolfenstein 3D](http://en.wikipedia.org/wiki/Wolfenstein_3D_engine "Wikipedia article"). For each column of the screen a ray is emmited. If the ray intersects an object (e. g. a wall), the texture of this object get rendered. This technique is limited to walls of the same height.

# Installation
1. Copy **vertex.mod** into your `%BlitzMax%/mod` folder
2. Make sure you have setup MinGW for BlitzMax correctly. Please check this topics:
 * [Guide how to set up MinGW for BlitzMax](http://www.blitzbasic.com/Community/posts.php?topic=90964)
 * [Installed MingW, can no longer build project](http://www.blitzbasic.com/Community/posts.php?topic=104435)
3. Open the MaxIDE, goto **Program** > **Build Modules**
4. Now you can import the raycaster engine by writing `import vertex.raycaster`

# Screenshot
This screenshot is taken from the _examples/Game.bmx_ example.

![Screenshot](https://cloud.githubusercontent.com/assets/10528519/8037979/1a98beac-0e01-11e5-9cec-7cd91b39f6e6.png "Screenshot taken from the game example")
