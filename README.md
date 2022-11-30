# Texel

Integrate node into a Swift App and use javascript to play videos with Metal.

## Install dependencies

### nodejs

    git submodule update --init --recursive
    cd node
    ./make_node.sh

### net-repl

    cd scripts
    npm install

## Running Texel

The size and position of the window can be adjusted in "applicationDidFinishLaunching".

## Interact with Texel

When Texel is running connect to the node-repl-socket and use javascript to
interact with the scene.

Connect to repl:

    scripts/node_modules/net-repl/bin/repl.js /tmp/texel.repl

Make a single layer:

    layer = texel.Layer();
    texel.layers = [layer];
    layer.size = texel.size.map(v=>v/2)
    layer.position = texel.size.map(v=>v/2);

Animate something:

    size = layer.size; rotation = layer.rotation;
    layer.size = texel.Animation(size.map(v=>v/2));
    layer.rotation = texel.Animation(rotation + 3.1415)
    setTimeout(()=>{layer.size = size; layer.rotation = rotation;}, 2000);

Start a movie:

    layer = texel.Layer();
    texel.layers = [layer];
    layer.size = texel.size.map(v=>v/2)
    layer.position = texel.size.map(v=>v/2);
    file = 'path/to/file.mov';
    movie = texel.Movie(file, true, false);
    movie.start();
    layer.content = movie;

To stop the movie we need to unreference all variables and start the javascript garbage collector:

    layer = undefined;
    movie = undefined;
    gc();

Show some image:

    layer = texel.Layer();
    texel.layers = [layer];
    layer.size = texel.size.map(v=>v/2)
    layer.position = texel.size.map(v=>v/2);
    image = texel.Image('/System/Library/Desktop Pictures/Big Sur Graphic.heic');
    layer.content = image;

Make text:

    layer = texel.Layer();
    texel.layers = [layer];
    layer.size = texel.size.map(v=>v/2)
    layer.position = texel.size.map(v=>v/2);
    text = texel.Text("Hello World");
    layer.content = text;

## Run demos

The demos use assets files from your "Movies" and "Pictures" directories.
Adjust that to your needs.

    eval(fs.readFileSync('animations.js')+'');
    eval(fs.readFileSync('movies.js')+'');
    eval(fs.readFileSync('slideshow.js')+'');
    eval(fs.readFileSync('grid_exchange.js')+'');
    eval(fs.readFileSync('videoplayer.js')+'');
    eval(fs.readFileSync('alignment_fitting.js')+'');
    eval(fs.readFileSync('choose_animation.js')+'');

