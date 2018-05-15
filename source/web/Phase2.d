module web.Phase2;

import vibe.d;
import database.Collection;


void phase2WebHandler (scope WebSocket socket) {
    int counter = 0;
    logInfo ("Got new web connection");
    while (true) {
	sleep (1.seconds);
	if (!socket.connected) break;
	counter ++;
	logInfo ("Send  '%d'.", counter);
	socket.send (counter.to!string);
    }
    logInfo ("Client is out");
}


final class Phase2Controller {

    private Session _session;
    
    void get () {
	render!"app2/waiting.dt";
    }    
        
}
