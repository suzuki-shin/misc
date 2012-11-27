function $extend(from, fields) {
	function inherit() {}; inherit.prototype = from; var proto = new inherit();
	for (var name in fields) proto[name] = fields[name];
	return proto;
}
var Main = function() { }
Main.__name__ = true;
Main.main = function() {
	var ws = new WebSql("hogesql");
	ws.transaction(function(tx) {
		Item.create(ws,tx,function(tx1,res) {
			console.log("exex suc");
		});
		var item = new Item("Dash","times");
		Table.insert(ws,tx,item);
		Table.insert(ws,tx,new Item("AAA","bbb"));
		Table.select(ws,tx,"select * from items",[],function(tx1,res) {
			console.log(res.rows.item(0));
		});
	});
}
var Table = function() { }
Table.__name__ = true;
Table.insert = function(websql,tx,table,success,error) {
	websql.executeSql(tx,table.insertSql(),table.insertParams(),success != null?success:function(tx1,res) {
	},error != null?error:function(tx1,res) {
	});
}
Table.select = function(websql,tx,query,params,success,error) {
	websql.executeSql(tx,query,params,success,error != null?error:function(tx1,res) {
	});
}
Table.prototype = {
	selectSql: function(cond) {
		return "";
	}
	,insertParams: function() {
		return [];
	}
	,insertSql: function() {
		return "";
	}
}
var Item = function(name,attr,isSaved,isActive,orderNum) {
	if(orderNum == null) orderNum = 0;
	if(isActive == null) isActive = true;
	if(isSaved == null) isSaved = false;
	this.name = name;
	this.attr = attr;
	this.isSaved = isSaved;
	this.isActive = isActive;
	this.orderNum = orderNum;
};
Item.__name__ = true;
Item.create = function(websql,tx,success,error) {
	websql.executeSql(tx,"CREATE TABLE IF NOT EXISTS items (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL, attr TEXT, is_saved INT DEFAULT 0 NOT NULL, ordernum INT DEFAULT 0, is_active INTEGER DEFAULT 1)",[],success != null?success:function(tx1,res) {
	},error != null?error:function(tx1,res) {
	});
}
Item.__super__ = Table;
Item.prototype = $extend(Table.prototype,{
	selectSql: function(cond) {
		return "SELECT * FROM items WHERE " + cond;
	}
	,insertParams: function() {
		return [this.name,this.attr,Std.string(this.orderNum)];
	}
	,insertSql: function() {
		return "INSERT INTO items (name, attr, ordernum) VALUES (?, ?, ?)";
	}
});
var Std = function() { }
Std.__name__ = true;
Std.string = function(s) {
	return js.Boot.__string_rec(s,"");
}
var Res = function() { }
Res.__name__ = true;
var js = js || {}
js.Boot = function() { }
js.Boot.__name__ = true;
js.Boot.__string_rec = function(o,s) {
	if(o == null) return "null";
	if(s.length >= 5) return "<...>";
	var t = typeof(o);
	if(t == "function" && (o.__name__ || o.__ename__)) t = "object";
	switch(t) {
	case "object":
		if(o instanceof Array) {
			if(o.__enum__) {
				if(o.length == 2) return o[0];
				var str = o[0] + "(";
				s += "\t";
				var _g1 = 2, _g = o.length;
				while(_g1 < _g) {
					var i = _g1++;
					if(i != 2) str += "," + js.Boot.__string_rec(o[i],s); else str += js.Boot.__string_rec(o[i],s);
				}
				return str + ")";
			}
			var l = o.length;
			var i;
			var str = "[";
			s += "\t";
			var _g = 0;
			while(_g < l) {
				var i1 = _g++;
				str += (i1 > 0?",":"") + js.Boot.__string_rec(o[i1],s);
			}
			str += "]";
			return str;
		}
		var tostr;
		try {
			tostr = o.toString;
		} catch( e ) {
			return "???";
		}
		if(tostr != null && tostr != Object.toString) {
			var s2 = o.toString();
			if(s2 != "[object Object]") return s2;
		}
		var k = null;
		var str = "{\n";
		s += "\t";
		var hasp = o.hasOwnProperty != null;
		for( var k in o ) { ;
		if(hasp && !o.hasOwnProperty(k)) {
			continue;
		}
		if(k == "prototype" || k == "__class__" || k == "__super__" || k == "__interfaces__" || k == "__properties__") {
			continue;
		}
		if(str.length != 2) str += ", \n";
		str += s + k + " : " + js.Boot.__string_rec(o[k],s);
		}
		s = s.substring(1);
		str += "\n" + s + "}";
		return str;
	case "function":
		return "<function>";
	case "string":
		return o;
	default:
		return String(o);
	}
}
String.__name__ = true;
Array.__name__ = true;
Main.main();

//@ sourceMappingURL=main.js.map