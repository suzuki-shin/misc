package;

enum Maybe<T> {
    Nothing;
    Just(v:T);
}
function fromJust(m:Maybe<T>):T {
    switch(m){
        case Just a:
            a;
        default:
    }
}

class U {
    static public var l = function(a:Dynamic):Void{trace(a);};
    static public var l2 = function(a:Dynamic, b:Dynamic):Void{trace(b);};
}
