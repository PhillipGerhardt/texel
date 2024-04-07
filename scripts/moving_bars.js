
let w = texel.size[0];
let h = texel.size[1];

let a = texel.Layer();
let b = texel.Layer();
let c = texel.Layer();
let d = texel.Layer();
a.size = [100, h];
b.size = [100, h];
c.size = [w, 100];
d.size = [w, 100];
a.position = [0, h/2];
b.position = [w, h/2];
c.position = [w/2, h];
d.position = [w/2, 0];
texel.layers = [a,b,c,d];

let dur = 8;
let i = 0;

function step() {
    if (i == 0) {
        a.position = texel.Animation([w, h/2], dur);
        b.position = texel.Animation([0, h/2], dur);
        c.position = texel.Animation([w/2, 0], dur);
        d.position = texel.Animation([w/2, h], dur);
    }
    if (i == 1) {
        a.position = texel.Animation([0, h/2], dur);
        b.position = texel.Animation([w, h/2], dur);
        c.position = texel.Animation([w/2, h], dur);
        d.position = texel.Animation([w/2, 0], dur);
    }
    i = (i + 1) % 2;
}

texel.onKeyDown = keyCode => {
    console.log('step');
    step();
}

if (global.i) {
    clearInterval(global.i);
}
global.i = setInterval(step, dur * 1000);
step();

global.gc();


