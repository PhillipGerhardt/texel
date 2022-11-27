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

Start a movie:

    t = process._linkedBinding('texel');
    l = t.Layer();
    t.layers = [l];
    l.size = t.size.map(v=>v/2)
    l.position = t.size.map(v=>v/2);
    file = '/path/to/movie.mov';
    c = t.Movie(file, true, false);
    c.start();
    l.content = c;
    global.gc();

Animate something:

    s = l.size; r = l.rotation;
    l.size = t.Animation(s.map(v=>v/2));
    l.rotation = t.Animation(r + 3.1415)
    setTimeout(()=>{l.size = s; l.rotation = r;}, 2000);
