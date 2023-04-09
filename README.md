# Texel

Integrate node into a Swift App and use javascript to play videos with Metal.

## Install dependencies

    git submodule update --init --recursive

### Build externals

    cd externals
    ./make_node.sh
    ./make_ffmpeg.sh

### Install net-repl

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
    files = texel.contentsOfDirectory(path.join(os.homedir(), 'Movies')).filter(v=>texel.isMovie(v)).filter(v=>texel.isPlayable(v))
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

Play a movie with FFmpeg:

    layer = texel.Layer();
    texel.layers = [layer];
    layer.size = texel.size.map(v=>v*0.9)
    layer.position = texel.size.map(v=>v/2);
    files = texel.contentsOfDirectory(path.join(os.homedir(), 'Movies')).filter(v=>texel.isMovie(v));
    file = texel.shuffle(files)[0];
    movie = texel.Movie(file, true, false); // loop = true, muted = false
    movie.start();
    layer.content = movie;
    gc();

Show some image:

    layer = texel.Layer();
    texel.layers = [layer];
    layer.size = texel.size.map(v=>v*0.6)
    layer.position = texel.size.map(v=>v/2);
    image = texel.Image('/System/Library/Desktop Pictures/Big Sur Graphic.heic');
    layer.content = image;

Create and show raw image:

    > ffmpeg -ss 00:00:00 -i myvideo.mov -frames 1 -vf scale=1280:720 -vcodec rawvideo -pix_fmt rgb24 -f image2 /tmp/raw.rgb

    layer = texel.Layer();
    texel.layers = [layer];
    layer.size = texel.size.map(v=>v*0.6)
    layer.position = texel.size.map(v=>v/2);
    image = texel.Raw('/tmp/raw.rgb', 1280, 720, 3);
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

Make map:

    layer = texel.Layer();
    texel.layers = [layer];
    layer.size = texel.size;
    layer.position = texel.size.map(v=>v/2);
    map = texel.Map([512,512]);
    map.start()
    layer.content = map;

## Run demos

The demos use asset files from your "Movies" and "Pictures" directories.
Adjust that to your needs.

    eval(fs.readFileSync('alignment_fitting.js')+'');
    eval(fs.readFileSync('animations.js')+'');
    eval(fs.readFileSync('choose_animation.js')+'');
    eval(fs.readFileSync('filter.js')+'');
    eval(fs.readFileSync('fragment_adjust_lod.js')+'');
    eval(fs.readFileSync('fragment_combine_textures.js')+'');
    eval(fs.readFileSync('fragment_hit.js')+'');
    eval(fs.readFileSync('fragment_metaball.js')+'');
    eval(fs.readFileSync('fragment_pixelate.js')+'');
    eval(fs.readFileSync('fragment_sdf.js')+'');
    eval(fs.readFileSync('fragment_wave_combine.js')+'');
    eval(fs.readFileSync('game_of_life.js')+'');
    eval(fs.readFileSync('grid_exchange.js')+'');
    eval(fs.readFileSync('movies.js')+'');
    eval(fs.readFileSync('rain.js')+'');
    eval(fs.readFileSync('slideshow.js')+'');
    eval(fs.readFileSync('ticker.js')+'');
    eval(fs.readFileSync('videoplayer.js')+'');
    eval(fs.readFileSync('vision_detector.js')+'');
    eval(fs.readFileSync('wave.js')+'');
    eval(fs.readFileSync('hit_test.js')+'');
    eval(fs.readFileSync('color_some_layers.js')+'');

