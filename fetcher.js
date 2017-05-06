var http = require('http');
var https = require('https');
var fs = require('fs');

var output = "";

var accessToken = "BQAyH0W9B-emBetQH8ALodXvx2IwwKxzxp04zhq3M_JKKYcTy6lJ2umlDKvTEqE0iZKJwTI0nL8elik8X4Qx-rZdgFn9T-QT5eE6co3ZI804fUpbELQgaONmVbnzzZOF3b6HVnv8Wu7TxP0gWRSXKNPopCUdH5JOMtITujwF-9JyXqdU79iHLEs3JUgqOuNebdqgzd2sJizSAUh14MUbCu9zhhmS_m6IfHZrgZRtkwX7d41i9XoCw1TV8npEroEGVJmVFfxCmamcZu28KvDVDtZwG3ID8WjEtwMArnpuzf8KkfO5DMg3SbFWzMENIcacmF1MT-Zc03WpQmENwKoRg9FzOg";

var spotifyHost = 'api.spotify.com';
var years = ['2014','2015','2016'];
var playlists = {
    '2017': 'users/eurovision14/playlists/0okqnc7i5nzYoj8MHMnRn1',
    '2016': 'users/eurovision14/playlists/0okqnc7i5nzYoj8MHMnRn1',
    '2015': 'users/eurovision14/playlists/2t0JMyo7A448HCIW5keoTg',
    '2014': 'users/21ksf4arb7o2m45mlxzj4dula/playlists/7KA6Chz2MD5WJaPonm62nb'
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

function getAudioFeaturesRec(yearsIndex) {
    var requestsSent = 0;
    var requestsReceived = 0;
    playlistsProcessed[years[yearsIndex]]['tracks'].forEach(track => {
        console.log(track.id);
        var options = {
            host: spotifyHost,
            path: '/v1/audio-features/'+track.id,
            headers: {
                Authorization: 'Bearer ' + accessToken,
                accept: 'application/json'
            }
        };
        requestsSent++;
        https.get(options, msg => {
            if (msg.statusCode == 200) {
                parseMsg(msg, body => {
                    track['audio-features'] = body;
                    requestsReceived++;
                });
            } else if (msg.statusCode == 401) {
                console.log("api token expired");
            }
        });
    });
    waitForResponses(400, ()=>{
        console.log("sent: " + requestsSent + ", recv: " + requestsReceived);
        return requestsSent >= requestsReceived;
    }, ()=>{
        if (yearsIndex == years.length-1) {
            console.log("got all audio feature responses");
            writeOutput(JSON.stringify(playlistsProcessed, null, '\t'), 'playlistsTreatedWithAudioFeatures');
        } else {
            getAudioFeaturesRec(yearsIndex+1);
        }
    });
    
    
}

function getAudioFeatures() {
    getAudioFeaturesRec(0);
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
    getAudioFeatures();
})
years.forEach(year => { getPlaylistTracks(year); })