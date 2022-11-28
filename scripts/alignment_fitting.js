'use strict';

let t = process._linkedBinding('texel'); 

const kScaleMode = 'ScaleMode';
const kHorizontalAlignment = 'HorizontalAlignment';
const kVerticalAlignment = 'VerticalAlignment';

t.layers = [];

let sIdx = 0;
let hIdx = 0;
let vIdx = 0;

let l = t.Layer();
l.size = t.size.map(v=>v/2)
l.position = t.size.map(v=>v/2);
let txt = t.Text('', [512,512]);
txt.foregroundColor = [0,0,0,1];
txt.backgroundColor = 0.8;
txt.fontSize = 36;
l.content = txt;

let infoSize = [t.size[0], t.size[1] / 8];
let info = t.Text("Use arrow keys to change settings", infoSize);
info.fontSize = 36*2;
let li = t.Layer();
li.size = infoSize;
li.pivot = [0,0];
li.content = info;

t.layers = [l,li];

function update() {
    txt.text = `
    ${kScaleMode}: ${t.enums()[kScaleMode][sIdx]}
    ${kHorizontalAlignment}: ${t.enums()[kHorizontalAlignment][hIdx]}
    ${kVerticalAlignment}: ${t.enums()[kVerticalAlignment][vIdx]}
    `;
    l.contentScaling = t.enums()[kScaleMode][sIdx];
    l.contentHorizontalAlignment = t.enums()[kHorizontalAlignment][hIdx];
    l.contentVerticalAlignment = t.enums()[kVerticalAlignment][vIdx];
}

update();

t.onKeyDown = keyCode => { 
    if (keyCode == 125) /* down */ { sIdx += 1; }
    if (keyCode == 126) /* up */ { vIdx += 1; }
    if (keyCode == 124) /* right */ { hIdx += 1; }
    if (keyCode == 123) /* left */ {  
        l.size = l.size.reverse();
    }
    sIdx = sIdx % t.enums()[kScaleMode].length;
    hIdx = hIdx % t.enums()[kHorizontalAlignment].length;
    vIdx = vIdx % t.enums()[kVerticalAlignment].length;
    update();
};

global.gc();

