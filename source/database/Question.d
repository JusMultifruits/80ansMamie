module database.Question;

import vibe.d;

struct Question {
    @name ("_id") BsonObjectID id;
    string texte;
    Reponse [] reponses;
}

struct Reponse {
    string texte;
    bool valid;
}


