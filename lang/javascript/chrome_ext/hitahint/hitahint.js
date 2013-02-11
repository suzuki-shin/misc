var KEY_CODE_HITAHINT_START, KEY_CODE_FOCUS_FORM, KEY_CODE_CANCEL, HINT_KEYS, keyCodeToIndex, indexToKeyCode, isHitAHintKey, Main, NewtralMode, HitAHintMode, FormFocusMode;
console.log('hitahint');
KEY_CODE_HITAHINT_START = 69;
KEY_CODE_FOCUS_FORM = 70;
KEY_CODE_CANCEL = 27;
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
keyCodeToIndex = function(keyCode){
  return keyCode - 65;
};
indexToKeyCode = function(index){
  return index + 65;
};
isHitAHintKey = function(keyCode){
  var k, v;
  return $.inArray(String(keyCode), (function(){
    var ref$, results$ = [];
    for (k in ref$ = HINT_KEYS) {
      v = ref$[k];
      results$.push(k);
    }
    return results$;
  }())) !== -1;
};
Main = (function(){
  Main.displayName = 'Main';
  var prototype = Main.prototype, constructor = Main;
  function Main(){}
  return Main;
}());
NewtralMode = (function(){
  NewtralMode.displayName = 'NewtralMode';
  var prototype = NewtralMode.prototype, constructor = NewtralMode;
  function NewtralMode(){}
  return NewtralMode;
}());
NewtralMode.keyUpHitAHintStart = function(){
  Main.mode = HitAHintMode;
  return $('a').addClass('links').html(function(i, oldHtml){
    if (HINT_KEYS[indexToKeyCode(i)] != null) {
      return '<div class="hintKey">' + HINT_KEYS[indexToKeyCode(i)] + '</div> ' + oldHtml;
    } else {
      return oldHtml;
    }
  });
};
NewtralMode.keyUpFocusForm = function(){
  Main.mode = FormFocusMode;
  return $('input, textarea')[0].focus();
};
NewtralMode.keyUpCancel = function(){
  return false;
};
NewtralMode.keyUpHintKey = function(keyCode){
  return false;
};
NewtralMode.keyUpOthers = function(){
  return false;
};
HitAHintMode = (function(){
  HitAHintMode.displayName = 'HitAHintMode';
  var prototype = HitAHintMode.prototype, constructor = HitAHintMode;
  function HitAHintMode(){}
  return HitAHintMode;
}());
HitAHintMode.keyUpHitAHintStart = function(){
  return false;
};
HitAHintMode.keyUpFocusForm = function(){
  return false;
};
HitAHintMode.keyUpCancel = function(){
  Main.mode = NewtralMode;
  $('a').removeClass('links');
  return $('.hintKey').remove();
};
HitAHintMode.keyUpHintKey = function(keyCode){
  console.log('hit!: ' + keyCode);
  $('a')[keyCodeToIndex(keyCode)].click();
  Main.mode = NewtralMode;
  $('a').removeClass('links');
  return $('.hintKey').remove();
};
HitAHintMode.keyUpOthers = function(){
  return false;
};
FormFocusMode = (function(){
  FormFocusMode.displayName = 'FormFocusMode';
  var prototype = FormFocusMode.prototype, constructor = FormFocusMode;
  function FormFocusMode(){}
  return FormFocusMode;
}());
FormFocusMode.keyUpHitAHintStart = function(){
  return console.log('');
};
FormFocusMode.keyUpFocusForm = function(){
  return console.log('');
};
FormFocusMode.keyUpCancel = function(){
  Main.mode = NewtralMode;
  return $(':focus').blur();
};
FormFocusMode.keyUpHintKey = function(keyCode){
  return false;
};
FormFocusMode.keyUpOthers = function(){
  return false;
};
$(function(){
  Main.mode = NewtralMode;
  $('input, textarea').focus(function(){
    return Main.mode = FormFocusMode;
  });
  return $(document).keyup(function(e){
    console.log('keyCode: ' + e.keyCode);
    console.log('mode: ' + Main.mode);
    if (e.keyCode === KEY_CODE_HITAHINT_START) {
      return Main.mode.keyUpHitAHintStart();
    } else if (e.keyCode === KEY_CODE_FOCUS_FORM) {
      return Main.mode.keyUpFocusForm();
    } else if (e.keyCode === KEY_CODE_CANCEL) {
      return Main.mode.keyUpCancel();
    } else if (isHitAHintKey(e.keyCode)) {
      return Main.mode.keyUpHintKey(e.keyCode);
    } else {
      return Main.mode.keyUpOthers();
    }
  });
});