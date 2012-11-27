package;
extern class WebSql {
    //
    // wrapping js libs
    //
    public function new(dbname:String):Void;
    public function transaction(callb:Tx -> Void,
                                ?errorCallb:Tx -> Res -> Void,
                                ?successCallb:Tx -> Res -> Void):Void;
    public function executeSql(tx:Tx,
                               sql:String,
                               params:Array<String>,
                               ?successCallb:Tx -> Res -> Void,
                               ?errorCallb:Tx -> Res -> Void):Void;
}

class Tx {} // トランザクションオブジェクト型
class Res {} // レスポンスオブジェクト型