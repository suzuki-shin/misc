(function() {
  var fullchar2halfchar, glbal, outPut, selectFile;

  glbal = this;

  glbal.ftoh = function(str) {
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
      var file_name, textData;
      console.log('readeronload');
      textData = reader.result;
      alert(textData);
      alert(glbal.ftoh(textData));
      console.log(textData.split("\n"));
      file_name = (file.name.match(/^(\w+)/))[0];
      file_name || (file_name = 'xxxxx');
      console.log(file_name);
      $('#download-link').attr('href', "data:application/octet-stream," + encodeURIComponent(reader.result));
      return $('#download-link').show();
    };
    return reader.onerror = function(ev) {
      return alert('error');
    };
  };

  outPut = function(ev) {
    var file, reader;
    file = ev.target.files[0];
    alert(file.name + ' is selected!');
    reader = new FileReader();
    reader.readAsText(file);
    return reader.onload = function(ev) {
      return this.attr('href', "data:application/octet-stream," + encodeURIComponent(reader.result));
    };
  };

  /*
  # event
  */

  $(function() {
    $(document).on('change', '#selectFile', selectFile);
    return $(document).on('click', '#download-link', outPut);
  });

}).call(this);
