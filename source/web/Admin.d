module web.Admin;

import vibe.d;
import database.Collection;
import database.Question;

final class AdminController {
    
    void get () {
	render!"admin/index.dt";
    }

    void getRedir_add_deter () {
	render!"admin/addDeter.dt";
    }

    void getAdd_deter (string quest, string [] answers) {
	logInfo (quest);
	foreach (it ; answers)
	    logInfo (it);
	
	Determinant deter = Determinant (BsonObjectID.generate (), quest, []);
	foreach (it ; answers) {
	    deter.reponses ~= [ComplexeReponse(it, "")];
	}
	Collection.insertDeterminant (deter);
    }
    
}
