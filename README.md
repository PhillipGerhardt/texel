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
Seek to a position by clicking on it.

    layer = texel.Layer();
    texel.layers = [layer];
    layer.size = texel.size.map(v=>v*0.9)
    layer.position = texel.size.map(v=>v/2);
    files = texel.contentsOfDirectory(path.join(os.homedir(), 'Movies')).filter(v=>texel.isMovie(v)).filter(v=>texel.canReadAsset(v))
    file = texel.shuffle(files)[0];
    console.log(file); // make sure it plays in quicktime
    movie = texel.Movie(file, true, false); // loop = true, muted = false
    movie.start();
    layer.content = movie;
    gc();

To stop the movie we need to unreference all variables and start the javascript garbage collector:

    texel.layers = [];
    layer = undefined;
    movie = undefined;
    gc();

Show some image:

    layer = texel.Layer();
    texel.layers = [layer];
    layer.size = texel.size.map(v=>v*0.6)
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

Make text ticker:

    layer = texel.Layer();
    layer.draw = false;
    texel.layers = [layer];
    layer.size = [texel.size[0], texel.size[1]/8];
    layer.position = texel.size.map(v=>v/2);
    msg = "In computer graphics, a texel, texture element, or texture pixel is the fundamental unit of a texture map. ";
    speed = 800;
    fontSize = 128;
    foregroundColor = [1,1,1,1];
    backgroundColor = [0.0, 0.5, 0.5, 1];
    ticker = texel.Ticker(layer.size, msg, speed, fontSize, foregroundColor, backgroundColor);
    layer.content = ticker;
    ticker.start();

## Run demos

The demos use asset files from your "Movies" and "Pictures" directories.
Adjust that to your needs.

    eval(fs.readFileSync('animations.js')+'');
    eval(fs.readFileSync('movies.js')+'');
    eval(fs.readFileSync('slideshow.js')+'');
    eval(fs.readFileSync('grid_exchange.js')+'');
    eval(fs.readFileSync('videoplayer.js')+'');
    eval(fs.readFileSync('alignment_fitting.js')+'');
    eval(fs.readFileSync('choose_animation.js')+'');
    eval(fs.readFileSync('fragment_metaball.js')+'');
    eval(fs.readFileSync('fragment_hit.js')+'');
    eval(fs.readFileSync('fragment_pixelate.js')+'');
    eval(fs.readFileSync('fragment_combine_textures.js')+'');
    eval(fs.readFileSync('fragment_adjust_lod.js')+'');
    eval(fs.readFileSync('vision_detector.js')+'');

