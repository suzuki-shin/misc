var p, KEY_CODE_HITAHINT_START, KEY_CODE_FOCUS_FORM, KEY_CODE_CANCEL, KEY_CODE_SELECTOR_TOGGLE, _HINT_KEYS, HINT_KEYS, k1, v1, k2, v2, keyCodeToIndex, indexToKeyCode, isHitAHintKey, makeSelectorConsole, filteringTabs, isFocusingForm, Main, NeutralMode, HitAHintMode, FormFocusMode, SelectorMode;
console.log('hitahint');
p = prelude;
KEY_CODE_HITAHINT_START = 69;
KEY_CODE_FOCUS_FORM = 70;
KEY_CODE_CANCEL = 27;
KEY_CODE_SELECTOR_TOGGLE = 186;
_HINT_KEYS = {
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
  85: 'u',
  86: 'v',
  87: 'w',
  88: 'x',
  89: 'y',
  90: 'z'
};
HINT_KEYS = {};
for (k1 in _HINT_KEYS) {
  v1 = _HINT_KEYS[k1];
  for (k2 in _HINT_KEYS) {
    v2 = _HINT_KEYS[k2];
    HINT_KEYS[parseInt(k1) * 100 + parseInt(k2)] = v1 + v2;
  }
}
keyCodeToIndex = function(firstKeyCode, secondKeyCode){
  var k, v;
  return $.inArray(parseInt(firstKeyCode) * 100 + parseInt(secondKeyCode), (function(){
    var ref$, results$ = [];
    for (k in ref$ = HINT_KEYS) {
      v = ref$[k];
      results$.push(parseInt(k));
    }
    return results$;
  }()));
};
indexToKeyCode = function(index){
  var k, v;
  return (function(){
    var ref$, results$ = [];
    for (k in ref$ = HINT_KEYS) {
      v = ref$[k];
      results$.push(k);
    }
    return results$;
  }())[index];
};
isHitAHintKey = function(keyCode){
  var k, v;
  return $.inArray(String(keyCode), (function(){
    var ref$, results$ = [];
    for (k in ref$ = _HINT_KEYS) {
      v = ref$[k];
      results$.push(k);
    }
    return results$;
  }())) !== -1;
};
makeSelectorConsole = function(tabs){
  var ts, t;
  if ($('#selectorList')) {
    $('#selectorList').remove();
  }
  console.log(tabs);
  ts = p.concat((function(){
    var i$, ref$, len$, results$ = [];
    for (i$ = 0, len$ = (ref$ = tabs).length; i$ < len$; ++i$) {
      t = ref$[i$];
      results$.push('<tr><td>' + t.id + '</td><td>' + t.title + '</td></tr>');
    }
    return results$;
  }()));
  $('#selectorConsole').append('<table id="selectorList">' + ts + '</table>');
  return $('#selectorList tr:first').addClass("selected");
};
filteringTabs = function(text, tabs){
  return p.filter(function(t){
    var a;
    a = t.title.search(text) !== -1;
    console.log(t);
    console.log(a);
    return a;
  }, tabs);
};
isFocusingForm = function(){
  var focusElems;
  focusElems = $(':focus');
  console.log(focusElems.attr('type'));
  return focusElems && ((focusElems[0].nodeName.toLowerCase() === "input" && focusElems.attr('type') === "text") || focusElems[0].nodeName.toLowerCase() === "textarea");
};
Main = (function(){
  Main.displayName = 'Main';
  var prototype = Main.prototype, constructor = Main;
  function Main(){}
  return Main;
}());
NeutralMode = (function(){
  NeutralMode.displayName = 'NeutralMode';
  var prototype = NeutralMode.prototype, constructor = NeutralMode;
  NeutralMode.keyUpHitAHintStart = function(){
    Main.mode = HitAHintMode;
    return Main.links.addClass('links').html(function(i, oldHtml){
      if (HINT_KEYS[indexToKeyCode(i)] != null) {
        return '<div class="hintKey">' + HINT_KEYS[indexToKeyCode(i)] + '</div> ' + oldHtml;
      } else {
        return oldHtml;
      }
    });
  };
  NeutralMode.keyUpFocusForm = function(){
    Main.mode = FormFocusMode;
    return $('input, textarea')[0].focus();
  };
  NeutralMode.keyUpCancel = function(){
    return false;
  };
  NeutralMode.keyUpHintKey = function(keyCode){
    return false;
  };
  NeutralMode.keyUpSelectorToggle = function(){
    Main.mode = SelectorMode;
    $('#selectorConsole').show();
    return $('#selectorInput').focus();
  };
  NeutralMode.keyUpOthers = function(){
    return false;
  };
  NeutralMode.keyUpAny = function(keyCode){
    return false;
  };
  function NeutralMode(){}
  return NeutralMode;
}());
HitAHintMode = (function(){
  HitAHintMode.displayName = 'HitAHintMode';
  var prototype = HitAHintMode.prototype, constructor = HitAHintMode;
  HitAHintMode.firstKeyCode = null;
  HitAHintMode.keyUpHitAHintStart = function(){
    return false;
  };
  HitAHintMode.keyUpFocusForm = function(){
    return false;
  };
  HitAHintMode.keyUpCancel = function(){
    Main.mode = NeutralMode;
    Main.links.removeClass('links');
    return $('.hintKey').remove();
  };
  HitAHintMode.keyUpHintKey = function(keyCode){
    var idx;
    console.log('hit!: ' + keyCode + ', 1stkey: ' + this.firstKeyCode);
    if (this.firstKeyCode === null) {
      return this.firstKeyCode = keyCode;
    } else {
      idx = keyCodeToIndex(this.firstKeyCode, keyCode);
      console.log('idx: ' + idx);
      console.log(Main.links);
      Main.links[idx].click();
      Main.mode = NeutralMode;
      Main.links.removeClass('links');
      $('.hintKey').remove();
      return this.firstKeyCode = null;
    }
  };
  HitAHintMode.keyUpSelectorToggle = function(){
    return false;
  };
  HitAHintMode.keyUpOthers = function(){
    return false;
  };
  HitAHintMode.keyUpAny = function(keyCode){
    return false;
  };
  function HitAHintMode(){}
  return HitAHintMode;
}());
FormFocusMode = (function(){
  FormFocusMode.displayName = 'FormFocusMode';
  var prototype = FormFocusMode.prototype, constructor = FormFocusMode;
  FormFocusMode.keyUpHitAHintStart = function(){
    return false;
  };
  FormFocusMode.keyUpFocusForm = function(){
    return false;
  };
  FormFocusMode.keyUpCancel = function(){
    Main.mode = NeutralMode;
    return $(':focus').blur();
  };
  FormFocusMode.keyUpHintKey = function(keyCode){
    return false;
  };
  FormFocusMode.keyUpSelectorToggle = function(){
    return false;
  };
  FormFocusMode.keyUpOthers = function(){
    return false;
  };
  FormFocusMode.keyUpAny = function(keyCode){
    return false;
  };
  function FormFocusMode(){}
  return FormFocusMode;
}());
SelectorMode = (function(){
  SelectorMode.displayName = 'SelectorMode';
  var prototype = SelectorMode.prototype, constructor = SelectorMode;
  SelectorMode.keyUpHitAHintStart = function(){
    return false;
  };
  SelectorMode.keyUpFocusForm = function(){
    return false;
  };
  SelectorMode.keyUpCancel = function(){
    Main.mode = NeutralMode;
    $('#selectorConsole').hide();
    return $(':focus').blur();
  };
  SelectorMode.keyUpHintKey = function(keyCode){
    return false;
  };
  SelectorMode.keyUpOthers = function(){
    return false;
  };
  SelectorMode.keyUpSelectorToggle = function(){
    Main.mode = NeutralMode;
    return $('#selectorConsole').hide();
  };
  SelectorMode.keyUpAny = function(keyCode){
    var text;
    text = $('#selectorInput').val();
    console.log(text);
    makeSelectorConsole(filteringTabs(text, Main.tabs));
    return $('#selectorConsole').show();
  };
  function SelectorMode(){}
  return SelectorMode;
}());
$(function(){
  Main.mode = NeutralMode;
  Main.links = $('a').length === void 8
    ? [$('a')]
    : $('a');
  if (isFocusingForm()) {
    Main.mode = FormFocusMode;
  }
  chrome.extension.sendMessage({
    mes: "makeSelectorConsole"
  }, function(tabs){
    Main.tabs = tabs;
    $('body').append('<div id="selectorConsole"><input id="selectorInput" type="text" /></div>');
    return makeSelectorConsole(tabs);
  });
  $('input[type="text"], textarea').focus(function(){
    console.log('form focus');
    return Main.mode = FormFocusMode;
  });
  $('input[type="text"], textarea').blur(function(){
    console.log('form blur');
    return Main.mode = NeutralMode;
  });
  return $(document).keyup(function(e){
    console.log('keyCode: ' + e.keyCode);
    console.log('mode: ' + Main.mode);
    if (e.keyCode === KEY_CODE_HITAHINT_START) {
      Main.mode.keyUpHitAHintStart();
    } else if (e.keyCode === KEY_CODE_FOCUS_FORM) {
      Main.mode.keyUpFocusForm();
    } else if (e.keyCode === KEY_CODE_CANCEL) {
      Main.mode.keyUpCancel();
    } else if (e.keyCode === KEY_CODE_SELECTOR_TOGGLE) {
      Main.mode.keyUpSelectorToggle();
    } else if (isHitAHintKey(e.keyCode)) {
      Main.mode.keyUpHintKey(e.keyCode);
    } else {
      Main.mode.keyUpOthers();
    }
    return Main.mode.keyUpAny();
  });
});