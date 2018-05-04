module database.Utilisateur;

import vibe.d;
import std.conv;
import std.string, std.algorithm, std.uni : isWhite;

struct Utilisateur {
    @name ("_id") BsonObjectID id;
    string nom;
    string identifiant;
    short mois;
    short annee;
    Reponse [] completed;
    
    /**
       Returns: le nom sous forme poli ^^, jean paul -> Jean Paul
     */
    static string emphasisName (string nom) {
	return nom.strip ()
	    .split (" ")
	    .map!((a) => a.capitalize ())
	    .join (" ");
    }

    /**
       Returns: Le nom sous forme simple, Jean Paul -> jean_paul
     */
    static string simplifyName (string nom) {
	return nom.strip ()
	    .split (" ")
	    .map!(a => a.toLower ())
	    .join ("_");
    }

    /**
       Returns: L'identifiant de l'utilisateur 'nom_mois_annee'
     */
    string computeId () {
	return simplifyName (nom) ~ "_" ~ mois.to!string ~ "_" ~ annee.to!string;
    }

    /**
       Returns: L'identifiant de l'utilisateur 'nom_mois_annee'
    */
    static string computeId (string nom, short mois, short annee) {
	return simplifyName (nom) ~ "_" ~ mois.to!string ~ "_" ~ annee.to!string;
    }

    void answer (Reponse x) {
	this.completed ~= [x];
    }
    
}
