
function make(file) {
    let l = texel.Layer();
    l.clip = true;
    l.draw = false;
    l.contentScaling = 'fill';
    l.contentVerticalAlignment = 'top';
    l.color = 0;
    l.size = [dx, dy];
    l.position = [0, dy]
    if (texel.isImage(file)) {
        l.content = texel.Image(file);
    }
    if (texel.isMovie(file)) {
        l.content = texel.Movie(file, true, true);
        l.content.start();
    }
    return l;
}

function exchange(idx, file) {
    let l = make(file);
    let layers = texel.layers[idx].sublayers;
    let layer = texel.layers[idx];
    layers.push(l);
    while (layers.length > 2) { layers.shift(); }
    texel.layers[idx].sublayers = layers;
    let ad = 2;
    // let af = 'outCubic';
    let af = 'outBounce';
    if (layers.length == 2) {
        layers[0].position = texel.Animation([0, -dy], ad, af);
        layers[1].position = texel.Animation([0, 0], ad, af);
        setTimeout(()=>{
            let layers = texel.layers[idx].sublayers;
            while (layers.length > 1) { layers.shift(); }
            texel.layers[idx].sublayers = layers;
            global.gc();
        }, ad*1000); 
    }
    else {
        layers[0].position = texel.Animation([0, 0], ad, af);
    }
    global.gc();
}

function step() {
    let position = indices[index % indices.length];
    let file = files[index % files.length];
    console.log('position', position, 'file', file);
    exchange(position, file);
    ++index;
}

let movieDir = path.join(os.homedir(), 'Movies');
let movies = texel.contentsOfDirectory(movieDir, true).filter(v=>texel.isMovie(v)).filter(v=>texel.isPlayable(v));
let imageDir = path.join(os.homedir(), 'Pictures');
let images = texel.contentsOfDirectory(imageDir, true).filter(v=>texel.isImage(v));
let files = images.concat(movies)
    .filter(v=>{let as = texel.assetSize(v); return as != undefined && as[0] < 8192 && as[1] < 8192;})

files = texel.shuffle(files);

texel.layers = [];
let m = 2;
let n = 3;
let dx = texel.size[0]/m;
let dy = texel.size[1]/n;
for (let y = 0; y < n; ++y) {
    for (let x = 0; x < m; ++x) {
        let l = texel.Layer();
        l.color = 0;
        l.draw = false;
        l.clip = true;
        l.size = [dx, dy];
        l.position = [x * dx + dx/2, y * dy + dy/2];
        let layers = texel.layers;
        layers.push(l);
        texel.layers = layers;
        let idx = y * m + x;
        let file = files[idx % files.length];
        exchange(idx, file);
    }
}

let indices = Array.from(Array(m*n).keys());
indices = texel.shuffle(indices);
let index = m * n;

texel.onKeyDown = (keyCode) => { step() }; 

global.gc();

