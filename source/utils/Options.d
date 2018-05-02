module utils.Options;
import utils.Singleton;
import std.getopt;
import std.json;
import std.file;

alias Options = IOptions.instance;

class IOptions {

    private JSONValue _configFile;
    private string _configFileName = "default.json";
    
    void init (string [] args) {
	auto res = getopt (args, "config-file", &_configFileName, "cfg", &_configFileName);
	this._configFile = parseJSON (cast (string) std.file.read (this._configFileName));
    }

    JSONValue configFile () {
	return this._configFile;
    }
    
    
    mixin Singleton;
}
