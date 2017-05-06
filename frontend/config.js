var yearUpper = 2017;
var yearLower = 2014;


function renderYearOptions() {
    $('#year-select').append('<option value="" style="display: none">-----</option>');
    for (var i=yearLower;i<=yearUpper;i++) {
        $('#year-select').append('<option value="'+i+'">'+i+'</option>');
    }
}

function renderSongTable() {
    $('#score-entries').empty();
    var header ='<tr><th>Country</th><th>Placement</th><th>Song</th><th>Artist</th> <th>Predicted score</th><th>Actual score</th><th>Difference</th></tr>';
    var row = $('<tr></tr>').appendTo('#score-table tbody');
    var rowData = {
        'country':'Serbia',
        'placement':'2',
        'song':'Fire, Desire',
        'artist':'The Flobberworms',
        'predicted':'149',
        'actual':'138',
        'difference':'+11',
    };
    row.append('<td>'+rowData.country+'</td>');
    row.append('<td>'+rowData.placement+'</td>');
    row.append('<td>'+rowData.song+'</td>');
    row.append('<td>'+rowData.artist+'</td>');
    row.append('<td>'+rowData.predicted+'</td>');
    row.append('<td>'+rowData.actual+'</td>');
    row.append('<td>'+rowData.difference+'</td>');
    setTimeout($('#score-table-container').show(), 500);
}



$(document).ready(()=>{
    renderYearOptions();

    $('#go-button').click(event=>{
        //TODO: do some ajax here that fetches table before rendering
        console.log("clicked!")
        renderSongTable();
        
    });
})