'use strict';

let t = process._linkedBinding('texel'); 
let anims = t.enums()["Ease"];

let l = t.Layer();
l.size = t.size.map(v=>v/5);
let src = t.size.map(v=>v*(1/5));
let dst = t.size.map(v=>v*(4/5));
l.position = src;
let c = t.Text("", l.size);
c.fontSize = 64;
c.text = "hello";
l.content = c;

let infoSize = [t.size[0], t.size[1] / 8];
let info = t.Text("Arrow up/down: Choose animation. Space: Start animation.", infoSize);
info.fontSize = 36*2;
let li = t.Layer();
li.draw = false;
li.size = infoSize;
li.pivot = [0,0];
li.content = info;


t.layers = [l, li];

function update() {
    c.text = `${anims[animIdx]}`;
} 

let direction = 1;
let animIdx = 0;
let animDuration = 1;
t.onKeyDown = keyCode => { 
    if (keyCode == 125) /* down */ { animIdx -= 1; }
    if (keyCode == 126) /* up */ { animIdx += 1; }
    if (animIdx == -1) { animIdx = anims.length - 1; }
    if (animIdx == anims.length) { animIdx = 0; }
    animIdx = animIdx % anims.length;
    if (keyCode == 49) /* space */ {
        if (direction == 1) {  
            l.position = t.Animation(dst, animDuration, anims[animIdx]);
        }
        if (direction == 0) {  
            l.position = t.Animation(src, animDuration, anims[animIdx]);
        }
        direction = (direction + 1 ) % 2;
    }
    update();
};
update();

global.gc();


