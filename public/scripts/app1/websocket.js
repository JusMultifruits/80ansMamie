var socket;

function connect () {
    setText ("connexion ...");
    socket = new WebSocket (getBaseURL () + "/ws");
    socket.onopen = function () {
	setText ("Connecté, en attente des données ...");	
    }

    socket.onmessage = function (message) {
	writeQuestion (message.data);
    }

    socket.onclose = function () {
	//setText ("Fin de connexion");
    }

    socket.onerror = function () {
	connect ();
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
    var question = JSON.parse (message);
    document.getElementById ("Question").innerHTML = question.name;
    for (var i = 0 ; i < question.answers.length ; i++) {
	writeNewAnswer (question.answers [i], i, question.id);
    }
    reloadRadios ();
}

function sendServer (i, deter) {
    var xhttp = new XMLHttpRequest ();
    xhttp.open ("GET", "answer?id=" + deter + "&ans=" + i, true);
    xhttp.send ();
}

function writeNewAnswer (answer, i, deter) {
    $("#Answers").append ('<div class="col-xs-12 col-sm-12 col-md-6 col-lg-6"> \
                              <div class="product-chooser-item" onclick="sendServer (' + i + ', ' + deter + ')"> \
                                  <div class="col-12"> \
                                      <div class="card col-12 text-center" style="background-color:' + answer.data + ';"> \
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

