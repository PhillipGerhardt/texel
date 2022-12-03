'use strict';

const t = process._linkedBinding('texel');

function make() {
    let l = t.Layer();
    l.draw = false;
    l.contentColor = 0;
    l.size = t.size;
    l.size = t.size.map(x=>x*3/4);
    l.position = t.size.map(x=>x/2);
    let file = files[index];
    console.log('file', file);
    if (texel.isMovie(file)) {
        l.content = t.Movie(file, true);
        l.contentVolume = 0;
        l.content.start();
    }
    if (texel.isImage(file)) {
        l.content = t.Image(file);
    }
    return l;
}

function step() {
    let l = make();
    let layers = t.layers;
    layers.push(l);
    while (layers.length > 2) { layers.shift(); }
    t.layers = layers;
    let ad = 1;
    let at = 'outQuad';
    let left = [- t.size[0], t.size[1]/2];
    let center = t.size.map(v=>v/2);
    let right = [2 * t.size[0], t.size[1]/2];
    l.position = right;
    if (layers.length == 2) {
        layers[0].contentColor = t.Animation([0,0,0,0], ad, at);
        layers[0].contentVolume = t.Animation(0, ad, at);
        layers[0].position = t.Animation(left, ad, at);
        layers[1].contentColor = t.Animation([1,1,1,1], ad, at);
        layers[1].contentVolume = t.Animation(1, ad, at);
        layers[1].position = t.Animation(center, ad, at);
    }
    else {
        layers[0].contentColor = t.Animation([1,1,1,1], ad, at);
        layers[0].contentVolume = t.Animation(1, ad, at);
        layers[0].position = t.Animation(center, ad, at);
    }
    global.gc();
}

t.onKeyDown = keyCode => {
    if (keyCode == 123) { // left
        index += 1;
    }
    if (keyCode == 124) { // right
        index -= 1;
    }
    if (index == -1) { index = files.length - 1; }
    if (index == files.length) { index = 0; }
    step();
};

let index = 0;
let movieDir = path.join(os.homedir(), 'Movies');
let imageDir = path.join(os.homedir(), 'Pictures');
let images = texel.contentsOfDirectory(imageDir).filter(v=>texel.isImage(v));
let movies = texel.contentsOfDirectory(movieDir).filter(v=>texel.isMovie(v));
let files = images.concat(movies);
files = files.filter(v=>texel.canReadAsset(v));
files = texel.shuffle(files);
index = 0;
t.layers = [];
step();
global.gc();

