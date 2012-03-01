(function() {
  var fullchar2halfchar, global, selectFile;

  global = this;

  global.ftoh = function(str) {
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

  selectFile = function(ev) {
    var file, reader;
    file = ev.target.files[0];
    alert(file.name + ' is selected!');
    reader = new FileReader();
    reader.readAsText(file);
    reader.onload = function(ev) {
      var textData;
      console.log('readeronload');
      textData = reader.result;
      alert(textData);
      alert(global.ftoh(textData));
      console.log(textData.split("\n"));
      $('#download-link').attr('href', "data:application/octet-stream," + encodeURIComponent(global.ftoh(reader.result)));
      return $('#download-link').show();
    };
    return reader.onerror = function(ev) {
      return alert('error');
    };
  };

  /*
  # event
  */

  $(function() {
    return $(document).on('change', '#selectFile', selectFile);
  });

}).call(this);
