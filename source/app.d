import std.stdio, std.datetime;
import vibe.d;


final class Room {
    private string [] _messages;
    private shared ManualEvent _msgEvent;
	
    void addMessage (string name, string msg) {
	writeln ("msg : ", msg);
	auto time = Clock.currTime ();
	this._messages ~= name ~ "@" ~ time.toISOExtString () ~ ": " ~ msg;
	this._msgEvent.emit ();
    }

    string[] getMessages () {
	return this._messages;	    
    }

    void waitForMessage (size_t nextMsg) {
	while (this._messages.length <= nextMsg)
	    this._msgEvent.wait ();
    }
	
}


final class WebChat {

    private Room [string] _rooms;
        
    void get () {
	render!"index.dt";
    }

    void getRoom (string id, string name) {
	auto messages = getOrCreate (id).getMessages ();
	render!("room.dt", id, name, messages);
    }

    void postRoom (string id, string name, string message) {
	if (message.length != 0)
	    getOrCreate (id).addMessage (name, message);
	
	redirect ("room?id=" ~ id.urlEncode~"&name="~name.urlEncode);
    }

    private Room getOrCreate (string id) {
	if (auto room = id in this._rooms) {
	    return *room;
	} else {
	    return (this._rooms [id] = new Room ());
	}
    }

    void getWS (string id, string name, scope WebSocket socket) {
	auto room = getOrCreate (id);
	auto writer = runTask (
	    () {
		auto nextMsg = room.getMessages ().length;
		while (socket.connected) {
		    while (nextMsg < room.getMessages ().length) {
			socket.send (room.getMessages[nextMsg++]);
		    }
		    room.waitForMessage (nextMsg);
		} 
	    }
	);

	while (socket.waitForData) {
	    auto message = socket.receiveText ();
	    if (message.length != 0)
		room.addMessage (name, message);
	}
	
	writer.join ();
    }
    
}

void launchChat () {
    auto router = new URLRouter ();
    router.registerWebInterface (new WebChat ());
    router.get ("*", serveStaticFiles("public/"));

    auto settings = new HTTPServerSettings ();
    settings.port = 8080;
    settings.bindAddresses = ["::1", "127.0.0.1"];
    listenHTTP (settings, router);
    logInfo ("Please open http://127.0.0.1:8080 in your browser.");
    runApplication ();
}

void main () {
    launchChat ();
}
