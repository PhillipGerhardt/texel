'use strict';

delete require.cache[require.resolve('./txl.js')];
const t = process._linkedBinding('texel'); 
const txl = require('./txl.js');

function make() {
    let l = t.Layer();
    l.draw = false;
    l.contentColor = 0;
    l.size = t.size;
    l.size = t.size.map(x=>x*3/4);
    l.position = t.size.map(x=>x/2);
    let file = files[index];
    if (txl.is_movie(file)) {
        l.content = t.Movie(file, true);
        l.contentVolume = 0;
        l.content.start();
    }
    if (txl.is_image(file)) {
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
    let at = 'linear';
    if (layers.length == 2) {
        layers[0].contentColor = t.Animation([0,0,0,0], ad, at);
        layers[0].contentVolume = t.Animation(0, ad, at);
        layers[1].contentColor = t.Animation([1,1,1,1], ad, at);
        layers[1].contentVolume = t.Animation(1, ad, at);
    }
    else {
        layers[0].contentColor = t.Animation([1,1,1,1], ad, at);
        layers[0].contentVolume = t.Animation(1, ad, at);
    }
    global.gc();
}

t.onKeyDown = keyCode => { 
    if (keyCode == 125) { // down
        index += 1;
    }
    if (keyCode == 126) { // up
        index -= 1;
    }
    if (index == -1) { index = files.length - 1; }
    if (index == files.length) { index = 0; }
    step(); 
};

let index = 0;
let files = txl.get_assets();
txl.shuffle(files);
index = 0;
t.layers = [];
step();
global.gc();

