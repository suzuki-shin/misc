import WebSql;
import Model;
class Main {
    static function main() {
//         trace("Hello World !");
        var ws = new WebSql("hogesql");
        ws.transaction(
            function(tx){
                Item.create(ws, tx, function(tx, res){ trace('exex suc'); });
                Record.create(ws, tx, function(tx, res){
                        trace('exex suc');
                        Table.insert(ws, tx, new Record(1, 30)); // これもOK
                    });
                var item = new Item("Dash", "times");
                Table.insert(ws, tx, item);
                Table.insert(ws, tx, new Item("AAA", "bbb")); // これもOK
                Table.select(ws, tx, "select * from items", [], function(tx,res){trace(res.rows.item(0));});
            });
    }
}
