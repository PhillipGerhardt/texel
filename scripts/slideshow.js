'use strict';

function make() {
    let l = texel.Layer();
    l.draw = false;
    l.contentColor = 0;
    l.size = texel.size;
    l.size = texel.size.map(x=>x*3/4);
    l.position = texel.size.map(x=>x/2);
    let file = files[index];
    console.log('file', file);
    if (texel.isMovie(file)) {
        l.content = texel.Movie(file, true);
        l.contentVolume = 0;
        l.content.start();
    }
    if (texel.isImage(file)) {
        l.content = texel.Image(file);
    }
    return l;
}

function step() {
    let l = make();
    let layers = texel.layers;
    layers.push(l);
    while (layers.length > 2) { layers.shift(); }
    texel.layers = layers;
    let ad = 1;
    let at = 'outQuad';
    let left = [- texel.size[0], texel.size[1]/2];
    let center = texel.size.map(v=>v/2);
    let right = [2 * texel.size[0], texel.size[1]/2];
    l.position = right;
    if (layers.length == 2) {
        layers[0].contentColor = texel.Animation([0,0,0,0], ad, at);
        layers[0].contentVolume = texel.Animation(0, ad, at);
        layers[0].position = texel.Animation(left, ad, at);
        layers[1].contentColor = texel.Animation([1,1,1,1], ad, at);
        layers[1].contentVolume = texel.Animation(1, ad, at);
        layers[1].position = texel.Animation(center, ad, at);
    }
    else {
        layers[0].contentColor = texel.Animation([1,1,1,1], ad, at);
        layers[0].contentVolume = texel.Animation(1, ad, at);
        layers[0].position = texel.Animation(center, ad, at);
    }
    global.gc();
}

texel.onKeyDown = keyCode => {
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
files = texel.shuffle(files);
index = 0;
texel.layers = [];
step();
global.gc();

