var yearUpper = 2017;
var yearLower = 2014;
var backendHost = 'http://10.128.173.98:4200/api/';


function renderYearOptions() {
    $('#year-select').append('<option value="-1" style="display: none">-----</option>');
    for (var i=yearLower;i<=yearUpper;i++) {
        $('#year-select').append('<option value="'+i+'">'+i+'</option>');
    }
}

function renderSongTable() {
    $('#score-table-container').hide();
    $('#score-table tbody').empty();
    var header ='<tr><th>Country</th><th>Placement</th><th>Song</th><th>Artist</th> <th>Predicted score</th><th>Actual score</th><th>Difference</th></tr>';
    var requestedYear = $('#year-select').val();
    if (requestedYear != -1) {
        $.ajax({
            url: backendHost+requestedYear
        }).done(function(data){
            $('#score-table tbody').append(header); 
            var rowData = JSON.parse(data);
            console.log(rowData);
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
            $('#score-table-container').slideDown();
        });
    }

    
    
    
    
}



$(document).ready(()=>{
    renderYearOptions();

    $('#go-button').click(event=>{
        //TODO: do some ajax here that fetches table before rendering
        console.log("clicked!")
        renderSongTable();
        
    });
})