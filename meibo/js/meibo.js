(function() {
  var drop, selectFile, _drop;

  selectFile = function(ev) {
    var f;
    return typeof console !== "undefined" && console !== null ? console.log((function() {
      var _i, _len, _ref, _results;
      _ref = ev.target.files;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        f = _ref[_i];
        _results.push(f.name);
      }
      return _results;
    })()) : void 0;
  };

  _drop = function(files) {
    var f, html, _i, _len;
    if (typeof console !== "undefined" && console !== null) console.log('_drop');
    html = '<html><head></head><body><table>';
    for (_i = 0, _len = files.length; _i < _len; _i++) {
      f = files[_i];
      if (typeof console !== "undefined" && console !== null) console.log(f.name);
      html = html + '<tr><td><img src="' + f.name + '"/></td></tr>';
    }
    html = html + '</table></body></html>';
    if (typeof console !== "undefined" && console !== null) console.log(html);
    $('#download-link').attr('href', "data:text/html," + html);
    return $('#download-link').show();
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
      return false;
    });
    return $("body").bind("dragover", function() {
      return false;
    });
  });

}).call(this);
