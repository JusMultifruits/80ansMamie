module utils.Singleton;

/**
 Template Singleton pour permettre la génération simple de classe Singleton
*/
mixin template Singleton (T) {

    /**
     Returns l'intance du singleton.
     */
    static ref T instance () {
	if (inst is null) inst = new T;
	return inst;
    }
    
protected:

    this () {}    
    static T inst = null;
    
}

/**
 Template Singleton pour permettre la génération simple de classe Singleton
*/
mixin template Singleton () {

    alias T = typeof (this);
    
    /**
     Returns l'intance du singleton.
     */
    static ref T instance () {
	if (inst is null) inst = new T;
	return inst;
    }
    
protected:

    this () {}    
    static T inst = null;
    
}

mixin template ThreadSafeSingleton () {
    alias T = typeof (this);

    private this () {}

    /**
       Returns: l'instance du singleton
    **/

    static ref T instance () {
	if (inst is null) {
	    synchronized {
		if (inst is null) {
		    inst = new T;
		}
	    }
	}
	return inst;
    }

private:

    __gshared static T inst = null;
}
