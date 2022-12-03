const t = process._linkedBinding('texel'); 

function make(file) {
    let l = t.Layer();
    l.clip = true;
    l.draw = false;
    l.contentScaling = 'fill';
    l.contentVerticalAlignment = 'top';
    l.color = 0;
    l.size = [dx, dy];
    l.position = [0, dy]
    if (texel.isImage(file)) {
        l.content = t.Image(file);
    }
    if (texel.isMovie(file)) {
        l.content = t.Movie(file, true, true);
        l.content.start();
    }
    return l;
}

function exchange(idx, file) {
    let l = make(file);
    let layers = t.layers[idx].sublayers;
    let layer = t.layers[idx];
    layers.push(l);
    while (layers.length > 2) { layers.shift(); }
    t.layers[idx].sublayers = layers;
    let ad = 2;
    // let af = 'outCubic';
    let af = 'outBounce';
    if (layers.length == 2) {
        layers[0].position = t.Animation([0, -dy], ad, af);
        layers[1].position = t.Animation([0, 0], ad, af);
        setTimeout(()=>{
            let layers = t.layers[idx].sublayers;
            while (layers.length > 1) { layers.shift(); }
            t.layers[idx].sublayers = layers;
            global.gc();
        }, ad*1000); 
    }
    else {
        layers[0].position = t.Animation([0, 0], ad, af);
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
let movies = texel.contentsOfDirectory(movieDir, true).filter(v=>texel.isMovie(v));
let imageDir = path.join(os.homedir(), 'Pictures');
let images = texel.contentsOfDirectory(imageDir, true).filter(v=>texel.isImage(v));
let files = images.concat(movies);
files = files.filter(v=>texel.canReadAsset(v));
files = texel.shuffle(files);
console.log(files);

t.layers = [];
let m = 3;
let n = 3;
let dx = t.size[0]/m;
let dy = t.size[1]/n;
for (let y = 0; y < n; ++y) {
    for (let x = 0; x < m; ++x) {
        let l = t.Layer();
        l.color = 0;
        l.draw = false;
        l.clip = true;
        l.size = [dx, dy];
        l.position = [x * dx + dx/2, y * dy + dy/2];
        let layers = t.layers;
        layers.push(l);
        t.layers = layers;
        let idx = y * m + x;
        let file = files[idx % files.length];
        exchange(idx, file);
    }
}

let indices = Array.from(Array(m*n).keys());
indices = texel.shuffle(indices);
let index = 0;

t.onKeyDown = (keyCode) => { step() }; 

global.gc();

