function addRep () {
    $('#multi').append ('<input class="form-control input-rep" type="text" required="true"> <input type="checkbox" class="form-control input-check" ><select class="form-control input-team"><option>Team Rouge</option><option>Team Bleue</option><option selected>Les Deux</option></select><br/>');
}

function sendServer () {
    var reponses = [];
    var quelleReponseJuste = [];
    var quelleEquipe = [];
    var values = $('input.input-rep');
    var reponsesJustes = $('input.input-check');
    var auMoinsUneReponseJuste = false;

    var quellesTeam = $('select.input-team');

 
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
	switch (quellesTeam[i].value) {
	case "Team Rouge": quelleEquipe.push ('"0"');
	    break;
	case "Team Bleue": quelleEquipe.push ('"1"');
	    break;
	default : quelleEquipe.push ('"2"');
	    break;
	}
    }

    if ($('#id')[0].value== "") {
	alert("Question vide");
	return;
    }

    console.log ("quelleTeam",quelleEquipe);


    if (auMoinsUneReponseJuste == false) {
	alert("Aucune bonne réponse n'est donnée");
	return;
    }
    alert(quelleReponseJuste);
    console.log (i);
    var xhttp = new XMLHttpRequest ();
    
    var reps = '{ "reponses" : ['+reponses+']}"';
    var bonnesReps = '{ "bonnesReps" : ['+quelleReponseJuste+']}';
    var equipeVisee = '{ "equipe" : ['+quelleEquipe+']}';
    bonnesReps = encodeURIComponent (bonnesReps);
    console.log ("add_question?quest=" + $('#id')[0].value + "&answers=" +reps +"&bonneReps="+bonnesReps+"&equipe="+equipeVisee);
    xhttp.open ("GET", "add_question?quest=" + $('#id')[0].value + "&answers=" +reps +"&bonneReps="+bonnesReps+"&equipe="+equipeVisee);
    xhttp.send ();
    $('#multi')[0].innerHTML = "";
    $('#id')[0].value = "";
    
}

