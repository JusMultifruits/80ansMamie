import std.stdio, std.datetime;
import utils.Options, database.Collection;

void main (string [] args) {
    Options.init (args);
    Collection.updateQuestion ("De quelle couleurs est le vert ?",
			       ["bleu", "jaune", "pas compris la question"],
			       [false, false, true]);
}
