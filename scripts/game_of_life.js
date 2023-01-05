
layer = texel.Layer();
texel.layers = [layer];
layer.size = texel.size;
layer.position = texel.size.map(v=>v/2);
content = texel.GameOfLife([128, 128]);
layer.content = content;

global.gc();

