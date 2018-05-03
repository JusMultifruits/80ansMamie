module web.login;

import vibe.d;
import database.Collection;
import database.Utilisateur;
import std.datetime, std.string;
import std.stdio, std.conv;

/**
   Le controleur web qui va gérer les questions de la première phase
 */
final class LoginPage {

    /**
       Première requete HTTP, sans path
       On affiche la page de login
     */
    void get () {
	render!"login.dt";
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
	
	logInfo ("Connexion de " ~ login.identifiant ~ ":" ~ isBack.to!string);
	// la page welcome demande l'utilisateur et si il est nouveau ou non
	render!("welcome.dt", login, isBack);
    }
    
}
