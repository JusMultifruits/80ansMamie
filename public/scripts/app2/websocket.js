
var _equipe;
var questionEnCours;
var dataSet;

function connect(equipe)
{
    if (equipe == '4') {
	dataSet = [];
	chargerGraphique ("");
    }
    
    setText("connecting...");
    socket = new WebSocket(getBaseURL() + "/ws");
    _equipe = equipe;
    socket.onopen = function() {
	setText("connected. waiting for timer...");
	socket.send(equipe);
    }
    socket.onmessage = function(message) {
	console.log (message + " " + equipe);
	ecrireContenu (message.data, equipe);
    }
    socket.onclose = function() {
	setText("connection closed.");
    }
    socket.onerror = function() {
	setText("Error!");
    }
}

function closeConnection()
{
	socket.close();
	setText("closed.");
}

function setText(text)
{
    //document.getElementById("timer").innerHTML = text;
}

function getBaseURL()
{
	var href = window.location.href.substring(7); // strip "http://"
	var idx = href.indexOf("/");
	return "ws://" + href.substring(0, idx);
}

function ecrireContenu (message, equipe) {
    console.log(_equipe);
    switch(_equipe) {
    case '3' :
 	console.log("case3");
	ecrireListeQuestionsAdmin (message);
	break;
    case '4': 
	console.log("case4");
	var json = JSON.parse (message);
	if (json ['res'] == "vrai") 
	    tracerGraphique (message);
	var red = json ["red"], blue = json ["blue"];
	document.getElementById ("score-rouge").innerHTML = red;
	document.getElementById ("score-bleue").innerHTML = blue;	
	break;
    default:
	console.log("default"); 
	writeQuestion (message);
	break;
    }
}

function ecrireListeQuestionsAdmin (message) {
    document.getElementById ("Question").innerHTML = '<div class="container>\
<div class="row">\
<form action="resultats" class="col-md" method="get">\
<input class="form-control btn-info" type="submit" value="Resultats"></form>\
<div class="row">\
<label for="fausseRep10">Rep1 Rouge</label><input type="text" name="rep10" value="0" id="fausseRep10">\
<label for="fausseRep20">Rep2 Rouge</label><input type="text" name="rep20" value="0" id="fausseRep20">\
<label for="fausseRep30">Rep3 Rouge</label><input type="text" name="rep30" value="0" id="fausseRep30">\
<label for="fausseRep40">Rep4 Rouge</label><input type="text" name="rep40" value="0" id="fausseRep40">\
</div>\
<div class="row">\
<label for="fausseRep11">Rep1 Bleue</label><input type="text" name="rep11" value="0" id="fausseRep11">\
<label for="fausseRep21">Rep2 Bleue</label><input type="text" name="rep21" value="0" id="fausseRep21">\
<label for="fausseRep31">Rep3 Bleue</label><input type="text" name="rep31" value="0" id="fausseRep31">\
<label for="fausseRep41">Rep4 Bleue</label><input type="text" name="rep41" value="0" id="fausseRep41"></div>\
<button type="submit" class="btn btn-danger" onclick="envoyerFaussesReponses()">Envoyer les fausses réponses </button></div>\
<div class="row">\
\
<label for="score_rouge">Score rouge</label><input type="text" name="score_rouge" value="0" id="score_rouge">\
<label for="score_bleue">Score bleue</label><input type="text" name="score_bleue" value="0" id="score_bleue">\
<button type="submit" class="btn btn-danger" onclick="envoyerScore()">Envoyer les scores </button>\</div>';
    document.getElementById ("contenu").innerHTML = "";
    var listeQuestions = JSON.parse (message);
    var i = 0;
    $("#contenu").append ('<div class="row"><button type="button" class="btn btn-danger" onclick="sortirDuJeu()"> Sortir de la boucle Admin </button></div>');
    $("#contenu").append ('<input type="radio" id="1" name="Team" value="T1"><label for="choix1">Equipe Bleue</label> <input type="radio" id="0" name="Team" value="T2"><label for="choix2">Equipe Rouge</label> <input type="radio" id="2" name="Team" value="T3" checked><label for="choix3">Les Deux</label>');
    for (quest of listeQuestions) {
	$("#contenu").append('<div class="row"> <h2> ',quest.texte,'  </h2>  <button class="btn btn-success" onclick="envoyerQuestion('+i+')"><span class="glyphicon glyphicon-envelope"></span></button><div class="row"><ul>');
	for (rep of quest.reponses) {
	    $("#contenu").append('<li> '+rep.texte+' : '+rep.valid+' - '+rep.equipe+'</li>');
	}
	$("#contenu").append('</ul></div>');
	i++;
    }
}

