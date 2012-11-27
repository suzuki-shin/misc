package;
import WebSql;

class Column {
    var name: String;
//     var type: 
}

class PrimaryKey extends Column {
}

class Table {
    var id: PrimaryKey;

    static public function insert(
        websql:WebSql,
        tx:Tx,
        table:Table,
        ?suc:Tx -> Res -> Void,
        ?err:Tx -> Res -> Void
    ):Void {
        websql.executeSql(
            tx,
            table.insertSql(),
            table.insertParams(),
            if (suc != null) suc else function(tx,res) {},
            if (err != null) err else function(tx,res) {}
        );
    }
    private function insertSql():String {return "";}
    private function insertParams():Array<String> {return [];}

    static public function select( websql:WebSql,
                                   tx:Tx,
                                   query:String,
                                   params:Array<String>,
                                   suc:Tx -> Res -> Void,
                                   ?err:Tx -> Res -> Void
    ):Void {
        websql.executeSql(tx, query, params, suc, if (err != null) err else function(tx,res) {});
    }
    private function selectSql(cond:String):String {return "";}
    private function selectParams():Array<String> {return [];}
}
