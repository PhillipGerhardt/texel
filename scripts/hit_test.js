
let a = texel.Layer();
let b = texel.Layer();
a.size = texel.size.map(v=>v/4);
a.position = [texel.size[0]*(1/3), texel.size[1]/2];
b.size = texel.size.map(v=>v/4);
b.position = [texel.size[0]*(2/3), texel.size[1]/2];
texel.layers = [a,b];

let c = texel.Text("0");
let d = texel.Text("0");

a.content = c;
b.content = d;

function inc(text) {
    let i = parseInt(text.text);
    i = i + 1;
    text.text = "" + i;
}

texel.onKeyDown = (keyCode, position) => {
    console.log(keyCode, position);
    let layer = texel.layerAt(position);
    if (layer) {
        if (texel.isSame(layer, a)) {
            inc(c);
        }
        if (texel.isSame(layer, b)) {
            inc(d);
        }
    }
};

global.gc();

