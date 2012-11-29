package;
import WebSql;
import Table;
import Util;

class Item extends Table {
    public var __name: String;
    public var __attr: String;
    public var __is_saved: Bool;
    public var __is_active: Bool;
    public var __ordernum: Int;

    public function new(id: Maybe<Int>, name:String, attr:String, is_saved = false, is_active = true, ordernum = 0):Void {
        this.__id        = id;
        this.__name      = name;
        this.__attr      = attr;
        this.__is_saved  = is_saved;
        this.__is_active = is_active;
        this.__ordernum  = ordernum;
    }

    static public function fromJSON(json:Dynamic):Item {
        var id = if (json.id != null) Just(Std.parseInt(json.id)) else Nothing;
        return new Item(id, json.name, json.attr, json.is_saved, json.is_active, json.ordernum);
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
        return [this.__name, this.__attr, Std.string(this.__ordernum)];
    }
}

class Record extends Table {
    public var __item_id: Int;
    public var __value: Int;
    public var __is_saved: Bool;
    public var __is_active: Bool;

    public function new(id:Maybe<Int>, item_id:Int, value:Int, is_saved = false, is_active = true):Void {
        this.__id        = id;
        this.__item_id   = item_id;
        this.__value     = value;
        this.__is_saved  = is_saved;
        this.__is_active = is_active;
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
        return [Std.string(this.__item_id), Std.string(this.__value)];
    }

//     static public function fromJSON(cls:Class<Table>, json:Dynamic):Table {
//         var id = if (json.id != null) Just(Std.parseInt(json.id)) else Nothing;
// //         trace(json);
// //         trace(cls);
// //         trace(Type.getInstanceFields(cls));
//         return Type.createInstance(cls, [id, json.name, json.attr, json.is_saved, json.is_active, json.ordernum]);
//     }
}
