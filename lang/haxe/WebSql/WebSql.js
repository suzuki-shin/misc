function WebSql(dbname) {
  this.db = window.openDatabase(dbname, '', dbname, 1048576);
}
WebSql.prototype.transaction = function(callback, errorCallback, successCallback) {
  return this.db.transaction(callback, errorCallback, successCallback);
}
WebSql.prototype.executeSql = function(tx, sql, params, successCallback, errorCallback) {
  return tx.executeSql(sql, params, successCallback, errorCallback);
}