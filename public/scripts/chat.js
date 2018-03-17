function sendMessage () {
    var msg = document.getElementById ("inputLine");
    socket.send (msg.value);
    msg.value = "";
    return false;
}

function connect (room, name) {
    socket = new WebSocket ("ws://127.0.0.1:8080/ws?id=" + encodeURIComponent (room) + "&name=" + encodeURIComponent (name));

    socket.onmessage = function (msg) {
	var history = document.getElementById ("history");
	var previous = history.textContent.trim ();
	if (previous.length != 0) previous = previous + "\n";
	history.textContent = previous + msg.data;
	history.scrollTop = history.scrollHeight;	
    }

    socket.onclose = function () {
	console.log ("Socket closed - reconnecting ... ");
	connect ();
    }
}

