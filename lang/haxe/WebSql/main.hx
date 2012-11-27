import WebSql;
class Main {
    static function main() {
        trace("Hello World !");
        var websql = new WebSql("hogesql");
        websql.transaction(
            function(tx){
                Item.create(websql, tx, function(tx, res){ trace('exex suc'); }, function(tx, res){ trace('exex err'); });
                Item.insert(websql, tx, 'run', 'minutes', 1, function(tx, res){ trace('exex suc'); }, function(tx, res){ trace('exex err'); });
            },
            function(tx){trace('tranx err');},
            function(tx){trace('tranx suc');});

//         websql.transaction(
//             function(tx){
//                 websql.executeSql(tx,
//                                   "select * from hoge;", [],
//                                   function(tx, res){
//                                       trace('exex suc');
//                                       trace(res.rows.item(0));
//                                   },
//                                   function(tx, res){
//                                       trace('exex suc');
//                                       trace(res.rows.item(0));
//                                   });
//             },
//             function(tx){trace('tranx err');},
//             function(tx){trace('tranx suc');});
    }
}

class Column {
}

class PrimaryKey extends Column {
}

class Table extends WebSql {
    var id: PrimaryKey;
}

class Item extends Table {
    var name: String;
    var attr: String;
    var isSaved: Bool;
    var isActive: Bool;
    var orderNum: Int;

    static public function create(websql:WebSql, tx:Dynamic, success:Dynamic, error:Dynamic):Void {
        websql.executeSql(
            tx,
            "CREATE TABLE IF NOT EXISTS items (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL, attr TEXT, is_saved INT DEFAULT 0 NOT NULL, ordernum INT DEFAULT 0, is_active INTEGER DEFAULT 1)",
            [],
            success,
            error
        );
    }

    static public function insert(websql:WebSql, tx:Dynamic, name:String, attr:String, ordernum:Int, success:Dynamic, error:Dynamic):Void {
        websql.executeSql(
            tx,
            "INSERT INTO items (name, attr, ordernum) VALUES (?, ?, ?)",
            [name, attr, "1"],
//             [name, attr, cast(ordernum, String)],
            success,
            error
        );
    }
}
