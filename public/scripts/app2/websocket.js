var socket;
var _equipe;
function connect(equipe)
{
    setText("connecting...");
    socket = new WebSocket(getBaseURL() + "/ws");
    _equipe = equipe;
    socket.onopen = function() {
	setText("connected. waiting for timer...");
	socket.send(equipe);
    }
    socket.onmessage = function(message, equipe) {	
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
    if (_equipe == 3) {
    	ecrireListeQuestionsAdmin (message);
    } else {
    	writeQuestion (message);
    }
}

function ecrireListeQuestionsAdmin (message) {
    document.getElementById ("Question").innerHTML = "";
    document.getElementById ("contenu").innerHTML = "";
    var listeQuestions = JSON.parse (message);
    var i = 0;
    $("#contenu").append ('<div class="row"><button type="button" class="btn btn-danger" onclick="sortirDuJeu()"> Sortir de la boucle Admin </button></div>');
    $("#contenu").append ('<input type="radio" id="1" name="Team" value="T1"><label for="choix1">Equipe Bleue</label> <input type="radio" id="0" name="Team" value="T2"><label for="choix2">Equipe Rouge</label> <input type="radio" id="2" name="Team" value="T3" checked><label for="choix3">Les Deux</label>');
    for (quest of listeQuestions) {
	$("#contenu").append('<div class="row"> <h2> ',quest.texte,'  </h2>  <button class="btn btn-success" onclick="envoyerQuestion('+i+')"><span class="glyphicon glyphicon-envelope"></span></button><div class="row"><ul>');
	for (rep of quest.reponses) {
	    $("#contenu").append('<li> '+rep.texte+' : '+rep.valid+' </li>');
	}
	$("#contenu").append('</ul></div>');
	i++;
    }
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
    var message = '{"rep" : '+i+',"equipe":'+_equipe+'}';
    console.log("avant envoi");
    socket.send (message);
    console.log("après envoi");
}
