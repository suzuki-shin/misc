package;
import WebSql;
import Table;
import Util;

typedef ItemCols = {
    var id: Maybe<Int>;
    var name: String;
    var attr: String;
    var is_saved: Bool;
    var is_active: Bool;
    var ordernum: Int;
}

class Item extends Table {
    var columns:ItemCols;

    public function new(cols:ItemCols):Void {
        this.columns = cols;
    }

    static public function fromJSON(json:Dynamic):Item {
        var id = if (json.id != null) Just(Std.parseInt(json.id)) else Nothing;
        return new Item({id:id, name:json.name, attr:json.attr, is_saved:json.is_saved, is_active:json.is_active, ordernum:json.ordernum});
    }

    static public function create(websql:WebSql, tx:Tx, ?suc:Tx -> Res -> Void, ?err:Tx -> Res -> Void):Void {
        websql.executeSql(
            tx,
            "CREATE TABLE IF NOT EXISTS items (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL UNIQUE, attr TEXT, is_saved INT DEFAULT 0 NOT NULL, ordernum INT DEFAULT 0, is_active INTEGER DEFAULT 1)",
            [],
            if (suc != null) suc else function(tx,res) {},
            if (err != null) err else function(tx,res) {}
        );
    }

    override function insertSql():String {
        return "INSERT INTO items (name, attr, ordernum) VALUES (?, ?, ?)";
    }
    override function insertParams():Array<String> {
        return [this.columns.name, this.columns.attr, Std.string(this.columns.ordernum)];
    }

    public function getTrTagStr():String {
        return "<tr><td>"+ this.columns.id + "</td><td>" + this.columns.name + "</td><td>" + this.columns.attr + "</td></tr>";
    }

    public function getLiTagStr():String {
        return "<li>["+ this.columns.id + "] " + this.columns.name + ":" + this.columns.attr + "</li>";
    }
}

typedef RecordCols = {
    var id: Maybe<Int>;
    var item_id: Int;
    var value: Int;
    var is_saved: Bool;
    var is_active: Bool;
}

class Record extends Table {
    var columns:RecordCols;

    public function new(cols:RecordCols):Void {
        this.columns = cols;
    }

    static public function create(websql:WebSql, tx:Tx, ?suc:Tx -> Res -> Void, ?err:Tx -> Res -> Void):Void {
        websql.executeSql(
            tx,
            "CREATE TABLE IF NOT EXISTS records (id INTEGER PRIMARY KEY AUTOINCREMENT, item_id INTEGER NOT NULL, value INTEGER NOT NULL, is_saved INT DEFAULT 0 NOT NULL, is_active INTEGER DEFAULT 1)",
            [],
            if (suc != null) suc else function(tx,res) {},
            if (err != null) err else function(tx,res) {}
        );
    }

    override function insertSql():String {
        return "INSERT INTO records (item_id, value) VALUES (?, ?)";
    }
    override function insertParams():Array<String> {
        return [Std.string(this.columns.item_id), Std.string(this.columns.value)];
    }
}
