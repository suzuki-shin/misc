package;
extern class WebSql {
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