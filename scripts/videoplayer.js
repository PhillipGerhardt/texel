const path = require('path');

function make() {
    let l = texel.Layer();
    l.draw = false;
    l.contentColor = 0;
    l.contentScaling = 'fit';
    l.size = texel.size;
    l.size = texel.size.map(x=>x*4/5);
    l.position = texel.size.map(x=>x/2);
    let file = files[index];
    console.log('file', file);
    let content = texel.Movie(file, true);
    l.contentVolume = 0;
    content.start();
    l.content = content;
    return l;
}

function step() {
    l = make();
    layers = texel.layers;
    layers.push(l);
    while (layers.length > 2) { layers.shift(); }
    texel.layers = layers;
    let ad = 2;
    let at = 'outExpo';
    let ls = texel.size.map(x=>x*4/5);
    let center = texel.size.map(x=>x/2);
    let ty = center[1] - ls[1];
    let sy = center[1] + ls[1];
    if (direction == -1) {
        ty = center[1] + ls[1];
        sy = center[1] - ls[1];
    }
    if (layers.length == 2) {
        layers[0].position = texel.Animation([texel.size[0]/2, ty], ad, at);

        layers[1].position = [texel.size[0]/2, sy];
        layers[1].position = texel.Animation(texel.size.map(x=>x/2), ad, at);

        layers[0].contentColor = texel.Animation([0,0,0,0], ad);
        layers[0].contentVolume = texel.Animation(0, ad);
        layers[1].contentColor = texel.Animation([1,1,1,1], ad);
        layers[1].contentVolume = texel.Animation(1, ad);

        let oldContent = layers[0].content;
        setTimeout(()=>{oldContent.stop();}, 1000 * ad);
    }
    else {
        layers[0].position = [texel.size[0]/2, sy];
        layers[0].position = texel.Animation(texel.size.map(x=>x/2), ad, at);

        layers[0].contentColor = texel.Animation([1,1,1,1], ad);
        layers[0].contentVolume = texel.Animation(1, ad);
    }
    global.gc();
}

function forward() {
    console.log('forward');
    layers = texel.layers;
    layer = layers[layers.length - 1];
    content = layer.content;
    let pos = content.position;
    console.log('pos', pos);
    pos = Math.min(pos + 0.05, 1);
    console.log('pos', pos);
    content.position = pos;
}

function backward() {
    console.log('backward');
    layers = texel.layers;
    layer = layers[layers.length - 1];
    content = layer.content;
    let pos = content.position;
    console.log('pos', pos);
    pos = Math.max(pos - 0.05, 0);
    console.log('pos', pos);
    content.position = pos;
}

function stop() {
    layers = texel.layers;
    layer = layers[layers.length - 1];
    layer.content.stop();
}

function start() {
    layers = texel.layers;
    layer = layers[layers.length - 1];
    layer.content.start();
}

texel.onKeyDown = keyCode => {
    console.log(keyCode);
    if (keyCode == 125) { // down
        direction = 1;
        index += 1;
    }
    if (keyCode == 126) { // up
        direction = -1;
        index -= 1;
    }
    if (keyCode == 35) { // p
        stop();
    }
    if (keyCode == 8) { // c
        start();
    }

    if (index == -1) { index = files.length - 1; }
    if (index == files.length) { index = 0; }

    if (keyCode == 125 || keyCode == 126) { step(); }
    if (keyCode == 123) { backward(); }
    if (keyCode == 124) { forward(); }
};

let movieDir = path.join(os.homedir(), 'Movies');
let files = texel.contentsOfDirectory(movieDir, true)
    .filter(v=>texel.isMovie(v))
    .filter(v=>texel.isPlayable(v))
    .filter(v=>texel.assetSize(v)[0] <= 1920);
let index = 0;
let direction = 1;

texel.layers = [];
step();

console.log('use up and down arrow to choose a video');
console.log('use left and right to seek');

global.gc();

