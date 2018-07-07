function addRep () {
    $('#multi').append ('<input class="form-control input-rep" type="text" required="true"> <input type="checkbox" class="form-control input-check" >');
}

function sendServer () {
    var reponses = [];
    var quelleReponseJuste = [];
    var values = $('input.input-rep');
    var reponsesJustes = $('input.input-check');
    var auMoinsUneReponseJuste = false;
    for (var i = 0; i < values.length; i++) {
	reponses.push ('"'+values[i].value+'"');
	if (reponsesJustes[i].checked) {
	    quelleReponseJuste.push ('"true"');
	} else {
	    quelleReponseJuste.push ('"false"');
	}
	if (values[i].value == "") {
	    alert ("Champ "+ (i+1) + " vide");
	    return;
	}
	if (reponsesJustes[i].checked) {
	    auMoinsUneReponseJuste = true;
	}
    }

    if ($('#id')[0].value== "") {
	alert("Question vide");
	return;
    }

    if (auMoinsUneReponseJuste == false) {
	alert("Aucune bonne réponse n'est donnée");
	return;
    }
    alert(quelleReponseJuste);
    console.log (i);
    var xhttp = new XMLHttpRequest ();
    
    var reps = '{ "reponses" : ['+reponses+']}"';
    var bonnesReps = '{ "bonnesReps" : ['+quelleReponseJuste+']}';
    bonnesReps = encodeURIComponent (bonnesReps);
    console.log ("add_question?quest=" + $('#id')[0].value + "&answers=" +reps +"&bonneReps="+bonnesReps);
    xhttp.open ("GET", "add_question?quest=" + $('#id')[0].value + "&answers=" +reps +"&bonneReps="+bonnesReps);
    xhttp.send ();
    $('#multi')[0].innerHTML = "";
    $('#id')[0].value = "";
    
}

