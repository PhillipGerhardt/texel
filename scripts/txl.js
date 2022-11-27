'use strict';

const fs = require('fs');
const path = require('path');
const os = require('os');

const { resolve } = require('path');
const { readdir } = require('fs').promises;

async function getFiles(dir)
{
    const dirents = await readdir(dir, {withFileTypes: true});
    const files   = await Promise.all(dirents.map((dirent) => {
        const res = resolve(dir, dirent.name);
        return dirent.isDirectory() ? getFiles(res) : res;
    }));
    return files.flat();
}

function is_movie(file)
{
    let extensions = [
        '.m4v',
        '.mov', 
        '.mp4', 
        '.mpg',
    ];
    for (let extension of extensions) {
        if (file.endsWith(extension)) {
            return true;
        }
    }
    return false;
}

async function get_movies()
{
    console.log('asd');
    let files = await getFiles(path.join(os.homedir(), 'Movies'));
    files = files.filter(file => {
        return is_movie(file);
    });
    return files;
};

module.exports = {
    get_movies: get_movies,
};

