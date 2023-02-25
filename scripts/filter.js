'use strict';

let layer = texel.Layer();
layer.size = texel.size;
layer.position = texel.size.map(v=>v/2);
texel.layers = [layer];

let size = [512, 512];
let f1 = texel.Filter('CIStarShineGenerator', size);
let f2 = texel.Filter('CILenticularHaloGenerator', size);
let f3 = texel.Filter('CIPageCurlTransition', size);

layer.content = f3;

f1.start();
f2.start();
f3.start();

f3.set('inputImage', f1);
f3.set('inputTargetImage', f2);
f3.set('inputExtent', [0, 0].concat(size));
f3.set('inputAngle', 0.3);

let times = [1,0];
texel.onKeyDown = keyCode => { 
    f3.time = texel.Animation(times[0]);
    times.push(times.shift());
};

global.gc();

