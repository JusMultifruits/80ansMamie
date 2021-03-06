module database.Collection;

import database.Question, database.Utilisateur;
import vibe.d;
import utils.Singleton;
import utils.Options;
import std.container, std.array;
import std.typecons : Nullable;

alias Collection = ICollection.instance;

class ICollection {

    private MongoClient _client;
    private MongoCollection _questions;
    private MongoCollection _utilisateurs;
    private MongoCollection _determinant;
    private MongoCollection _reponses;
    
    /**
       Initialise l'accés à la base de données
       Le format du fichier de config doit être le suivant : 
       Example : 
       ----------
       {
           "mongoAddr" : "127.0.0.1",
	   "mongoPort" : -1, // port par défaut
	   "mongoBase" : {
	       "name" : "anniv",
	       "questions" : "questions",
	       "users" : "utilisateurs",
	       "determiners" : "determinant",
	       "reponses" : "reps"
	   }
       }
       ----------
     */
    private this () {
	// si pas de port spécifié on prend celui par défaut
	if (Options.configFile ["mongoPort"].integer != -1) 
	    this._client = connectMongoDB (Options.configFile ["mongoAddr"].str, cast (ushort) Options.configFile ["mongoPort"].integer);
	else
	    this._client = connectMongoDB (Options.configFile ["mongoAddr"].str);

	// On dispose de deux table distincte dans la base de données, questions et utilisateurs
	auto base = Options.configFile ["mongoBase"]["name"].str;
	auto qu = Options.configFile ["mongoBase"]["questions"].str;
	auto us = Options.configFile ["mongoBase"]["users"].str;
	auto deter = Options.configFile ["mongoBase"]["determiners"].str;
	auto reps = Options.configFile ["mongoBase"]["reponses"].str;
	
	// Récupération des tables
	this._questions = this._client.getCollection (base ~ "." ~ qu);
	this._utilisateurs = this._client.getCollection (base ~ "." ~ us);	
	this._determinant = this._client.getCollection (base ~ "." ~ deter);
	this._reponses = this._client.getCollection (base ~ "." ~ reps);
    }

    /**
       Insert une nouvelle question, si la question existe déjà la remplace par la nouvelle
       Params : 
       - texte, le texte de la question 
       - reponse, le texte des réponses possibles
       - valide, un tableau où valide [i] est vrai ssi reponse [i] est une bonne réponse
     */    
    void insertOrReplaceQuestion (string texte, string [] reponse, bool [] valide, int [] equipe) {
	Question q = Question (
	    BsonObjectID.generate (),
	    texte, []
	);
	
	Reponse [] reps = new Reponse [reponse.length];
	foreach (it ; 0 .. reponse.length) {
	    reps [it] = Reponse (
		reponse [it],
		valide [it],
		equipe [it]
	    );
	}
	
	q.reponses = reps;
	Nullable!Question res = this._questions.findOne!(Question) (["texte" : texte]);
	
	if (!res.isNull) {
	    q.id = res.id;
	    this._questions.update (["_id" : res.id], q);
	} else 
	    this._questions.insert (q);
    }

    /**
       Mise à jour d'une question, n'insert rien si la question n'existait pas
       Params: 
       - texte, le texte de la question
       - reponse, le texte des réponses possibles
       - valide, un tableau où valide [i] est vrai ssi reponse [i] est une bonne réponse
     */
    void updateQuestion (string texte, string [] reponse, bool [] valide, int [] equipe) {
	Nullable!Question res = this._questions.findOne!Question (["texte" : texte]);
	Question q;
	if (!res.isNull) q = Question (res.id, texte, []);
	else q = Question (BsonObjectID.generate (), texte, []);
	
	Reponse [] reps = new Reponse [reponse.length];
	foreach (it ; 0 .. reponse.length) {
	    reps [it] = Reponse (
		reponse [it],
		valide [it],
		equipe [it]
	    );
	}

	q.reponses = reps;
	this._questions.findAndModify (["texte" : texte], q);	
    }

    /**
       Mise à jour d'une question à partir de son id, n'insert rien si la question n'existait pas
       Params: 
       - id, l'identifiant de l'ancienne question
       - texte, le texte de la question
       - reponse, le texte des réponses possibles
       - valide, un tableau où valide [i] est vrai ssi reponse [i] est une bonne réponse
     */
    void updateQuestionById (BsonObjectID id, string texte, string [] reponse, bool [] valide, int [] equipe) {
	Nullable!Question res = this._questions.findOne!Question (["_id" : id]);
	Question q = Question (id, texte, []);
	
	Reponse [] reps = new Reponse [reponse.length];
	foreach (it ; 0 .. reponse.length) {
	    reps [it] = Reponse (
		reponse [it],
		valide [it],
		equipe [it]
	    );
	}
	
	q.reponses = reps;
	this._questions.findAndModify (["_id" : id], q);	
    }

