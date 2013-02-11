var KEY_CODE_HITAHINT_START, KEY_CODE_FOCUS_FORM, KEY_CODE_CANCEL, MODE_NEWTRAL, MODE_HITAHINT, MODE_FORM_FOCUS;
console.log('background');
KEY_CODE_HITAHINT_START = 69;
KEY_CODE_FOCUS_FORM = 70;
KEY_CODE_CANCEL = 27;
MODE_NEWTRAL = 0;
MODE_HITAHINT = 1;
MODE_FORM_FOCUS = 2;
$(function(){
  var links, mode;
  links = $('a');
  mode = MODE_NEWTRAL;
  return $(document).keyup(function(e){
    console.log(e.keyCode);
    return console.log(mode);
  });
});