package;
import WebSql;
// class Model {
// }

class Column {
    var name: String;
//     var type: 
}

class PrimaryKey extends Column {
}

class Table {
    var id: PrimaryKey;

    static public function insert(websql:WebSql,
                                  tx:Tx,
                                  table:Table,
                                  ?success:Tx -> Res -> Void,
                                  ?error:Tx -> Res -> Void
    ):Void {
        websql.executeSql(
            tx,
            table.insertSql(),
            table.insertParams(),
            if (success != null) success else function(tx,res) {},
            if (error != null) error else function(tx,res) {}
        );
    }
    private function insertSql():String {return "";}
    private function insertParams():Array<String> {return [];}

    static public function select(websql:WebSql,
                                  tx:Tx,
                                  query:String,
                                  params:Array<String>,
                                  success:Tx -> Res -> Void,
                                  ?error:Tx -> Res -> Void
    ):Void {
        websql.executeSql(
            tx,
            query,
            params,
            success,
            if (error != null) error else function(tx,res) {}
        );
    }
    private function selectSql(cond:String):String {return "";}
    private function selectParams():Array<String> {return [];}
}

class Item extends Table {
    var name: String;
    var attr: String;
    var isSaved: Bool;
    var isActive: Bool;
    var orderNum: Int;

    public function new(name:String, attr:String, isSaved = false, isActive = true, orderNum = 0):Void {
        this.name = name;
        this.attr = attr;
        this.isSaved = isSaved;
        this.isActive = isActive;
        this.orderNum = orderNum;
    }

    static public function create(websql:WebSql,
                                  tx:Tx,
                                  ?success:Tx -> Res -> Void,
                                  ?error:Tx -> Res -> Void
    ):Void {
        websql.executeSql(
            tx,
            "CREATE TABLE IF NOT EXISTS items (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL, attr TEXT, is_saved INT DEFAULT 0 NOT NULL, ordernum INT DEFAULT 0, is_active INTEGER DEFAULT 1)",
            [],
            if (success != null) success else function(tx,res) {},
            if (error != null) error else function(tx,res) {}
        );
    }

    override function insertSql():String {
        return "INSERT INTO items (name, attr, ordernum) VALUES (?, ?, ?)";
    }
    override function insertParams():Array<String> {
        return [this.name, this.attr, Std.string(this.orderNum)];
    }

    override function selectSql(cond:String):String {
        return "SELECT * FROM items WHERE " + cond;
    }
}
