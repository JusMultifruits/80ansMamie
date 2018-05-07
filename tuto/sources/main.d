auto router = new URLRouter ();
router.registerWebInterface (new MyWebInterface ());

auto settings = new HTTPServerSettings ();
settings.port = cast(short) 8080;
settings.bindAddresses = ["::", "0.0.0.0"]; // Addr any

listenHTTP (settings, router);


class MyWebInterface {

    
    /**
     * Requete GET sans nom, et sans parametres.
     * Appele par defaut lors du listenHTTP
     */
    void get () {
	// Envoi la page index.dt
	render!"index.dt";
    }

}

void postLogin (string nom, string prenom) {
    // On affiche la page bonjour, en lui passant des donnees
    render!("bonjour.dt", nom, prenom);
}

auto client  = connectMongoDB ("127.0.0.1");
auto collection = client.getCollection ("anniv.users");

struct Utilisateur {
    @name ("_id") BsonObjectID id;
    string nom;
    string prenom;    
}

collection.insert (Utilisateur (
    BsonObjectID.generate (), "abidbol", "georges"
));

auto user = collection.findOne!Utilisateur (
    ["nom" : "abidbol"]
);

auto user2 = collection.findOne!Utilisateur (
    // q{} veut dire la meme chose que ""
    q{{"user" : "abidbol", "prenom" : "georges"}}
);


void postLogin (string nom, string prenom) {
    if (request.session) response.terminateSession ();
    auto session = response.startSession ();
    session.set ("user", tuple (nom, prenom));
    render!("bonjour.dt", nom, prenom);
}

void getWho () {
    if (request.session) {
	auto nom = request.session.get ("user") [0];
	auto prenom = request.session.get ("user") [1];
	render!("bonjour.dt", nom, prenom);
    } else render!"index.dt";
}

void getData () {
    if (!request.session) {
	redirect ("login", "sponge", "bob"); // fait un post(login, nom="sponge", prenom="bob") 
    } else {
	// renvoi les donnees
    }
}


auto obj = parseJSON (q{{"name" : "abidbol"}});
writeln (obj ["name"].str);
