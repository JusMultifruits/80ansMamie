module database.Collection;

import database.Question;
import vibe.d;
import utils.Singleton;
import utils.Options;
import std.typecons : Nullable;

alias Collection = ICollection.instance;

class ICollection {

    private MongoClient _client;
    private MongoCollection _questions;
    private MongoCollection _utilisateurs;

    private this () {
	if (Options.configFile ["mongoPort"].integer != -1) 
	    this._client = connectMongoDB (Options.configFile ["mongoAddr"].str, cast (ushort) Options.configFile ["mongoPort"].integer);
	else
	    this._client = connectMongoDB (Options.configFile ["mongoAddr"].str);

	this._questions = this._client.getCollection ("anniv.questions");
	this._utilisateurs = this._client.getCollection ("anniv.utilisateurs");
	
    }

    void insertQuestion (string texte, string [] reponse, bool [] valide) {
	Question q = Question (
	    BsonObjectID.generate (),
	    texte, []
	);

	Reponse [] reps = new Reponse [reponse.length];
	foreach (it ; 0 .. reponse.length) {
	    reps [it] = Reponse (
		reponse [it],
		valide [it]
	    );
	}
	q.reponses = reps;
	this._questions.insert (q);
    }

    void updateQuestion (string texte, string [] reponse, bool [] valide) {
	Reponse [] reps = new Reponse [reponse.length];
	foreach (it ; 0 .. reponse.length) {
	    reps [it] = Reponse (
		reponse [it],
		valide [it]
	    );
	}
	this._questions.findAndModify (["texte" : texte], ["reponses" : reps]);	
    }

    void removeQuestion (string texte) {
	Nullable!Question q = this._questions.findOne!Question (["texte" : texte]);
	if (!q.isNull) {
	    this._questions.remove (q);
	}
    }
    
    
    mixin Singleton;
}

