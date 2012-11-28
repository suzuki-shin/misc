package;

import Util;
import WebSql;
import js.JQuery;

class Column {
    var name: String;
//     var type: 
}

class Table {
    var id: Maybe<Int>;

//     static public function fromObj(obj:Dynamic):Dynamic {
// //         var id = if (obj.id != null) Just(Std.parseInt(obj.id)) else Nothing;
// //         return new Item(id, obj.name, obj.attr, obj.is_saved, obj.is_active, obj.ordernum);
//     }

    static public function insert( websql:WebSql,
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

class Util {
    static public function resToList(res:Res):Array<Dynamic> {
        var list = [];
        for (i in 0...res.rows.length) {
            list.push(res.rows.item(i));
        }
        return list;
    }

    static public function toUl(ts:Array<Dynamic>):String {
        for (t in ts) {
        }
        return "";
    }
//     static public function resToUl(res:Res):String {
//         var len = res.rows.length();
//         var ulTagStr = "<ul>";
//     }
}