function envoyerScore () {
    var red = document.getElementById ('score_rouge').value;
    var blue = document.getElementById ('score_bleue').value;
    var xhttp = new XMLHttpRequest ();
    xhttp.open ("GET", "score?red=" + red + "&blue=" + blue, true);
    xhttp.send ();
}

function envoyerFaussesReponses () {
    var faussesRepRouge = [];
    var faussesRepBleue = [];
    faussesRepRouge.push (document.getElementById('fausseRep10').value);
    faussesRepRouge.push (document.getElementById('fausseRep20').value);
    faussesRepRouge.push (document.getElementById('fausseRep30').value);
    faussesRepRouge.push (document.getElementById('fausseRep40').value);
    console.log(faussesRepRouge);

    faussesRepBleue.push (document.getElementById('fausseRep11').value);
    faussesRepBleue.push (document.getElementById('fausseRep21').value);
    faussesRepBleue.push (document.getElementById('fausseRep31').value);
    faussesRepBleue.push (document.getElementById('fausseRep41').value);
    console.log(faussesRepBleue);
    
    var faussesRepJson = '{"faussesRepRouge" : ['+faussesRepRouge+'],"faussesRepBleue":['+faussesRepBleue+']}';
    console.log(faussesRepJson);
    var xhttp = new XMLHttpRequest ();
    console.log("faux_votes?fake="+faussesRepJson);

    xhttp.open ("GET", "faux_votes?fake="+faussesRepJson,true);
    xhttp.send ();
}

function envoyerQuestion (i) {
    console.log('envoyerQuest');
    var t = $('input[name="Team"]:checked').attr("id");
    console.log('t');
    var msg = '{"quest":'+i+',"team":'+t+'}';
    console.log ('msg');
    console.log (msg);
    socket.send (msg);
    console.log ('sent');
}

function sortirDuJeu () {
    socket.send ("Fin");
}

function writeQuestion (message) {
    document.getElementById ("Question").innerHTML = "";
    document.getElementById ("contenu").innerHTML = "";
    if (message == "NoQuest") {
	document.getElementById ("contenu").innerHTML = "Veuillez patienter";
    } else {
	var question = JSON.parse (message);	
	console.log (question.texte);
	document.getElementById ("Question").innerHTML = question.texte;
	console.log ("la");
	$("#contenu").append ('<div id="Reponses" class="row form-group product-chooser"></div>');
	for (var i = 0; i < question.reponses.length; i ++)  {
	    writeNewAnswer (question.reponses [i], i);
	}
	reloadRadios ();
    }
}

function reloadRadios () {
    $('div.product-chooser').not('.disabled').find('div.product-chooser-item').on('click', function(){	
	$(this).parent().parent().find('div.product-chooser-item').removeClass('selected');
	$(this).addClass('selected');
	$(this).find('input[type="radio"]').prop("checked", true);
    });
}

function writeNewAnswer (answer, i) {
    if((answer.equipe == _equipe) || (answer.equipe == 2))
	$("#Reponses").append ('<div class="col-xs-12 col-sm-12 col-md-6 col-lg-6"> \
                              <div class="product-chooser-item" onclick="sendServer (' + i + ')"> \
                                  <div class="col-12"> \
                                      <div class="card col-12 text-center"> \
                                         <div class="card-body"> \
                                           <h5 class="card-title">' + answer.texte + '</h5> \
                                         </div> \
                                         <input type="radio" name="product_' + i + '" value="' + i + '" checked=""/> \
                                      </div> \
                                      <div class="clear></div> \
                                 </div> \
                             </div> \
                          </div>');
}

function sendServer (i) {
    /*
    var message = '{"rep" : '+i+',"equipe":'+_equipe+'}';
    console.log("avant envoi");
    socket.send (message);
    console.log("après envoi");
    */

    var xhttp = new XMLHttpRequest ();
    xhttp.open ("GET", "reponse_quest_en_cours?i=" + i, true);
    xhttp.send ();
    
}

