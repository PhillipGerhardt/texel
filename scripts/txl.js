'use strict';

const fs = require('fs');
const path = require('path');
const os = require('os');

function get_files(dir)
{
    let files = [];
    let paths = fs.readdirSync(dir).map( f => path.join(dir, f ));
    for (let path of paths) {
        if (fs.lstatSync(path).isDirectory()) {
            files = files.concat(get_files(path));        
        }
    } 
    files = files.concat(paths);
    return files;
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

function get_movies()
{
    let files = get_files(path.join(os.homedir(), 'Movies'));
    files = files.filter(file => {
        return is_movie(file);
    });
    return files;
};

function get_images()
{
    let files = get_files(path.join(os.homedir(), 'Pictures'));
    files = files.filter(file => {
        return is_image(file);
    });
    return files;
};

function get_assets()
{
    let movies = get_movies();
    let images = get_images();
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

// min and max included
function randomIntFromInterval(min, max)
{
    return Math.floor(Math.random() * (max - min + 1) + min)
}

module.exports = {
    get_movies: get_movies,
    get_images: get_images,
    is_movie: is_movie,
    is_image: is_image,
    get_assets: get_assets,
    shuffle: shuffle,
    randomIntFromInterval: randomIntFromInterval,
    get_files: get_files,
};

