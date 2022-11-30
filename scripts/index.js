'use strict';

const repl = require('net-repl');

global.texel = process._linkedBinding('texel');

var options = {
    prompt: 'texel> ',
    deleteSocketOnStart: true
}
const server = repl.createServer(options).listen('/tmp/texel.repl');

