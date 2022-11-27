'use strict';

const repl = require('net-repl');

// const server = repl.createServer().listen(1337);
var options = {
    prompt: 'texel> ',
    deleteSocketOnStart: true
}
const server = repl.createServer(options).listen('/tmp/texel.repl');

