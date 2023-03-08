
function init() {
    let n = 5;
    let size = texel.size;
    let dx = size[0] / n;
    let dy = size[1] / n;
    let layers = [];

    for (let y = 0; y < n; ++y) {
        for (let x = 0; x < n; ++x) {
            let l = texel.Layer();
            let s = [dx, dy];
            let p = [dx * x + dx / 2, dy * y + dy / 2];
            l.size = s;
            l.position = p;
            layers.push(l);
        }
    }
    texel.layers = layers;
}

init();

texel.onKeyDown = (keyCode, position) => {
    console.log(keyCode, position);
    let layer = texel.layerAt(position);
    if (layer) {
        let r = Math.random();
        let g = Math.random();
        let b = Math.random();
        let color = [r,g,b,1] ;
        layer.color = color;
    }
};

global.gc();

