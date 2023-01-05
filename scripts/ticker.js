
layer = texel.Layer();
texel.layers = [layer];
layer.size = [texel.size[0], texel.size[1]/8];
layer.position = texel.size.map(v=>v/2);
msg = "In computer graphics, a texel, texture element, or texture pixel is the fundamental unit of a texture map. ";
speed = 800;
fontSize = 128;
foregroundColor = [1,1,1,1];
backgroundColor = [0.0, 0.5, 0.5, 1];
ticker = texel.Ticker(layer.size, msg, speed, fontSize, foregroundColor, backgroundColor);
layer.content = ticker;
ticker.start();
layer.contentScaling = 'original';

global.gc();

