(function() {
  var drop, ftoh, fullchar2halfchar, selectFile, _drop;

  ftoh = function(str) {
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
    reader = new FileReader();
    reader.readAsText(file);
    reader.onload = function(ev) {
      $('#download-link').attr('href', "data:application/octet-stream," + encodeURIComponent(ftoh(reader.result)));
      $('#download-link').show();
      return $('#data-area').empty().append(ftoh(reader.result));
    };
    return reader.onerror = function(ev) {
      return alert('error');
    };
  };

  _drop = function(files) {
    var f, reader, _i, _len, _results;
    if (typeof console !== "undefined" && console !== null) console.log('_drop');
    reader = new FileReader();
    _results = [];
    for (_i = 0, _len = files.length; _i < _len; _i++) {
      f = files[_i];
      reader.readAsText(f);
      _results.push(reader.onload = function() {
        return $('body').empty().append(ftoh(reader.result));
      });
    }
    return _results;
  };

  drop = function(e) {
    if (typeof console !== "undefined" && console !== null) console.log('drop');
    if (e.preventDefault) e.preventDefault();
    return _drop(e.originalEvent.dataTransfer.files);
  };

  /*
  # event
  */

  $(function() {
    $(document).on('change', '#selectFile', selectFile);
    $("body").bind("drop", drop);
    $("body").bind("dragenter", function() {
      if (typeof console !== "undefined" && console !== null) console.log('aaa');
      return false;
    });
    return $("body").bind("dragover", function() {
      if (typeof console !== "undefined" && console !== null) console.log('bbb');
      return false;
    });
  });

}).call(this);
