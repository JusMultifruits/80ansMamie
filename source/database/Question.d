module database.Question;

import vibe.d;

/**
   Structure très simple qui peut être stocké dans la base   
 */
struct Question {
    @name ("_id") BsonObjectID id; // le champs sera nommé '_id' dans la base 
    string texte;
    Reponse [] reponses;    
}

struct Reponse {
    string texte;
    bool valid;
}


/**
   Cette structure représente une question spéciale Ces questions ne
   sont posé que dans la première phase. Elle ne sont pas dans la table
   des questions, mais dans la table des determinant
 */
struct Determinant {
    @name ("_id") BsonObjectID id;
    string texte;
    ComplexeReponse [] reponses;    
}


/**
   Une réponse complexe peut avoir tout type de champs, 
   ces champs vont être utilisé différement celon la page web
 */
struct ComplexeReponse {
    string [string] datas;

    string opDispatch (string attr) () const {
	auto it = attr in datas;
	if (it !is null) return *it;
	else return "";
    }

    ref string opDispatch (string attr) () {
	auto it = attr in datas;
	if (it !is null) return *it;
	else return "";
    }

    bool opEquals (const ComplexeReponse other) const {
	return this.datas == other.datas;
    }
}

struct DeterReponse {
    BsonObjectID user;
    BsonObjectID deter;
    uint reponse;
}
