package;
import js.JQuery;

enum Maybe<T> {
    Nothing;
    Just(v:T);
}

class U {
    static public var l = function(a:Dynamic):Void{trace(a);};
    static public var l2 = function(a:Dynamic, b:Dynamic):Void{trace(b);};

    static public var notify = function(message:String, id:String = "notification"):Void{
        trace('notify');
        var notifyJQ = new JQuery('#' + id);
        notifyJQ.empty().append(message);
        notifyJQ.fadeToggle(5000);
//         haxe.Timer.delay(function(){ notifyJQ.fadeToggle(1000); }, 1500);
//         notifyJQ.show(3000);
//         haxe.Timer.delay(function(){ notifyJQ.hide(1000); }, 1500);
    };

    static public var iMaybe = function(defValue:Int , mValue:Maybe<Int>):Int {
        return switch (mValue) {
            case Just(a):
            a;
            case Nothing:
            defValue;
        }
    };
}
