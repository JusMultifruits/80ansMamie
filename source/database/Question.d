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


