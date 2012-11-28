package;
import WebSql;
import Table;
import Util;

class Item extends Table {
    public var name: String;
    public var attr: String;
    public var is_saved: Bool;
    public var is_active: Bool;
    public var ordernum: Int;

    public function new(id: Maybe<Int>, name:String, attr:String, is_saved = false, is_active = true, ordernum = 0):Void {
        this.id        = id;
        this.name      = name;
        this.attr      = attr;
        this.is_saved  = is_saved;
        this.is_active = is_active;
        this.ordernum  = ordernum;
    }

    static public function fromObj(obj:Dynamic):Item {
        var id = if (obj.id != null) Just(Std.parseInt(obj.id)) else Nothing;
        return new Item(id, obj.name, obj.attr, obj.is_saved, obj.is_active, obj.ordernum);
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
        return [this.name, this.attr, Std.string(this.ordernum)];
    }

    override function selectSql(cond:String):String {
        return "SELECT * FROM items WHERE " + cond;
    }
}

class Record extends Table {
    public var item_id: Int;
    public var value: Int;
    public var is_saved: Bool;
    public var is_active: Bool;

    public function new(id:Maybe<Int>, item_id:Int, value:Int, is_saved = false, is_active = true):Void {
        this.id        = id;
        this.item_id   = item_id;
        this.value     = value;
        this.is_saved  = is_saved;
        this.is_active = is_active;
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
        return [Std.string(this.item_id), Std.string(this.value)];
    }

    override function selectSql(cond:String):String {
        return "SELECT * FROM records WHERE " + cond;
    }
}
