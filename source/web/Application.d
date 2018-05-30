module web.Application;

import utils.Singleton;
import utils.Options;
import web.Phase1;
import web.Phase2;
import web.Admin;
import vibe.d;

alias Application = IApplication.instance;

enum AppType {
    FIRST_PHASE = 1, // première phase de question 
    ADMIN, // Coté administrateur
    COMPETITION, // Deuxième phase, ou on oppose les 2 équipe
    FINAL_GAME // Dernière phase avec les question truqués
}

/**
   Cette classe gêre tout le système d'interface web
   En fonction du contexte demarre un controleur spécifique
*/
final class IApplication {

    URLRouter _router;
    HTTPServerSettings _settings;

    /**
       Charge les informations du fichier de config : 
       Nécessite le format suivant : 
       Example : 
       ----------
       {
           "app" : 1, // AppType
	   "web" : {
	       "port" : 8080,
	       "ipv4" : "0.0.0.0", // AddrAny
	       "ipv6" : "::" // AddrAny
	   }
       }
       ----------
     */
    private this () {
	this._router = new URLRouter ();
	
	// Lancement du controleur adapté à l'application
	final switch (Options.configFile ["app"].integer) {
	case AppType.FIRST_PHASE : {
	    this._router.registerWebInterface (new Phase1Controller ());
	    this._router.get ("/ws", handleWebSockets (&questionWebHandler));
	} break;	    
	case AppType.ADMIN : {
	    this._router.registerWebInterface (new AdminController ());
	} break;
	case AppType.COMPETITION : {
	    this._router.registerWebInterface (new Phase2Controller ());
	    this._router.get ("/ws", handleWebSockets (&phase2WebHandler));
	} break;
	}

	// On définis les dossiers des ressources accéssible depuis l'exterieur (scripts, css ...)	
	this._router.get ("*", serveStaticFiles("public/"));
	
	this._settings = new HTTPServerSettings ();
	this._settings.port = cast (short) Options.configFile ["web"]["port"].integer;


	// On peut spécifier une addresse pour qu'on ne puisse accéder
	// que depuis celle ci, par exemple 127.0.0.1 impose que le
	// service ne soit pas accessible depuis l'exterieur
	// Ce qui est pratique pour la partie ADMIN
	this._settings.bindAddresses = [Options.configFile ["web"]["ipv6"].str,
					Options.configFile ["web"]["ipv4"].str];	
	
	this._settings.errorPageHandler (&this._errorPage);
	this._settings.sessionStore = new MemorySessionStore;
	
	listenHTTP (this._settings, this._router);
	logInfo ("Please open http://" ~ Options.configFile ["web"]["ipv4"].str ~ ":" ~ Options.configFile ["web"]["port"].integer.to!string);
    }

    /**
       Lance l'application
     */
    void run () {
	runEventLoop ();
    }    

    private void _errorPage (HTTPServerRequest req, HTTPServerResponse res, HTTPServerErrorInfo error) {
	logInfo (error.debugMessage);
	switch (error.code) {
	case 404 : res.render!("404.dt"); break;
	case 500 : res.render!("500.dt"); break;
	default : res.render!("500.dt"); break;
	}
    }
    
    mixin Singleton;
}
