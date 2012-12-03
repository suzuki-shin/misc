package;

import Util;
import WebSql;
import js.JQuery;

class Table {
    static public function insert( websql:WebSql,
                                   tx:Tx,
                                   obj:Table,
                                   ?suc:Tx -> Res -> Void,
                                   ?err:Tx -> Res -> Void
    ):Void {
        websql.executeSql(
            tx,
            obj.insertSql(),
            obj.insertParams(),
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
}

class Util {
    static public function resToList(res:Res):Array<Dynamic> {
        var list = [];
        for (i in 0...res.rows.length) {
            list.push(res.rows.item(i));
        }
        return list;
    }
}