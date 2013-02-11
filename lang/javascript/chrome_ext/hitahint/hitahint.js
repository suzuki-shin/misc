var KEY_CODE_HITAHINT_START, KEY_CODE_FOCUS_FORM, KEY_CODE_CANCEL, MODE_NEWTRAL, MODE_HITAHINT, MODE_FORM_FOCUS, HINT_KEYS, Main;
console.log('hitahint');
KEY_CODE_HITAHINT_START = 69;
KEY_CODE_FOCUS_FORM = 70;
KEY_CODE_CANCEL = 27;
MODE_NEWTRAL = 0;
MODE_HITAHINT = 1;
MODE_FORM_FOCUS = 2;
HINT_KEYS = {
  65: 'a',
  66: 'b',
  67: 'c',
  68: 'd',
  69: 'e',
  70: 'f',
  71: 'g',
  72: 'h',
  73: 'i',
  74: 'j',
  75: 'k',
  76: 'l',
  77: 'm',
  78: 'n',
  79: 'o',
  80: 'p',
  81: 'q',
  82: 'r',
  83: 's',
  84: 't',
  85: 'u'
};
Main = (function(){
  Main.displayName = 'Main';
  var prototype = Main.prototype, constructor = Main;
  function Main(){}
  return Main;
}());
$(function(){
  var HINT_KEYS_LENGTH, links;
  HINT_KEYS_LENGTH = HINT_KEYS.length;
  links = $('a');
  Main.mode = MODE_NEWTRAL;
  return $(document).keyup(function(e){
    var k, v;
    console.log(e.keyCode);
    console.log(Main.mode);
    if (Main.mode === MODE_NEWTRAL) {
      if (e.keyCode === KEY_CODE_HITAHINT_START) {
        Main.mode = MODE_HITAHINT;
        return links.addClass('links').html(function(i, oldHtml){
          if (HINT_KEYS[i + 65] != null) {
            console.log(HINT_KEYS[i + 65]);
            return '<div class="hintKey">' + HINT_KEYS[i + 65] + '</div> ' + oldHtml;
          } else {
            return oldHtml;
          }
        });
      } else if (e.keyCode === KEY_CODE_FOCUS_FORM) {
        Main.mode = MODE_FORM_FOCUS;
        return $('input, textarea')[0].focus();
      }
    } else if (Main.mode === MODE_HITAHINT) {
      if (e.keyCode === KEY_CODE_CANCEL) {
        Main.mode = MODE_NEWTRAL;
        links.removeClass('links');
        return $('.hintKey').remove();
      } else if ($.inArray(e, (function(){
        var ref$, results$ = [];
        for (k in ref$ = HINT_KEYS) {
          v = ref$[k];
          results$.push(k);
        }
        return results$;
      }())) !== -1) {
        return console.log('hit!: ' + e.keyCode);
      } else {
        console.log(e);
        return console.log('mum');
      }
    } else if (Main.mode === MODE_FORM_FOCUS) {
      if (e.keyCode === KEY_CODE_CANCEL) {
        $(':focus').blur();
        return Main.mode = MODE_NEWTRAL;
      }
    } else {
      return console.log('else');
    }
  });
});