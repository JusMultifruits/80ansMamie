module web.Phase2;

import vibe.d;
import database.Collection;
import database.Question;
import database.Utilisateur;
import utils.Singleton;
import std.concurrency;
import std.stdio;
import std.json;

final class GerantDuJeu {
    mixin ThreadSafeSingleton;
    private int[Tid] tableauTIdEquipe;
    private Question questionEnCours;
    private bool questionDisponible;
    private int equipeVisee;
    
    this () {
	this.questionDisponible = false;
	this.equipeVisee = 2;
    }

    void ajouter (Tid tId, int equipe) {
	this.tableauTIdEquipe[tId] = equipe;
	foreach (key,value; this.tableauTIdEquipe)
	    writeln (key, " | ", value, "||");
    }

    void supprimer (Tid tId) {
	this.tableauTIdEquipe.remove (tId);
	foreach (key, value; this.tableauTIdEquipe)
	    writeln (key, " | ", value, "||");
    }

    bool getEtat () {
	return this.questionDisponible;
    }

    int getEquipeVisee () {
	return this.equipeVisee;
    }

    void fixerQuestionEnCours (Question question) {
	this.questionEnCours = question;
	writeln ("Question fixée");
	writeln (this.questionEnCours);
    }

    void changerEtat () {
	this.questionDisponible = !this.questionDisponible;
    }

    void sendNotif () {
	foreach (tId, team ; this.tableauTIdEquipe)
	    std.concurrency.send (tId, true);
       
    }

    Question getQuestionEnCours () {
	return this.questionEnCours;
    }

    void traiterReponses (long nbRep, long equipe) {
	writeln (nbRep, " ", equipe);
    }

    void fixerQuestionEtEquipe (Question quest, int team) {
	this.fixerQuestionEnCours (quest);
	this.equipeVisee = team;
    }
}


void phase2WebHandler (scope WebSocket socket) {
    int counter = 0;
    logInfo ("Got new web connection");
    int equipe = socket.receiveText.to!int;
    writeln (equipe);
    GerantDuJeu.instance.ajouter (thisTid, equipe);
    while (true) {
	if (!socket.connected) break;
	/*  counter ++;
	  socket.send (counter.to!string);
	*/
	if (equipe == 3) {
	    gererInterfaceAdmin (socket); // On décompose
	} else {
	    gererInterfaceJoueur (socket, equipe);
	}
    }
    logInfo ("Client is out");
    GerantDuJeu.instance.supprimer (thisTid);  
}

void gererInterfaceAdmin (WebSocket socket) {
    auto questions = Collection.allQuestions ();
    auto questJson = questions.serializeToJson ();
    socket.send (questJson.toString ());

    bool fini = false;
    while (!fini) {
	auto msg = socket.receiveText;
	if (msg == "Fin")
	    fini = true;
	else {
	    logInfo ("avant quest");
	    int quest = parseJSON(msg)["quest"].integer.to!int;
	    logInfo ("quest");
	    int team = parseJSON(msg)["team"].integer.to!int;
	    logInfo("team");
	    auto question = Collection.allQuestions () [quest];
	    GerantDuJeu.instance.fixerQuestionEtEquipe (question, team);
	    GerantDuJeu.instance.sendNotif ();
	}
    }
}    

void gererInterfaceJoueur (WebSocket socket, int equipeDuJoueur) {
    bool aRepondu = false;
    bool envoye = false;
    socket.send ("NoQuest");
    receiveOnly!bool ();
    // On a reçu un ping, on peut se mettre à jour
    
    auto quest = GerantDuJeu.instance.getQuestionEnCours ();
    auto questionJson = quest.serializeToJson ();

    if ((GerantDuJeu.instance.getEquipeVisee () == equipeDuJoueur) || (GerantDuJeu.instance.getEquipeVisee () == 2)) {
	socket.send (questionJson.toString ());
        auto rep = socket.receiveText;
	long reponse = parseJSON(rep)["rep"].integer;
	long equipe = parseJSON(rep)["equipe"].integer;
    
	GerantDuJeu.instance.traiterReponses (reponse, equipe);
    } 
}

final class Phase2Controller {
    private Session _session;

    // request.clientAddress.toAdressString pour avoir l'adresse : http://vibed.org/api/vibe.core.net/NetworkAddress

    void get () {
	if (this.session && this.session.isKeySet ("user")) {
	    auto login = this.session.get!Utilisateur("user");
	    render!("app2/pagePrincipale.dt", login);
	} else {
	    render!"app2/login.dt";
	}
    }

    void getLogin (string nom, Date date) {
	nom = Utilisateur.emphasisName (nom);
	auto login = Collection.findUserById (Utilisateur.computeId (nom, date.month, date.year));
	if (login.isNull) {
	    render!"app2/erreurGetLogin.dt";
	} else {
	    this.logUser (login);
	    render!("app2/pagePrincipale.dt", login);
	}
    }

    void getBegin () {
	if (!this.session || !this.session.isKeySet ("user")) {
	    render!"app2/login.dt";
	} else {
	    auto login = this.session.get!Utilisateur ("user");
	    render!("app2/pagePrincipale.dt", login);
	}
    }

    void getQuestion () {
	if (!this.session || !this.session.isKeySet ("user")) {
	    render!"app2/login.dt";
	} else {
	    auto login = this.session.get!Utilisateur ("user");
	    render!("app2/pagePrincipale.dt", login);
	}
    }


    void getLogout () {
	if (this.session && this.session.isKeySet ("user")) {
	    auto user = Collection.findUserById (this.session.get!Utilisateur ("user").identifiant);
	    user.logged = false;
	    Collection.updateUser (user);
	}
	response.terminateSession ();
	render!"app2/login.dt";
    }

    // void getEnvoyer_question (int id) {
    // 	if (!this.session || !this.session.isKeySet ("user"))
    // 	    render!"app2/login.dt";
    // 	else {
    // 	    auto login = this.session.get!Utilisateur ("user");
    // 	    if (login.equipe == 3) {
    // 		auto question = Collection.allQuestions () [id];
    // 		GerantDuJeu.instance.fixerQuestionEnCours (question);
    // 		GerantDuJeu.instance.changerEtat ();
    // 		writeln (GerantDuJeu.instance.getEtat ());
    // 		sleep (2.seconds);
    // 		GerantDuJeu.instance.changerEtat ();
    // 	    }
    // 	    render!("app2/pagePrincipale.dt", login);
    // 	}
    // }

    void getReponse_quest_en_cours (int i) {
	writeln("getReponseQuestEnCours");
	if (!this.session || ! this.session.isKeySet ("user"))
	    render!"app2/login.dt";
	else {
	    auto login = this.session.get!Utilisateur ("user");
	    writeln ("Appel de traiterReponses ()");
	    GerantDuJeu.instance.traiterReponses (i, login.equipe);
	    render!("app2/pagePrincipale.dt", login);
	}
    }

    private {
	void logUser (Utilisateur user) {
	    if (request.session) response.terminateSession ();
	    auto session = response.startSession ();
	    user.logged = true;
	    Collection.updateUser (user);
	    session.set ("user", user);
	}

	Session session () {
	    return request.session;
	}
    }
}
