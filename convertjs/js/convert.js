(function() {
  var fullchar2halfchar;

  this.ftoh = function(str) {
    var c;
    return ((function() {
      var _i, _len, _results;
      _results = [];
      for (_i = 0, _len = str.length; _i < _len; _i++) {
        c = str[_i];
        _results.push(fullchar2halfchar(c));
      }
      return _results;
    })()).join('');
  };

  fullchar2halfchar = function(char) {
    if (this.table[char] != null) {
      return this.table[char];
    } else {
      return char;
    }
  };

}).call(this);
