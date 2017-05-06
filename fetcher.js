var http = require('http');
var https = require('https');
var fs = require('fs');

var output = "";

var accessToken = "BQAr0xHEJhSYi8Hmvww8-n7KSqA4BYxRaMWzyKaCT0LwGVuWwHEqitUc-4uUP0VA2dmNOFXqUuENNXMwMPzLvKykRzewpVGXN3DLqGjCiZEAZguB6A_ijX3VjgBLicQHA1RPSvVkXiQWWdVk5bqGUi9d0UHYCQ5uOleIB_DjXPSNsmZktPjyDu3DNIddyTMIr9O7Ce_s9Xn3R4uOV8gQh-6xCBMcR1i_e_9y9nY1T0_KWGPnMRBJ88pjTae95mkatfLbVknf4Y_gfS1MkkfMEPRAtwZT1RaUBYrt8w4xd3Kd1l6l0SCOHwJ-UwpBBf3IjGhb2BSFFOnx2Jvl4_QeGet-bg";

var spotifyHost = 'api.spotify.com';
var years = ['2016'];
var playlists = {
    '2017': 'users/eurovision14/playlists/0okqnc7i5nzYoj8MHMnRn1',
    '2016': 'users/eurovision14/playlists/0okqnc7i5nzYoj8MHMnRn1',
    '2015': 'users/eurovision14/playlists/2t0JMyo7A448HCIW5keoTg'
};
var playlistsJSON = {};
var playlistsProcessed = {};


function waitForResponses(interval, condition, callback) {
    setTimeout(() => {
        if (condition()) {
            callback();
        } else {
            waitForResponses(interval, condition, callback);
        }
    }, interval)
}

function writeOutput(data, filename) {
    var filePath = './out/'+(filename==undefined ? 'out' : filename)+'.json';
    fs.open(filePath, 'w', function (err, file) {
        if (err) {
            throw "an error occurred: "+err;
        }

        fs.write(file, data, function(errj) {
            if (errj) {
                throw "an error occurred: "+errj;
            }
            fs.close(file, function(){
                console.log("output file written to " + filePath);
            });
        });
    });
}


function getPlaylistTracks(year) {
    var options = {
        host: spotifyHost,
        path: '/v1/' + playlists[year] + '/tracks',
        headers: {
            Authorization: 'Bearer ' + accessToken,
            accept: 'application/json'
        }
    };
    https.get(options, msg => {
        if (msg.statusCode == 200) {
            parseMsg(msg, body => {
                console.log("got playlist json");
                playlistsJSON[year] = body;
            });
        } else if (msg.statusCode == 401) {
            console.log("api token expired");
        }
    });
}


function parseMsg(msg, callback) {
    var body = "";
    msg.on('data', function(chunk){
        body += chunk;
    });

    msg.on('end', function(){
        var apiResponse = JSON.parse(body);
        callback(apiResponse);
    });
}


function treatPlaylists() {
    treatedPlaylists = {};
    years.forEach(year => {
        console.log(year + ': ');
        var playlist = playlistsJSON[year];
        var tracks = [];
        playlist.items.forEach(item => {
            var artists = [];
            item.track.artists.forEach(artist => {
                artists.push({
                    'name': artist.name,
                    'id': artist.id
                });
            });
            tracks.push({
                'name': item.track.name,
                'artists': artists,
                'id': item.track.id
            });
        });
        treatedPlaylists[year] = {'tracks': tracks};
    });
    return treatedPlaylists;
}

function getAudioFeatures() {
    var requestsSent = 0;
    var requestsReceived = 0;

    
    var options = {
        host: spotifyHost,
        path: '/v1/' + playlists[year] + '/tracks',
        headers: {
            Authorization: 'Bearer ' + accessToken,
            accept: 'application/json'
        }
    };
    https.get(options, msg => {
        if (msg.statusCode == 200) {
            parseMsg(msg, body => {
                console.log("got playlist json");
                playlistsJSON[year] = body;
            });
        } else if (msg.statusCode == 401) {
            console.log("api token expired");
        }
    });
}

//############ main()
console.log("running");

waitForResponses(200, () => {
    return Object.keys(playlistsJSON).length >= 1;
}, () => {
    console.log('got all playlist responses');
    writeOutput(JSON.stringify(playlistsJSON, null, '\t'), 'playlistsUntreated');
    playlistsProcessed = treatPlaylists();
    writeOutput(JSON.stringify(playlistsProcessed, null, '\t'), 'playlistsTreated');
})
years.forEach(year => { getPlaylistTracks(year); })