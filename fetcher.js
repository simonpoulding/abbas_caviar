var http = require('http');
var https = require('https');
var fs = require('fs');

var output = "";

var accessToken = "BQBPMjz2vpFVEBId9t4yTUK2oPYzw5eh-IKDGxtl1wZMI9x0MFH0q2UF2xIJiiTWv02YKmPvaa3E72nE4iJsn0eS_Fj55gvobT3P4tyKTC3jg7qFvt5UXCqvnCCrYu0hqazHzEjGW9cr6bHhQbMN-WP1_ZFol9DC0oL0NeYiLqTIpgCn2JguhR-kDLRxwetKxxJcLpMVm0I4K1M5Pfr8ux7CbSwTnzczA-cYjN3XNKaGGgcStkeGKqm0mHKCoCZFUdfUstsXi0vbhrxh7HNgGrRYbSUdqpNQXM48ZQfRXXaXClfixlbjfiiPmPGqdvsFpXxfCK8EpHVkaubIJb-qZaoekw";

var spotifyHost = 'api.spotify.com';
var years = ['2014','2015','2016','2017'];
var playlists = {
    '2017': 'users/eurovision14/playlists/0okqnc7i5nzYoj8MHMnRn1',
    '2016': 'users/eurovision14/playlists/5O57Wl25vUmqMUaO0Hgxbz',
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
    console.log(requestsSent +" requests sent (" +years[yearsIndex]+ ")")
    waitForResponses(100, ()=>{
        //console.log("sent: " + requestsSent + ", recv: " + requestsReceived);
        return requestsReceived >= requestsSent;
    }, ()=>{
        if (yearsIndex == years.length-1) {
            console.log("got all audio feature responses");
            writeOutput(JSON.stringify(playlistsProcessed, null, '\t'), 'playlistsTreatedWithAudioFeatures');
        } else {
            console.log(requestsReceived + "requests received(" +years[yearsIndex]+ ")")
            setTimeout(()=>{getAudioFeaturesRec(yearsIndex+1)},5000);
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