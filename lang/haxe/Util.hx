package;

enum Maybe<T> {
    Nothing;
    Just(v:T);
}

class U {
    static public var l = function(a:Dynamic):Void{trace(a);};
    static public var l2 = function(a:Dynamic, b:Dynamic):Void{trace(b);};
}
