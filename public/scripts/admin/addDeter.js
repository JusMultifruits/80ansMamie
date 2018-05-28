function addRep () {
    $('#multi').append ('<input class="form-control input-rep" type="text" required="true">');    
}

function sendServer () {
    var ans = [];
    var values = $('input.input-rep');
    for (var i = 0 ; i < values.length ; i++) {
	ans.push ('"' + values [i].value + '"');
	if (values [i].value == "") {
	    alert ("Champ " + (i + 1) + " vide");
	    return;
	}
    }

    if ($('#id') [0].value == "") {
	alert ("Question vide");
	return;
    }

    console.log (i);
    var xhttp = new XMLHttpRequest ();
    
    var reps = '{ "ans" : [' + ans + ']}';
    xhttp.open ("GET", "add_deter?quest=" + $('#id') [0].value + "&answers=" + reps);
    xhttp.send ();
    $('#multi')[0].innerHTML = "";
    $('#id')[0].value = "";
}
