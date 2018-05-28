module web.login;

import vibe.d;
import database.Collection;
import database.Utilisateur;
import database.Question;
import std.datetime, std.string;
import std.stdio, std.conv;
import std.typecons, std.json;

void questionWebHandler (scope WebSocket socket) {
    logInfo ("Get new web connection");    
    socket.send (q{
	    {
		"id" : 0,
		    "name" : "Quelle est votre couleur préférée ?",
		    "answers" : [{"data" : "#0000FF", "value" : "bleue"},
				 {"data" : "#00FF00", "value" : "vert"},
				 {"data" : "#FF0000", "value" : "rouge"},
				 {"data" : "#FFFF00", "value" : "jaune"}
		    ]
		    }
	});
}

/**
   Le controleur web qui va gérer les questions de la première phase
 */
final class LoginPage {

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
	    auto deter = this.getCurrentQuestion (user);
	    if (deter [0] == -1) {
		render!"app1/end.dt";
	    } else {
		auto question = deter [1];
		render!("app1/dynamic.dt", question);
	    }
	}
    }

    void getLogout () {
	response.terminateSession ();
	render!"app1/login.dt";
    }

    void getAnswer (int id, int ans) {
	if (!this.session || !this.session.isKeySet ("user"))
	    render!"app1/login.dt";
	else {
	    auto user = this.session.get!Utilisateur ("user");
	    auto deter = Collection.allDeterminants () [id];
	    Collection.iorReponseToDeterminer (user, deter, ans);
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
	    session.set ("user", user);
	}	

	/**
	   On récupère la session associé à la requetes courante	   
	*/
	Session session () {
	    return request.session;
	}
	
	Tuple!(int, Determinant) getCurrentQuestion (Utilisateur user) {
	    /*auto deters = Collection.allDeterminants ();
	    auto nb = Collection.getDeterReponsesFromUserId (user.id);
	    if (nb.length == deters.length) {
		return tuple (-1, Determinant.init);
	    } else {
		return tuple (cast(int) nb.length, deters [nb.length]);
		}*/

	    auto val = Determinant (
		BsonObjectID.generate (),
		"Quelle est ta couleur préféré ?",
		[
		    ComplexeReponse ("bleue", "#0000FF"),
		    ComplexeReponse ("vert", "#00FF00")
		]		
	    );
	    return tuple (0, val);
	}

    }
    
}
