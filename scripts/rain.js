
function randomIntFromInterval(min, max) { // min and max included 
    return Math.floor(Math.random() * (max - min + 1) + min)
}

function make() {
    let x = randomIntFromInterval(0, texel.size[0]);
    let dy = randomIntFromInterval(0, 500);
    let y = texel.size[1] + dy;
    let l = texel.Layer();
    l.size = [200,200];
    l.position = [x,y];
    l.contentColor = 0;
    l.draw = false;
    let idx = randomIntFromInterval(0, files.length - 1);
    let file = files[idx];
    l.content = texel.Image(file);
    l.content.start();
    l.position = texel.Animation([x,200], 3, 'outBounce');
    l.contentColor = texel.Animation([1,1,1,1], 1);
    return l;
}

function step() {
    let l = make();
    layers.push(l);
    texel.layers = layers;
    setTimeout(() => {
        l.contentColor = texel.Animation([0,0,0,0], 1);
        setTimeout(() => {
            layers = layers.filter((val)=>{return val != l;});
            texel.layers = layers;
        }, 1000);
    }, 3000);
    global.gc();
}

let imageDir = path.join(os.homedir(), 'Pictures');
let files = texel.contentsOfDirectory(imageDir, true).filter(v=>texel.isImage(v));

texel.layers = [];
let layers = [];

if (global.i) {
    clearInterval(global.i);
}
global.i = setInterval(step, 100);
global.gc();

