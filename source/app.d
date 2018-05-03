import std.stdio, std.datetime;
import utils.Options, database.Collection;
import web.Application;

import utils.json;


/**
   On peut difficilement faire plus court
*/
void main (string [] args) {
    // Charge le fichier de config
    Options.init (args);

    // Lance l'application
    Application.run ();
}
