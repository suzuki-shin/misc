import WebSql;
class Main {
    static function main() {
        trace("Hello World !");
        var websql = new WebSql("hogesql");
        websql.transaction(
            function(tx){
                websql.executeSql(tx,
                                  "select * from hoge;", [],
                                  function(tx, res){
                                      trace('exex suc');
                                      trace(res.rows.item(0));
                                  });
            },
            function(tx){trace('tranx err');},
            function(tx){trace('tranx suc');});
//         websql.transaction(
//             function(tx){
//                 websql.executeSql(tx,
//                                   "create table hoge (id int, name string);",
//                                   [],
//                                   trace("exec suc"),
//                                   trace("exec fail"));
//             },
//             function(tx){trace('tranx err');},
//             function(tx){trace('tranx suc');});
    }
}
