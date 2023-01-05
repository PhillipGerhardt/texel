'use strict';

const kScaleMode = 'ScaleMode';
const kHorizontalAlignment = 'HorizontalAlignment';
const kVerticalAlignment = 'VerticalAlignment';

texel.layers = [];

let sIdx = 0;
let hIdx = 0;
let vIdx = 0;

let l = texel.Layer();
l.size = texel.size.map(v=>v/2)
l.position = texel.size.map(v=>v/2);
let txt = texel.Text('', [512,512]);
txt.foregroundColor = [0,0,0,1];
txt.backgroundColor = 0.8;
txt.fontSize = 36;
l.content = txt;

let infoSize = [texel.size[0], texel.size[1] / 8];
let info = texel.Text("Use arrow keys to change settings", infoSize);
info.fontSize = 36*2;
let li = texel.Layer();
li.size = infoSize;
li.pivot = [0,0];
li.content = info;

texel.layers = [l,li];

function update() {
    txt.text = `
    ${kScaleMode}: ${texel.enums()[kScaleMode][sIdx]}
    ${kHorizontalAlignment}: ${texel.enums()[kHorizontalAlignment][hIdx]}
    ${kVerticalAlignment}: ${texel.enums()[kVerticalAlignment][vIdx]}
    `;
    l.contentScaling = texel.enums()[kScaleMode][sIdx];
    l.contentHorizontalAlignment = texel.enums()[kHorizontalAlignment][hIdx];
    l.contentVerticalAlignment = texel.enums()[kVerticalAlignment][vIdx];
}

update();

texel.onKeyDown = keyCode => { 
    if (keyCode == 125) /* down */ { sIdx += 1; }
    if (keyCode == 126) /* up */ { vIdx += 1; }
    if (keyCode == 124) /* right */ { hIdx += 1; }
    if (keyCode == 123) /* left */ {  
        l.size = l.size.reverse();
    }
    sIdx = sIdx % texel.enums()[kScaleMode].length;
    hIdx = hIdx % texel.enums()[kHorizontalAlignment].length;
    vIdx = vIdx % texel.enums()[kVerticalAlignment].length;
    update();
};

global.gc();

