
let anims = texel.enums()["Ease"];
let n = anims.length;

var layers = []

function init() {
    for (let i = 0; i < n; ++i) {
        let l = texel.Layer();
        l.size = [h/n, h/n];
        l.position = [i*(w/n) + w/(n*2), h * 4/5];
        layers.push(l);
    }
    texel.layers = layers;
}

function down() {
    for (let i = 0; i < n; ++i) {
        let l = layers[i];
        l.position = texel.Animation([i*(w/n) + w/(n*2), h * 1/5], 3, anims[i]);
    }
}

function up() {
    for (let i = 0; i < n; ++i) {
        let l = layers[i];
        l.position = texel.Animation([i*(w/n) + w/(n*2), h * 4/5], 3, anims[i]);
    }
}

let w = texel.size[0];
let h = texel.size[1];
let direction = 1;
texel.onKeyDown = keyCode => { 
    console.log('onKeyDown');
    if (direction == 1) { down(); }
    if (direction == 0) { up(); }
    direction += 1;
    direction = direction % 2;
};

init();

global.gc();

