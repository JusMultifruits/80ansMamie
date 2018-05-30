module web.Admin;

import vibe.d;
import database.Collection;
import database.Question, database.Utilisateur;
import std.json, std.stdio, std.algorithm.searching;

final class AdminController {
    
    void get () {
	render!"admin/index.dt";
    }

    void getBegin () {
	render!"admin/index.dt";
    }
    
    void getIndex () {
	render!"admin/index.dt";
    }

    void getRedir_add_deter () {
	render!"admin/addDeter.dt";
    }

    void getRedir_list_deter () {
	auto deters = Collection.allDeterminants (); 
	render!("admin/listDeters.dt", deters);
    }

    void getRedir_list_user () {
	auto users = Collection.allUsers ();
	render!("admin/listUser.dt", users);
    }
    
    void getRemove_deter (int id) {
	auto removable = Collection.allDeterminants ();
	if (id < removable.length) {
	    auto deter = removable [id];
	    Collection.removeDeterminant (deter.id);   
	}
	auto deters = Collection.allDeterminants (); 
	render!("admin/listDeters.dt", deters);
    }
    
    void getAdd_deter (string quest, string answers) {
	logInfo (quest);
	logInfo (answers);
	auto reps = parseJSON (answers) ["ans"].array;
	foreach (it ; reps)
	    logInfo (it.str);
	
	Determinant deter = Determinant (BsonObjectID.generate (), quest, []);
	foreach (it ; reps) {
	    deter.reponses ~= [ComplexeReponse(it.str)];
	}
	Collection.insertDeterminant (deter);
	render!"admin/addDeter.dt";
    }

    void getCalc_team () {
	auto users = Collection.allUsers ();
	if (users.length > 1) {
	    auto deters = Collection.allDeterminants ();
	    int [][] distance = new int [][users.length];
	    DeterReponse[][] reponse = new DeterReponse [][users.length];
	
	    foreach (ut ; 0 .. users.length) {
		distance [ut] = new int [users.length];
		reponse [ut] = Collection.getDeterReponsesFromUserId (users [ut].id);
		foreach (ref it ; distance [ut]) it = cast (int) deters.length;
	    }
	
	    foreach (dt ; 0 .. deters.length) { 
		foreach (ut ; 0 .. users.length) {
		    foreach (u2t ; 0 .. users.length) {		    
			if (reponse [ut].length > dt && reponse [u2t].length > dt && ut != u2t)
			    if (reponse [ut][dt].reponse == reponse [u2t][dt].reponse)
				distance [ut][u2t] --;
		    }
		}
	    }

	    auto captains = getCaptains (users, distance);
	    auto teams = getTeam (users, captains, distance);
	    writeln (teams);
	    foreach (it ; 0 .. 2) {
		foreach (tt ; 0 .. teams [it].length) {
		    teams [it][tt].equipe = it;
		    Collection.updateUser (teams [it][tt]);
		}
	    }

	}
	redirect ("/redir_list_user");
    }

    void getChange_team (string id) {
	auto user = Collection.findUserById (id);
	if (!user.isNull) {
	    if (user.equipe != -1) user.equipe = (user.equipe + 1) % 2;
	    Collection.updateUser (user);
	}
	auto users = Collection.allUsers ();
	render!("admin/listUser.dt", users);
    }
    
    private {

	int [2] getCaptains (Utilisateur [] users, int [][] distance) {
	    auto left = -1, right = -1, dist = int.max;
	    foreach (ut ; 0 .. users.length) {
		foreach (u2t ; 0 .. users.length) {
		    if (distance [ut][u2t] < dist) {
			left = cast (int) ut;
			right = cast (int) u2t;
			dist = distance [ut][u2t];
		    }
		}
	    }
	    return [left, right];
	}

	Utilisateur [][2] getTeam (Utilisateur [] users, int [2] captains, int [][] distance) {
	    Utilisateur [][2] teams;
	    int i = 0;
	    teams [0] ~= users [captains [0]];
	    teams [1] ~= users [captains [1]];
	    distance [captains [0]][captains [0]] = -1;
	    distance [captains [0]][captains [1]] = -1;
	    distance [captains [1]][captains [1]] = -1;
	    distance [captains [1]][captains [0]] = -1;
	    
	    while (teams [0].length + teams [1].length != users.length) {
		auto user = distance [captains [i % 2]].maxIndex;
		teams [i % 2] ~= users [user];
		distance [captains [i % 2]][user] = -1;
		distance [captains [(i + 1) % 2]][user] = -1;
		i ++;
	    }
	    return teams;
	}	
    }
    
}
