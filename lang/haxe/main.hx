import js.JQuery;
import WebSql;
import Table;
import SampleModel;
import Util;

class Main {
    static function main() {
        var ws = new WebSql("hogesql");
        setUp(ws);

//         new JQuery("button.toggle").click(function(){
//                 new JQuery( "button.toggle" ).toggle();
//                 ws.transaction(function(tx){
//                         Table.select(
//                             ws, tx,
//                             "SELECT * FROM items ORDER BY id DESC", [],
//                             function(tx,res){ tableOfItem(new JQuery("#itemList"), tx, res); });
//                     });});

        insertItemEvent(ws);
        insertRecordEvent(ws);
    }

    static function setUp(ws:WebSql):Void {
        U.notify('setUp...');

        ws.transaction(
            function(tx){
                Item.create(ws, tx);
                Record.create(ws, tx);
                renderItems(ws, tx);
            });
    }

    // #insertItemをクリックしたときに、#itemName、#itemAttrのItemをDBにINSERTする
    // 成功時には#itemNameと#itemAttrのフォームの値をクリアする
    static function insertItemEvent(ws:WebSql):Void {
        var itNameJQ = new JQuery("#itemName");
        var itAttrJQ = new JQuery("#itemAttr");
        new JQuery("#insertItem").click(function(ev){
                if (itNameJQ.attr('value') == '' || itAttrJQ.attr('value') == '') { return; }
                ws.transaction(
                    function(tx){
                        Table.insert(
                            ws, tx,
                            new Item({ id : Nothing,
                                       name : itNameJQ.attr('value'),
                                       attr : itAttrJQ.attr('value'),
                                       is_saved : false,
                                       is_active : true,
                                       ordernum : 0}),
                            function(tx,res){
                                itNameJQ.attr('value','');
                                itAttrJQ.attr('value','');
                                renderItems(ws, tx);
                            },
                            function(tx,res){ U.notify('INSERT ERROR'); }
                        );});});
    }

    // #insertRecordをクリックしたときに、#recordItemId、#recordValueのRecordをDBにINSERTする
    // 成功時には#recordNameと#recordAttrのフォームの値をクリアする
    static function insertRecordEvent(ws:WebSql):Void {
        var recItemIdJQ = new JQuery("#recordItemId");
        var recValueJQ = new JQuery("#recordValue");

        new JQuery("#insertRecord").click(function(ev){
                trace('insertRecord');
                if (recItemIdJQ.attr('value') == '' || recValueJQ.attr('value') == '') { return; }
                ws.transaction(
                    function(tx){
                        Table.insert(
                            ws, tx,
                            new Record({id : Nothing,
                                        item_id : Std.parseInt(recItemIdJQ.attr('value')),
                                        value : Std.parseInt(recValueJQ.attr('value')),
                                        is_active :  true,
                                        is_saved :  false}),
                            function(tx,res){ recItemIdJQ.attr('value',''); recValueJQ.attr('value',''); },
                            function(tx,res){ U.notify('INSERT ERROR'); }
                        );});});
    }

    static function renderItems(ws:WebSql, tx:Tx):Void {
        Table.select(
            ws, tx,
            "SELECT * FROM items WHERE is_active = 1 ORDER BY id", [],
            function(tx,res){ tableOfItem(new JQuery("#itemList"), tx, res); });
    }

    static function ulOfItem(jq:JQuery, tx:Tx, res:Res):Void {
        var itemList:List<Item> = Lambda.map(Util.resToList(res), Item.fromJSON);
        var str = "<ul>";
        for (it in itemList) {
            str += it.getLiTagStr();
        }
        str += "</ul>";
        jq.empty().append(str);
    }

    static function tableOfItem(jq:JQuery, tx:Tx, res:Res):Void {
        var itemList:List<Item> = Lambda.map(Util.resToList(res), Item.fromJSON);
        var str = "<table>";
        for (it in itemList) {
            str += it.getTrTagStr();
        }
        str += "</table>";
        jq.empty().append(str);
    }

//     static function hoge(table:Class<Table>):Void {
//         trace(Type.getClassFields(table));
//         trace(Type.getInstanceFields(table));
//         var i0 = new Item(Nothing, "ioioio", "sec");
//         trace(i0);
//         var a = {name:"898989",attr:"buub"};
//         trace(a);
//         trace(Type.typeof(a));
//         trace(a.name);
//         var i1 = Table.fromJSON(Item, {id:"aa", name:"UGUG"});
//         trace(i1);
//         ws.transaction(function(tx){ Table.insert(ws,tx, i1);});
//         trace(Table.getProps(Item));
//         trace(Table.getProps(Record));
//     }
}
