import js.JQuery;
import WebSql;
import Table;
import SampleModel;
import Util;

class Main {
    static function main() {
//         var xxx:Maybe<Int> = Just(120);
//         trace(xxx);
//         xxx = Nothing;
//         trace(xxx);

        var ws = new WebSql("hogesql");
        ws.transaction(function(tx){
                Item.create(ws, tx);
                Record.create(ws, tx);
            });
        new JQuery("button.toggle").click(function(){
                new JQuery( "button.toggle" ).toggle();
                ws.transaction(function(tx){
                        Table.select(
                            ws, tx,
                            "SELECT * FROM items ORDER BY id DESC", [],
                            function(tx,res){ulOfItem(new JQuery("#itemList"), tx, res);});
//                         Table.select(ws, tx, "SELECT * FROM items ORDER BY id DESC", [], function(tx,res){trace(res.rows.item(0));});
                    });});

        new JQuery("#insertItem").click(function(ev){
                ws.transaction(function(tx){
                        Table.insert(
                            ws, tx,
                            new Item(Nothing,
                                     new JQuery("#itemName").attr('value'),
                                     new JQuery("#itemAttr").attr('value')));
                    });});

        new JQuery("#insertRecord").click(function(ev){
                trace('insertRecord');
                ws.transaction(function(tx){
//                         Table.insert(ws, tx, new Record(Nothing, 1, 100), U.l2, U.l2);
                        Table.insert(
                            ws, tx,
                            new Record(Nothing,
                                       Std.parseInt(new JQuery("#recordItemId").attr('value')),
                                       Std.parseInt(new JQuery("#recordValue").attr('value'))));
                    });});
    }

//     static function ul(cls:Class<Table>, jq:JQuery, tx:Tx, res:Res):Void {
    static function ulOfItem(jq:JQuery, tx:Tx, res:Res):Void {
        trace(jq);
        var itemList = Lambda.map(Util.resToList(res), Item.fromObj);
        trace(itemList);
        var str = "<ul>";
        for (it in itemList) {
            str += "<li>["+ it.id + "] " + it.name + ":" + it.attr + "</li>";
        }
        str += "</ul>";
        jq.empty().append(str);
    }
}