    /**
       Retrouve une question en fonction de son texte
       Params : 
       - texte, le texte de la question
       Returns: La question, ou null
     */
    Nullable!Question findQuestion (string texte) {
	auto res = this._questions.find!(Question) (["texte" : texte]);
	if (res.empty) {
	    auto ret = Nullable!Question ();
	    ret.nullify;
	    return ret;
	} else return Nullable!Question (res.front ());
    }

    /**
       Supprime une question de la base de données, ne fais rien si la question n'y était pas
       Params: 
       - texte, le texte de la question
     */
    void removeQuestion (string texte) {
	Nullable!Question q = this._questions.findOne!Question (["texte" : texte]);
	if (!q.isNull) {
	    this._questions.remove (q);
	}
    }


    /**
       Supprime une question de la base de données en fonction de son id, ne fais rien si la question n'y était pas
       Params: 
       - id, l'id de la question
     */
    void removeQuestionById (BsonObjectID id) {
	Nullable!Question q = this._questions.findOne!Question (["_id" : id]);
	if (!q.isNull) {
	    this._questions.remove (q);
	}
    }

    /**
       Returns : l'ensemble des questions
     */
    Question [] allQuestions () {
	auto questions = this._questions.find!Question ();
	Array!Question res;
	foreach (it ; questions.byPair) {
	    res.insert (it [1]);
	}
	return res.array ();
    }
    
    /**
       Insert un nouvel utilisateur, ne modifie pas ceux déjà présents
       Params: 
       - nom, le nom de l'utilisateur
       - mois, le mois de naissance
       - annee, l'annee de naissance
    */
    Utilisateur insertUserUniq (string nom, short mois, short annee) {
	Utilisateur user = Utilisateur (BsonObjectID.generate (), nom, "", mois, annee);
	user.identifiant = user.computeId ();
	this._utilisateurs.insert (user);
	return user;
    }
   
    void updateUser (Utilisateur user) {
	this._utilisateurs.findAndModify (["_id" : user.id], user);
    }

    /**
       Retourne la liste des utilisateurs ayant pour nom `nom`
       Params: 
       - nom, le nom des utilisateurs recherché
     */
    Utilisateur[] findUsers (string nom) {
	auto users = this._questions.find!(Utilisateur) (["nom" : nom]);
	Array!Utilisateur res;
	foreach (it ; users.byPair)
	    res.insert (it [1]);
	return res.array ();
    }

    /**
       Retourne un utilisateur ayant pour identifiant `identifiant`
       Params: 
       - identifiant, l'identifiant de l'utilisateur recherché
       Returns: peut retourner un élement null
     */
    Nullable!Utilisateur findUserById (string identifiant) {
	return this._utilisateurs.findOne!(Utilisateur) (["identifiant" : identifiant]);
    }
    
    /**
       Returns: tout les utilisateurs
     */
    Utilisateur [] allUsers () {
	auto users = this._utilisateurs.find!Utilisateur ();
	Array!Utilisateur res;
	foreach (it ; users.byPair) {
	    res.insert (it [1]);
	}
	return res.array ();
    }

    void insertDeterminant (Determinant deter) {
	this._determinant.insert (deter);
    }
    
    /**
       Returns: tous les determinant
     */
    Determinant [] allDeterminants () {
	auto deters = this._determinant.find!Determinant ();
	Array!Determinant res;
	foreach (it ; deters.byPair)
	    res.insert (it [1]);
	return res.array ();
    }

    void removeDeterminant (BsonObjectID id) {
	this._determinant.remove (["_id" : id]);    
    }
    
    /**
       Insert ou remplace une réponse x, de l'utilisateur u, au déterminant d
       Params: 
       - u, u un utilisateur
       - d, le determinant
       - x, le numéro de la réponse
    */
    void iorReponseToDeterminer (Utilisateur u, Determinant d, uint x) {
	Nullable!DeterReponse res = this._reponses.findOne!(DeterReponse) (["user" : u.id, "deter" : d.id]);
	if (!res.isNull) {
	    res.reponse = x;
	    this._reponses.update (["user" : u.id, "deter" : d.id], res);
	} else
	    this._reponses.insert (DeterReponse (u.id, d.id, x));
    }

    DeterReponse [] getDeterReponsesFromUserId (BsonObjectID id) {
	auto reps = this._reponses.find!DeterReponse (["user" : id]);
	Array!DeterReponse res;
	foreach (it ; reps.byPair)
	    res.insert (it[1]);
	return res.array ();
    }

    
    mixin Singleton;
}

