module web.Phase1;

import vibe.d;
import database.Collection;
import database.Utilisateur;
import database.Question;
import std.datetime, std.string;
import std.stdio, std.conv;
import std.typecons, std.json;

void questionWebHandler (scope WebSocket socket) {
    logInfo ("Get new web connection");
    auto userId = socket.receiveText;
    auto user = Collection.findUserById (userId);
    if (!user.isNull) {
	auto nb = Collection.getDeterReponsesFromUserId (user.id);
	auto deter = Collection.allDeterminants ();
	if (nb.length >= deter.length) {
	    socket.send ("EOF"); 
	} else {
	    auto json = deter [nb.length].serializeToJson ();
	    json ["nb"] = nb.length;
	    socket.send (json.toString ());
	}
    }
}

/**
   Le controleur web qui va gérer les questions de la première phase
 */
final class Phase1Controller {

    /**
       La session va servir à stocker les informations de la connexion
       actuelle.
       Par exemple, quel utilisateur est connecté en ce moment.
     */
    private Session _session;
    
    /**
       Première requete HTTP, sans path
       On affiche la page de login
     */
    void get () {
	if (this.session && this.session.isKeySet("user")) {
	    auto login = this.session.get!Utilisateur ("user");
	    render!("app1/welcome.dt", login);
	} else 
	    render!"app1/login.dt";
    }

    /**
       Il est nécessaire que les accès se fasse de manière unique,
       donc on demande la date de naissance (plus simple comme ça)
       Params:
       - nom, le nom de l'utilisateur
       - date, la date de naissance (avec uniquement mois et année)
       Renvoi la page welcome, qui va être le démarrage des questions
     */
    void getLogin (string nom, Date date) {	
	nom = Utilisateur.emphasisName (nom);
	auto login = Collection.findUserById (Utilisateur.computeId (nom, date.month, date.year));
	
	bool isBack = true;
	if (login.isNull) { // C'est un nouvel utilisateur, il faut l'ajouter à la base
	    login = Collection.insertUserUniq (nom, date.month, date.year);
	    isBack = false;
	}

	this.logUser (login);
	
	logInfo ("Connexion de " ~ login.identifiant ~ ":" ~ isBack.to!string);
	// la page welcome demande l'utilisateur et si il est nouveau ou non
	render!("app1/welcome.dt", login);
    }

    void getBegin () {
	if (!this.session || !this.session.isKeySet ("user")) {
	    // Aucun utilisateur n'est connecté, la session à expiré
	    // ou un petit malin à taper directement l'adresse
	    // On redirige
	    render!"app1/login.dt"; 
	} else {
	    auto login = this.session.get!Utilisateur ("user");
	    render!("app1/welcome.dt", login);
	}
    }

    void getQuest () {
	if (!this.session || !this.session.isKeySet ("user")) 
	    render!"app1/login.dt";
	else {
	    auto user = this.session.get!Utilisateur ("user");
	    render!("app1/dynamic.dt", user);	    
	}
    }

    void getLogout () {
	if (this.session && this.session.isKeySet ("user")) {
	    auto user = Collection.findUserById (this.session.get!Utilisateur ("user").identifiant);
	    user.logged = false;
	    Collection.updateUser (user);
	}
	response.terminateSession ();
	render!"app1/login.dt";
    }

    void getAnswer (int id, int ans) {
	if (!this.session || !this.session.isKeySet ("user"))
	    render!"app1/login.dt";
	else {
	    auto user = this.session.get!Utilisateur ("user");
	    logInfo ("ici ", " ", id, " ", ans);
	    auto deter = Collection.allDeterminants () [id];
	    Collection.iorReponseToDeterminer (user, deter, ans);
	    render!("app1/dynamic.dt", user);
	}
    }
    
    private {    
    
	/**
	   On ajoute l'utilisateur dans la session
	   Params : 
	   - user, un utilisateur connecté et présent dans la base de donnée
	*/
	void logUser (Utilisateur user) {
	    if (request.session) response.terminateSession ();
	    auto session = response.startSession ();
	    user.logged = true;
	    Collection.updateUser (user);
	    session.set ("user", user);
	}	

	/**
	   On récupère la session associé à la requetes courante	   
	*/
	Session session () {
	    return request.session;
	}

    }
    
}
