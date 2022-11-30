'use strict';

const t = process._linkedBinding('texel'); 
delete require.cache[require.resolve('./txl.js')];
const txl = require('./txl.js');
const path = require('path');

function make(files) {
    t.layers = [];
    let layers = t.layers;
    n = Math.ceil(Math.sqrt(files.length));
    let size = t.size;
    let dx = size[0] / n;
    let dy = size[1] / n;

    for (let y = 0; y < n; ++y) {
        for (let x = 0; x < n; ++x) {
            let l = t.Layer();
            let s = [dx, dy];
            let p = [dx * x + dx / 2, dy * y + dy / 2];
            l.draw = false;
            l.size = s;
            l.position = p;
            layers.push(l);
        }
    }
    for (let y = 0; y < n; ++y) {
        for (let x = 0; x < n; ++x) {
            let l = t.Layer();
            let s = [dx, dy];
            let p = [dx * x + dx / 2, dy * y + dy / 2];
            l.draw = false;
            l.size = s.map(v=>v*0.7);
            l.position = p;
            layers.push(l);
            let index = x + y * n;
            console.log(index, s, p);
            if (index < files.length) {
                let f = path.join('/tmp', index + '.png')
                let c = t.Image(f);
                // let f = files[index];
                // let c = t.Movie(f, true, true);
                c.start();
                l.content = c;
            }
        }
    }
    layers[0].draw = true;
    t.layers = layers;
}

t.onKeyDown = (keyCode) => {
    let idx = n * py + px;
    let layers = t.layers;

    if (visible && keyCode != 49) {
        if (keyCode == 123) /* left */ { position -= 0.1; }
        if (keyCode == 124) /* right */ { position += 0.1; }
        if (position > 1) { position = position - 1; }
        if (position < 0) { position = 1 - position; }
        console.log('position', position);
        layers[n*n*2].content.seek(position);
    }

    if (!visible) {
        t.layers[idx].draw = false;
        if (keyCode == 125) /* down */ { py -= 1; }
        if (keyCode == 126) /* up */ { py += 1; }
        if (keyCode == 123) /* left */ { px -= 1; }
        if (keyCode == 124) /* right */ { px += 1; }
        if (py == -1) { py = n -1; }
        if (py == n) { py = 0; }
        if (px == -1) { px = n - 1; }
        if (px == n) { px = 0; }
        idx = n * py + px;
        t.layers[idx].draw = true;
    }

    if (keyCode == 49) /* space */ {
        if (inTransition) { return; }

        if (layers.length > n*n*2) {
            console.log('fadeout');
            inTransition = true;
            layers[n*n*2].contentVolume = t.Animation(0);
            layers[n*n*2].contentColor = t.Animation([0,0,0,0]);
            setTimeout(()=>{
                layers.length = n*n*2;
                t.layers = layers;
                global.gc();
                inTransition = false;
                visible = false;
            }, 1000);
            return;
        }

        if (idx < files.length) {
            console.log('fadein');
            let l = t.Layer();
            layers.push(l);
            l.draw = false;
            l.size = t.size.map(v=>v*0.8)
            l.position = t.size.map(v=>v/2);
            let f = files[idx];
            let c = t.Movie(f, true, false);
            c.start();
            l.content = c;
            layers[n*n*2].contentVolume = 0;
            layers[n*n*2].contentVolume = t.Animation(1);
            layers[n*n*2].contentColor = 0;
            layers[n*n*2].contentColor = t.Animation([1,1,1,1]);
            t.layers = layers;
            inTransition = true;
            visible = true;
            setTimeout(()=>{
                inTransition = false;
            }, 1000);
        }
    }
};

let n = 0;
let px = 0;
let py = 0;
let inTransition = false;
let visible = false;
let position = 0;

let movieDir = path.join(os.homedir(), 'Movies');
let files = txl.get_movies(movieDir);
for (let i = 0; i < files.length; ++i) {
    t.makeThumbnail(files[i], path.join('/tmp', i + '.png'));
}
make(files);

global.gc();

