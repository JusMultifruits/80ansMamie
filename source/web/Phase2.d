module web.Phase2;

import vibe.d;
import database.Collection;
import database.Question;
import database.Utilisateur;
import utils.Singleton;
import std.concurrency;
import std.stdio;
import std.json;

struct QuestEtRep {
    Question question;
    int[][2] reponses;
    int equipeCiblee;
    int red;
    int blue;
    string res;
}

final class GerantDuJeu {
    mixin ThreadSafeSingleton;
    private int[Tid] tableauTIdEquipe;
    private Question questionEnCours;
    private bool questionDisponible;
    private int equipeVisee;
    private int[string][2] reponses; // 2 tableaux de [] cases
    private int[][2] faussesReponses;
    private int[2] score;
    
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

    void creerFauxVotes (int[] fauxVotesRouges, int[] fauxVotesBleus) {
	this.faussesReponses[0] = fauxVotesRouges;
	this.faussesReponses[1] = fauxVotesBleus;
	foreach (tId, team; this.tableauTIdEquipe)
	    if (team == 4)
		std.concurrency.send (tId, true);
    }

    void updateScore (int red, int blue) {
	this.score [0] = red;
	this.score [1] = blue;
	foreach (tId, team; this.tableauTIdEquipe)
	    if (team == 4)
		std.concurrency.send (tId, false);
    }

    void fixerQuestionEnCours (Question question) {
	this.questionEnCours = question;
	writeln ("Question fixée");
	int i = cast (int) this.questionEnCours.reponses.length;
	// foreach (rep; this.questionEnCours.reponses)
	//     i++;
	writeln ("nb réponses", i);	
	this.reponses [0] = null; //new int[string];
	this.reponses [1] = null; //new int[string];
	// for (int j = 0; j < this.reponses.length ; j++)
	//     for (int k = 0; k < this.reponses[].length; k++)
	// 	this.reponses[j][k] = 0;
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

    void traiterReponses (long nbRep, string identifiant, long equipe) {
	writeln ("numero Rép : ", nbRep, ", equipe  :", equipe);
	this.reponses[equipe][identifiant] = cast (int) nbRep;
	writeln ("tableau : ", this.reponses);
	foreach (tId, team; this.tableauTIdEquipe)
	    if (team == 4)
		std.concurrency.send (tId, true);
    }

    int[string][2] recupererReponses () {
	return this.reponses;
    }

    int [2] getScore () {
	return this.score;
    }
    
    int[][2] compteReponse () {
	int[][2] reps;
	foreach (team ; 0 .. 2) {
	    reps [team] = new int [this.questionEnCours.reponses.length];
	    foreach (string id, nbRep ; this.reponses [team]) {
		writeln ("id : ", id, " nbRep : ", nbRep, " this.reponses[team]: ", this.reponses[team]);
		reps [team][nbRep] ++;
		writeln ("reps: ", reps);
	    }
	}
	for (int i = 0; i<reps[1].length; i++)
	    for (int j = 0; j<reps.length; j++) {
		reps[j][i] += faussesReponses[j][i];
		writeln( "reps[",j,"][",i,"]:",reps[j][i],"  fausseRep:",faussesReponses[j][i]);
	    }
	return reps;
    }

    void fixerQuestionEtEquipe (Question quest, int team) {
	this.fixerQuestionEnCours (quest);
	this.equipeVisee = team;
	this.faussesReponses = new int[quest.reponses.length];
    }
}


void phase2WebHandler (scope WebSocket socket) {
    int counter = 0;
    logInfo ("Got new web connection");
    int equipe = socket.receiveText.to!int;
    GerantDuJeu.instance.ajouter (thisTid, equipe);
    while (true) {
	if (!socket.connected) break;
	/*  counter ++;
	  socket.send (counter.to!string);
	*/
	switch (equipe) {
	case 3 : gererInterfaceAdmin (socket);
	    break;
	case 4 : gererInterfaceResultats (socket);
	    break;
	default : gererInterfaceJoueur (socket, equipe);
	}
    }
    logInfo ("Client is out");
    GerantDuJeu.instance.supprimer (thisTid);  
}

void gererInterfaceResultats (WebSocket socket) {
    bool res = receiveOnly!bool ();
    
    auto reponses = GerantDuJeu.instance.compteReponse ();
    auto question = GerantDuJeu.instance.getQuestionEnCours ();
    auto equipeCiblee = GerantDuJeu.instance.getEquipeVisee ();
    auto red = GerantDuJeu.instance.getScore () [0];
    auto blue = GerantDuJeu.instance.getScore () [1];
    QuestEtRep contenu = {question, reponses, equipeCiblee, red, blue, res ? "vrai" : "faux"};
    
    socket.send (contenu.serializeToJson ().toString ());
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
	    int quest = parseJSON(msg)["quest"].integer.to!int;
	    int team = parseJSON(msg)["team"].integer.to!int;
	    auto question = Collection.allQuestions () [quest];
	    GerantDuJeu.instance.fixerQuestionEtEquipe (question, team);
	    GerantDuJeu.instance.sendNotif ();
	}
    }
}    

