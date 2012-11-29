package;

import Util;
import WebSql;
import js.JQuery;

// class Column {
//     var name: String;
// //     var type: 
// }

class Table {
    public var __id: Maybe<Int>;

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

//     static public function fromJSON(cls:Class<Table>, json:Dynamic):Table {
//         var id = if (json.id != null) Just(Std.parseInt(json.id)) else Nothing;

//         trace(json);
//         trace(cls);
//         trace(Type.getInstanceFields(cls));

//         return Type.createInstance(cls, [id, json.name, json.attr, json.is_saved, json.is_active, json.ordernum]);
// //         return new Item(id, json.name, json.attr, json.is_saved, json.is_active, json.ordernum);
//     }

//     static public function getProps(cls:Class<Table>):Array<String> {
//         return Lambda.array(
//             Lambda.filter(
//                 Type.getInstanceFields(cls),
//                 function(s:String){return StringTools.startsWith(s, "__");}));
//     }
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