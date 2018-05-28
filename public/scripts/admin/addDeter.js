function addRep () {
    $('#multi').append ('<input class="form-control input-rep" type="text" required="true">');    
}

function sendServer () {
    var reps = [];
    var values = $('input.input-rep');
    for (var i = 0 ; i < values.length ; i++) {
	reps.push (values [i].value);
    }
    console.log (i);
    var xhttp = new XMLHttpRequest ();
    xhttp.open ("GET", "add_deter?quest=" + $('#id') [0].value + "&answers=[" + reps + "]");
    xhttp.send ();
}