void gererInterfaceJoueur (WebSocket socket, int equipeDuJoueur) {
    bool aRepondu = false;
    bool envoye = false;
    //socket.send ("NoQuest");
    receiveOnly!bool ();
    // On a reçu un ping, on peut se mettre à jour
    writeln ("ici");
    auto quest = GerantDuJeu.instance.getQuestionEnCours ();
    auto questionJson = quest.serializeToJson ();

    if ((GerantDuJeu.instance.getEquipeVisee () == equipeDuJoueur) || (GerantDuJeu.instance.getEquipeVisee () == 2)) {
	if (socket.connected)
	    socket.send (questionJson.toString ());
        /*auto rep = socket.receiveText;
	long reponse = parseJSON(rep)["rep"].integer;
	long equipe = parseJSON(rep)["equipe"].integer;
    
	GerantDuJeu.instance.traiterReponses (reponse, equipe);*/
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

    void getFaux_votes (string fake) {
    	if (!this.session || !this.session.isKeySet ("user")) {
    		render!"app2/login.dt";
    	} else {
	    //GerantDuJeu.instance.creerFauxVotes (faussesRep);
	    auto faussesRepBleues = parseJSON(fake)["faussesRepBleue"].array;
	    auto faussesRepRouges = parseJSON(fake)["faussesRepRouge"].array;

	    int[] fauxBleus;
	    int[] fauxRouges;
	    foreach (it; faussesRepBleues)
		fauxBleus ~= [it.integer.to!int];

	    foreach (it; faussesRepRouges)
		fauxRouges ~= [it.integer.to!int];

	    writeln(fauxRouges);
	    GerantDuJeu.instance.creerFauxVotes (fauxRouges, fauxBleus);

	    auto login = this.session.get!Utilisateur("user");
	    render!("app2/pagePrincipale.dt",login);
    	}
    }

    void getScore (int red, int blue) {
	if (!this.session || !this.session.isKeySet ("user")) {
	    render!"app2/login.dt";
	} else {
	    GerantDuJeu.instance.updateScore (red, blue);
	    auto login = this.session.get!Utilisateur("user");
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
	logInfo ("getReponseQuestEnCours");
	if (!this.session || ! this.session.isKeySet ("user"))
	    render!"app2/login.dt";
	else {
	    auto login = this.session.get!Utilisateur ("user");
	    logInfo ("Appel de traiterReponses ()");
	    GerantDuJeu.instance.traiterReponses (i, login.identifiant, login.equipe);
	    render!("app2/pagePrincipale.dt", login);
	}
    }

    void getResultats () {
	if (!this.session || !this.session.isKeySet ("user"))
	    render!"app2/login.dt";
	else
	    render!"app2/affichageResultats.dt";
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
