module web.Admin;

import vibe.d;
import database.Collection;
import database.Question;
import std.json, std.stdio;

final class AdminController {
    
    void get () {
	render!"admin/index.dt";
    }

    void getIndex () {
	render!"admin/index.dt";
    }

    void getRedir_add_deter () {
	render!"admin/addDeter.dt";
    }

    void getAdd_deter (string quest, string answers) {
	logInfo (quest);
	logInfo (answers);
	auto reps = parseJSON (answers) ["ans"].array;
	foreach (it ; reps)
	    logInfo (it.str);
	
	Determinant deter = Determinant (BsonObjectID.generate (), quest, []);
	foreach (it ; reps) {
	    deter.reponses ~= [ComplexeReponse(it.str, "")];
	}
	Collection.insertDeterminant (deter);
	render!"admin/addDeter.dt";
    }
    
}
