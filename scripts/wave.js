
layer = texel.Layer();
texel.layers = [layer];
layer.size = texel.size;
layer.position = texel.size.map(v=>v/2);
wave = texel.Wave([256,256]);
layer.content = wave;

global.gc();

