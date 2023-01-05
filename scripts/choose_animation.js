'use strict';

let anims = texel.enums()["Ease"];

let l = texel.Layer();
l.size = texel.size.map(v=>v/5);
let src = texel.size.map(v=>v*(1/5));
let dst = texel.size.map(v=>v*(4/5));
l.position = src;
let c = texel.Text("", l.size);
c.fontSize = 64;
c.text = "hello";
l.content = c;

let infoSize = [texel.size[0], texel.size[1] / 8];
let info = texel.Text("Arrow up/down: Choose animation. Space: Start animation.", infoSize);
info.fontSize = 36*2;
let li = texel.Layer();
li.draw = false;
li.size = infoSize;
li.pivot = [0,0];
li.content = info;


texel.layers = [l, li];

function update() {
    c.text = `${anims[animIdx]}`;
} 

let direction = 1;
let animIdx = 0;
let animDuration = 1;
texel.onKeyDown = keyCode => { 
    if (keyCode == 125) /* down */ { animIdx -= 1; }
    if (keyCode == 126) /* up */ { animIdx += 1; }
    if (animIdx == -1) { animIdx = anims.length - 1; }
    if (animIdx == anims.length) { animIdx = 0; }
    animIdx = animIdx % anims.length;
    if (keyCode == 49) /* space */ {
        if (direction == 1) {  
            l.position = texel.Animation(dst, animDuration, anims[animIdx]);
        }
        if (direction == 0) {  
            l.position = texel.Animation(src, animDuration, anims[animIdx]);
        }
        direction = (direction + 1 ) % 2;
    }
    update();
};
update();

global.gc();


