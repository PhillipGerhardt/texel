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

function is_image(file)
{
    let extensions = ['.jpg', '.jpeg', '.png', '.webp', '.heic'];
    for (let extension of extensions) {
        if (file.endsWith(extension)) {
            return true;
        }
    }
    return false;
}

function is_asset(file)
{
    return is_movie(file) || is_image(file);
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

async function get_images()
{
    console.log('asd');
    let files = await getFiles(path.join(os.homedir(), 'Pictures'));
    files = files.filter(file => {
        return is_image(file);
    });
    return files;
};

async function get_assets()
{
    let movies = await get_movies();
    let images = await get_images();
    let files = movies.concat(images);
    files = files.filter(file => {
        return is_asset(file);
    });
    return files;
};

function shuffle(array)
{
    for (var i = array.length - 1; i > 0; i--) {
        var j = Math.floor(Math.random() * (i + 1));
        var temp = array[i];
        array[i] = array[j];
        array[j] = temp;
    }
}

module.exports = {
    get_movies: get_movies,
    get_images: get_images,
    is_movie: is_movie,
    is_image: is_image,
    get_assets: get_assets,
    shuffle: shuffle,
};

