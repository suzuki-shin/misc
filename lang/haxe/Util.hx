package;
import js.JQuery;

enum Maybe<T> {
    Nothing;
    Just(v:T);
}

class U {
    static public var l = function(a:Dynamic):Void{trace(a);};
    static public var l2 = function(a:Dynamic, b:Dynamic):Void{trace(b);};
    static public var notify = function(message:String):Void{
        trace('notify');
        var notifyJQ = new JQuery("#notification");
        notifyJQ.empty().append(message);
        notifyJQ.show(3000);
        notifyJQ.hide(1500);
    }
}
