import WebSql;
import Table;
import SampleModel;

class Main {
    static function main() {
        var ws = new WebSql("hogesql");
        ws.transaction(
            function(tx){
                Item.create(ws, tx, function(tx, res){ trace('exex suc'); });
                Record.create(ws, tx, function(tx, res){
                    trace('exex suc');
                    Table.insert(ws, tx, new Record(1, 30));
                });
//                 var item = new Item("Dash", "times");
//                 Table.insert(ws, tx, item);
                Table.insert(ws, tx, new Item("AAA", "bbb")); // これもOK
                Table.select(ws, tx, "SELECT * FROM items ORDER BY id DESC", [], function(tx,res){trace(res.rows.item(0));});
            });
    }
}
