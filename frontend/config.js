var yearUpper = 2017;
var yearLower = 2014;


function renderYearOptions() {
    $('#year-select').append('<option value="" style="display: none">-----</option>');
    for (var i=yearLower;i<=yearUpper;i++) {
        $('#year-select').append('<option value="'+i+'">'+i+'</option>');
    }
}

function renderSongTable() {
    $('#score-table tbody').empty();
    var header ='<tr><th>Country</th><th>Placement</th><th>Song</th><th>Artist</th> <th>Predicted score</th><th>Actual score</th><th>Difference</th></tr>';
    $('#score-table tbody').append(header);
    
    
    rowData.forEach(rowEntry => {
        var row = $('<tr></tr>').appendTo('#score-table tbody');
        row.append('<td>'+rowEntry.country+'</td>');
        row.append('<td>'+rowEntry.placement+'</td>');
        row.append('<td>'+rowEntry.song+'</td>');
        row.append('<td>'+rowEntry.artist+'</td>');
        row.append('<td>'+rowEntry.predicted+'</td>');
        row.append('<td>'+rowEntry.actual+'</td>');
        row.append('<td>'+rowEntry.difference+'</td>');
    });
}



$(document).ready(()=>{
    renderYearOptions();

    $('#go-button').click(event=>{
        //TODO: do some ajax here that fetches table before rendering
        console.log("clicked!")
        renderSongTable();
        $('#score-table-container').slideDown();
    });
})