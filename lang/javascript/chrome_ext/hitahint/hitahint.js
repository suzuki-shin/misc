var p, KEY_CODE_HITAHINT_START, KEY_CODE_FOCUS_FORM, KEY_CODE_CANCEL, KEY_CODE_SELECTOR_TOGGLE, KEY_CODE_SELECTOR_CURSOR_NEXT, KEY_CODE_SELECTOR_CURSOR_PREV, KEY_CODE_SELECTOR_CURSOR_ENTER, _HINT_KEYS, HINT_KEYS, k1, v1, k2, v2, keyCodeToIndex, indexToKeyCode, isHitAHintKey, makeSelectorConsole, filteringTabs, isFocusingForm, Main, NeutralMode, HitAHintMode, FormFocusMode, SelectorMode;
console.log('hitahint');
p = prelude;
KEY_CODE_HITAHINT_START = 69;
KEY_CODE_FOCUS_FORM = 70;
KEY_CODE_CANCEL = 27;
KEY_CODE_SELECTOR_TOGGLE = 186;
KEY_CODE_SELECTOR_CURSOR_NEXT = 40;
KEY_CODE_SELECTOR_CURSOR_PREV = 38;
KEY_CODE_SELECTOR_CURSOR_ENTER = 13;
_HINT_KEYS = {
  65: 'A',
  66: 'B',
  67: 'C',
  68: 'D',
  69: 'E',
  70: 'F',
  71: 'G',
  72: 'H',
  73: 'I',
  74: 'J',
  75: 'K',
  76: 'L',
  77: 'M',
  78: 'N',
  79: 'O',
  80: 'P',
  81: 'Q',
  82: 'R',
  83: 'S',
  84: 'T',
  85: 'U',
  86: 'V',
  87: 'W',
  88: 'X',
  89: 'Y',
  90: 'Z'
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
      results$.push('<tr id="' + t.id + '"><td>' + t.title + '</td></tr>');
    }
    return results$;
  }()));
  $('#selectorConsole').append('<table id="selectorList">' + ts + '</table>');
  return $('#selectorList tr:first').addClass("selected");
};
filteringTabs = function(text, tabs){
  return p.filter(function(t){
    return t.title.search(text) !== -1;
  }, tabs);
};
isFocusingForm = function(){
  var focusElems;
  focusElems = $(':focus');
  console.log(focusElems.attr('type'));
  return focusElems[0] && ((focusElems[0].nodeName.toLowerCase() === "input" && focusElems.attr('type') === "text") || focusElems[0].nodeName.toLowerCase() === "textarea");
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
  function FormFocusMode(){}
  return FormFocusMode;
}());
SelectorMode = (function(){
  SelectorMode.displayName = 'SelectorMode';
  var prototype = SelectorMode.prototype, constructor = SelectorMode;
  SelectorMode.keyUpHitAHintStart = function(){
    return this.keyUpOthers();
  };
  SelectorMode.keyUpFocusForm = function(){
    return this.keyUpOthers();
  };
  SelectorMode.keyUpCancel = function(){
    Main.mode = NeutralMode;
    $('#selectorConsole').hide();
    return $(':focus').blur();
  };
  SelectorMode.keyUpHintKey = function(){
    return this.keyUpOthers();
  };
  SelectorMode.keyUpOthers = function(){
    var text;
    console.log('keyUpOthers');
    text = $('#selectorInput').val();
    console.log(text);
    makeSelectorConsole(filteringTabs(text, Main.tabs));
    return $('#selectorConsole').show();
  };
  SelectorMode.keyUpSelectorToggle = function(){
    Main.mode = NeutralMode;
    return $('#selectorConsole').hide();
  };
  SelectorMode.keyUpSelectorCursorNext = function(){
    console.log('keyUpSelectorCursorNext');
    return $('#selectorList .selected').removeClass("selected").next("tr").addClass("selected");
  };
  SelectorMode.keyUpSelectorCursorPrev = function(){
    console.log('keyUpSelectorCursorPrev');
    return $('#selectorList .selected').removeClass("selected").prev("tr").addClass("selected");
  };
  SelectorMode.keyUpSelectorCursorEnter = function(){
    var tabId;
    console.log('keyUpSelectorCursorEnter');
    tabId = $('#selectorList tr.selected').attr('id');
    console.log(tabId);
    return chrome.extension.sendMessage({
      mes: "keyUpSelectorCursorEnter",
      tabId: tabId
    }, function(res){
      return console.log(res);
    });
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
      console.log('KEY_CODE_HITAHINT_START');
      return Main.mode.keyUpHitAHintStart();
    } else if (e.keyCode === KEY_CODE_FOCUS_FORM) {
      console.log('KEY_CODE_FOCUS_FORM');
      return Main.mode.keyUpFocusForm();
    } else if (e.keyCode === KEY_CODE_CANCEL) {
      console.log('KEY_CODE_CANCEL');
      return Main.mode.keyUpCancel();
    } else if (e.keyCode === KEY_CODE_SELECTOR_TOGGLE) {
      console.log('KEY_CODE_SELECTOR_TOGGLE');
      return Main.mode.keyUpSelectorToggle();
    } else if (e.keyCode === KEY_CODE_SELECTOR_CURSOR_NEXT) {
      console.log('KEY_CODE_SELECTOR_CURSOR_NEXT');
      return Main.mode.keyUpSelectorCursorNext(e.keyCode);
    } else if (e.keyCode === KEY_CODE_SELECTOR_CURSOR_PREV) {
      console.log('KEY_CODE_SELECTOR_CURSOR_PREV');
      return Main.mode.keyUpSelectorCursorPrev(e.keyCode);
    } else if (e.keyCode === KEY_CODE_SELECTOR_CURSOR_ENTER) {
      console.log('KEY_CODE_SELECTOR_CURSOR_ENTER');
      return Main.mode.keyUpSelectorCursorEnter();
    } else if (isHitAHintKey(e.keyCode)) {
      console.log('KEY_CODE_HIT_HINT');
      return Main.mode.keyUpHintKey(e.keyCode);
    } else {
      console.log('KEY_CODE_DEFAULT');
      return Main.mode.keyUpOthers();
    }
  });
});