function tracerGraphique (message) {
    var json = JSON.parse (message);
    var question = json ["question"];
    var reponses = json["reponses"];
    var equipeCiblee = json ["equipeCiblee"];
    
    console.log (question);
    var graph = document.getElementById ("myChart").getContext ('2d');
  //   // console.log ("MaJ");
//     console.log (reponses);
//     // console.log (reponses[0]);
//     // console.log (equipeCiblee);
//     console.log("questions.reponses :" , question.reponses);
// //    if (!(question == questionEnCours)) {
// //	makeLabels (question.reponses);
//     chargerGraphique (question.texte, question, reponses, equipeCiblee);
// 	questionEnCours = question;
// 	console.log ("question modifiée");
//   //  }
//     dataSet.datasets = creerDataSet (reponses, equipeCiblee);
    //     //  window.chart.update ();

    window.chart = new Chart (graph, {
    	type : 'bar',
    	data : {labels :makeLabels (question.reponses),
		datasets : creerDataSet (reponses, equipeCiblee)	    
	       },//dataSet,
    	options: {
	    responsive: true,
    	    scales: {
    		yAxes: [{
    		    ticks : {
    			beginAtZero:true
    		    }
    		}],
		xAxes: [{
		    ticks: {
			fontSize:18
		    }
		}]
    	    },
	    title: {
		display: true,
		text: question.texte,
		fontSize: 25
	    },
	    animation : {
		duration : 0
	    }
	}
	    //	}// ,
	    //  defaults : {
	    //      global : {
	    // 	  animation : {
	    // 	      duration : 0
	    // 	  }
	    //      }
	    //  }
	    
    });
}

function chargerGraphique (titre, question, reponses, equipeCiblee) {
    var graph = document.getElementById ("myChart").getContext ('2d');
    // window.chart = new Chart (graph, {
    // 	type : 'bar',
    // 	data : {labels :makeLabels (question.reponses),
    // 		datasets : creerDataSet (reponses, equipeCiblee)	    
    // 	       },//dataSet,
    // 	options: {
    // 	    responsive: true,
    // 	    scales: {
    // 		yAxes: [{
    // 		    ticks : {
    // 			beginAtZero:true
    // 		    }
    // 		}]
    // 	    },
    // 	    title: {
    // 		display: true,
    // 		text: titre
    // 	    }
    // 	}
    // });
}

function makeLabels (reponsesTexte) {
    var labels = [];
    console.log ("reponsesTexte.length : ", reponsesTexte.length);
    for (var i = 0; i < reponsesTexte.length; i++ )
	labels[i] = reponsesTexte[i].texte;
    return labels;
  //  dataSet.labels = labels;
}

function traitementDesDonnees (reponsesDonnees, equipeCiblee, reponsesTexte) {
 
    donneesAAfficher.datasets = creerDataSet (reponsesDonnees, equipeCiblee);
    
    return donneesAAfficher;
}

function creerDataSet (reponses, equipeCiblee) {
    console.log ("creerDataSet",reponses.length);
    var color = Chart.helpers.color;
    switch(equipeCiblee) {
    case 2:console.log ("double team");
	console.log("reponses",reponses);
	var dataset = [{
	    label:'Equipe Rouge',
	    backgroundColor: 'rgba(255,0,0,0.35)',
	    borderColor:'rgba(255,0,0,0.8)',
	    borderWidth: 1,
	    data : reponses[0]
	},{
	    label:'Equipe Bleue',
	    backgroundColor : 'rgba(0,0,255,0.35)',//blue, // color (window.chartColors.blue).alpha(0.8).rgbString(),
	    borderColor: 'rgba (0,0,255,0.8)',//window.chartColors.blue,
	    borderWidth: 1,
	    data : reponses[1] }];
	break;
    case 0: console.log ("team rouge");
	console.log("reponses, ",reponses[0]);
	var dataset = [{
	    label:'Equipe Rouge',
	    backgroundColor: 'rgba(255,0,0,0.35)',//color(window.chartColors.red).alpha(0.8).rgbString(),
	    borderColor: 'rgba(255,0,0,0.8)',//window.chartColors.red,
	    borderWidth: 1,
	    data: reponses[0]
	}];
	break;
    case 1: console.log("team bleue");
	console.log ("reponses, ",reponses[1]);
	var dataset = [{
	    label:'Equipe Bleue',
	    backgroundColor: 'rgba(0,0,255,0.35)',//color(window.chartColors.blue).alpha(0.8).rgbString(),
	    borderColor: 'rgba(0,0,255,0.8)',//window.chartColors.blue,
	    borderWidth:1,
	    data: reponses[1]
	}];
	break;
    }
    return dataset;
}
