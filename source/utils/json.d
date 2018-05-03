module utils.json;

public import std.json;
import std.string;

/**
   Absolument inutile, mais c'est plus rapide
*/
template json (string T) {
    JSONValue json () {
	return parseJSON (T.replace ("'", "\""));
    }
}
