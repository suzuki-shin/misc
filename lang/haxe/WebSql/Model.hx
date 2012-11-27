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

    static public function insert(websql:WebSql, tx:Tx, table:Table,
                                  ?suc:Tx -> Res -> Void, ?err:Tx -> Res -> Void
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

    static public function select(websql:WebSql, tx:Tx, query:String, params:Array<String>,
                                  suc:Tx -> Res -> Void, ?err:Tx -> Res -> Void
    ):Void {
        websql.executeSql(
            tx,
            query,
            params,
            suc,
            if (err != null) err else function(tx,res) {}
        );
    }
    private function selectSql(cond:String):String {return "";}
    private function selectParams():Array<String> {return [];}
}

// 
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

    static public function create(websql:WebSql, tx:Tx, ?suc:Tx -> Res -> Void, ?err:Tx -> Res -> Void):Void {
        websql.executeSql(
            tx,
            "CREATE TABLE IF NOT EXISTS items (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL, attr TEXT, is_saved INT DEFAULT 0 NOT NULL, ordernum INT DEFAULT 0, is_active INTEGER DEFAULT 1)",
            [],
            if (suc != null) suc else function(tx,res) {},
            if (err != null) err else function(tx,res) {}
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

class Record extends Table {
    var itemId: Int;
    var value: Int;
    var isSaved: Bool;
    var isActive: Bool;

    public function new(itemId:Int, value:Int, isSaved = false, isActive = true):Void {
        this.itemId   = itemId;
        this.value    = value;
        this.isSaved  = isSaved;
        this.isActive = isActive;
    }

    static public function create(websql:WebSql, tx:Tx, ?suc:Tx -> Res -> Void, ?err:Tx -> Res -> Void):Void {
        websql.executeSql(
            tx,
            "CREATE TABLE IF NOT EXISTS records (id INTEGER PRIMARY KEY AUTOINCREMENT, itemId INTEGER NOT NULL, value INTEGER NOT NULL, is_saved INT DEFAULT 0 NOT NULL, is_active INTEGER DEFAULT 1)",
            [],
            if (suc != null) suc else function(tx,res) {},
            if (err != null) err else function(tx,res) {}
        );
    }

    override function insertSql():String {
        return "INSERT INTO records (itemId, value) VALUES (?, ?)";
    }
    override function insertParams():Array<String> {
        return [Std.string(this.itemId), Std.string(this.value)];
    }

    override function selectSql(cond:String):String {
        return "SELECT * FROM records WHERE " + cond;
    }
}
