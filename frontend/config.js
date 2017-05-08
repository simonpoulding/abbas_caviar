var yearUpper = 2017;
var yearLower = 2014;
var backendHost = 'http://localhost:4200/api/';
var rowData;


function renderYearOptions() {
    $('#year-select').append('<option value="-1" style="display: none">-----</option>');
    for (var i=yearLower;i<=yearUpper;i++) {
        $('#year-select').append('<option value="'+i+'">'+i+'</option>');
    }
    $('select').material_select();
}

function fetchSongTable() {
    $('#score-table-container').hide();
    var preloader = $('<div class="progress"><div class="indeterminate"></div></div>').appendTo('#score-table-container');
    $('#score-table-container').slideDown();
    $('#score-table tbody').empty();

    var requestedYear = $('#year-select').val();
    if (requestedYear != -1) {
        $.ajax({
            url: backendHost+requestedYear
        }).done(function(data){
            rowData = JSON.parse(data);
            renderSongTable();
            preloader.remove();
        });
    }

}


function renderSongTable() {
    $('#score-table-container').hide();
    $('#score-table tbody').empty();
    var header ='<tr><th>Country</th><th>Placement</th><th>Song</th><th>Artist</th> <th>Predicted score</th><th>Actual score</th><th>Difference</th></tr>';
    $('#score-table tbody').append(header);
    var sortParam = $('#sort-param').val();
    rowData.forEach(rowEntry => {
        rowEntry.predicted = Math.round(rowEntry.predicted);
        rowEntry.placement = Math.round(rowEntry.placement);
        rowEntry.actual = Math.round(rowEntry.actual);
        rowEntry.difference = Math.round(rowEntry.difference);
    });
    console.log(rowData);
    rowData.sort(function (a, b) {
        console.log(a +" : " + b);
        if (isNaN(+a[sortParam]) || isNaN(+b[sortParam])) {
            console.log("NaN!!!");
            var valA = a[sortParam].toUpperCase();
            var valB = b[sortParam].toUpperCase();
            if (valA < valB) {
                return -1;
            }
            if (valA > valB) {
                return 1;
            }
            return 0;
        } else {
            return Math.abs(+a[sortParam]) - Math.abs(+b[sortParam]);
        }
    });

    if ($('#sort-order').val() == "descending") {
        rowData.reverse();
    }

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
}


$(document).ready(function(){
    renderYearOptions();

    $('#go-button').click(function(event){
        //TODO: do some ajax here that fetches table before rendering
        console.log("clicked!")
        fetchSongTable();

    });
})
