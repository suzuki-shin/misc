package;
extern class WebSql {
    //
    // wrapping js libs
    //
    public function new(dbname:String):Void;
    public function transaction(callb:Dynamic,
                                errorCallb:Dynamic,
                                successCallb:Dynamic):Void;
    public function executeSql(tx:Dynamic,
                               sql:String,
                               params:Array<String>,
                               successCallb:Dynamic,
                               errorCallb:Dynamic):String;
}

// class Callback {
//     public function new(tx: Dynamic, res:Dynamic):
// }