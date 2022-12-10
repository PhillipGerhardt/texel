
let movieDir = path.join(os.homedir(), 'Movies');
let files = texel.contentsOfDirectory(movieDir, true).filter(v=>texel.isMovie(v)).filter(v=>texel.canReadAsset(v));
files = texel.shuffle(files);
let file = files[0];

l1 = texel.Layer();
l2 = texel.Layer();

texel.layers = [l1, l2];

l1.size = texel.size.map(v=>v);
l1.position = texel.size.map(v=>v/2);
l2.size = l1.size;
l2.position = l1.position;

l1.content = texel.Movie(file, true);

// humanHand, humanBody, face
l2.content = texel.VisionDetector(file, 'face', [512,512]);
l2.color = 0;
l2.contentScaling = 'stretch';

l1.content.start();
l2.content.start();

l2.size = l1.contentSize;

global.gc();

