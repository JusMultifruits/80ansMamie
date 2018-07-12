var socket;

function connect (userId) {
    setText ("connexion ...");
    socket = new WebSocket (getBaseURL () + "/ws");
    socket.onopen = function () {
	setText ("Connecté, en attente des données ...");
	socket.send (userId);
    }

    socket.onmessage = function (message) {
	writeQuestion (message.data);
    }

    socket.onclose = function () {
	//setText ("Fin de connexion");
    }

    socket.onerror = function () {
	connect (userId);
    }
    
}

function closeConnection () {
    socket.close ();
}

function setText (text) {
    document.getElementById ("Question").innerHTML = text;
}

function getBaseURL () {
    var href = window.location.href.substring (7);
    var idx = href.indexOf ("/");
    return "ws://" + href.substring (0, idx);
}

function writeQuestion (message) {
    document.getElementById("Answers").innerHTML = "";
    if (message == "EOF") {
	document.getElementById ("Question").innerHTML = "Merci pour votre participation, vos réponses ont bien été enregistrées";
	document.getElementById ("suivant").style.display = "none";
	$("#Answers").append ('<form action="logout" method="GET"> \
                                  <div class="form-group col-md-12"> \
                                    <input type="submit" class="form-control" value="Déconnexion"/> \
</div> \
</form>');
    } else {
	var question = JSON.parse (message);
	document.getElementById ("Question").innerHTML = question.texte;
	for (var i = 0 ; i < question.reponses.length ; i++) {
	    writeNewAnswer (question.reponses [i], i, question.nb);
	}
	reloadRadios ();
    }
}

function sendServer (i, deter) {
    var xhttp = new XMLHttpRequest ();
    console.log (deter, " ", i);
    xhttp.open ("GET", "answer?id=" + deter + "&ans=" + i, true);
    xhttp.send ();
}

function writeNewAnswer (answer, i, deter) {
    $("#Answers").append ('<div class="col-xs-12 col-sm-12 col-md-6 col-lg-6"> \
                              <div class="product-chooser-item" onclick="sendServer (' + i + ', ' + deter + ')"> \
                                  <div class="col-12"> \
                                      <div class="card col-12 text-center"> \
                                         <div class="card-body"> \
                                           <h5 class="card-title">' + answer.value + '</h5> \
                                         </div> \
                                         <input type="radio" name="product_' + i + '" value="' + i + '" checked=""/> \
                                      </div> \
                                      <div class="clear></div> \
                                 </div> \
                             </div> \
                          </div>');
}

function reloadRadios () {
    $('div.product-chooser').not('.disabled').find('div.product-chooser-item').on('click', function(){	
	$(this).parent().parent().find('div.product-chooser-item').removeClass('selected');
	$(this).addClass('selected');
	$(this).find('input[type="radio"]').prop("checked", true);
    });
}

function security () {
    document.getElementById ("dtp_input2").required = true;
}
