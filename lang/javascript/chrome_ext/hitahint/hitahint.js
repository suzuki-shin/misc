var p, FORM_INPUT_FIELDS, KEY_CODE, _HINT_KEYS, HINT_KEYS, k1, v1, k2, v2, keyCodeToIndex, indexToKeyCode, isHitAHintKey, makeSelectorConsole, filteringTabs, isFocusingForm, Main, NeutralMode, HitAHintMode, FormFocusMode, SelectorMode;
p = prelude;
FORM_INPUT_FIELDS = 'input[type!="hidden"], textarea, select';
KEY_CODE = {
  START_HITAHINT: 69,
  FOCUS_FORM: 70,
  TOGGLE_SELECTOR: 186,
  CANCEL: 27,
  MOVE_NEXT_SELECTOR_CURSOR: 40,
  MOVE_PREV_SELECTOR_CURSOR: 38,
  ENTER_SELECTOR_CURSOR: 13,
  MOVE_NEXT_FORM: 34,
  MOVE_PREV_FORM: 33,
  BACK_HISTORY: 72
};
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
      results$.push('<tr id="tab-' + t.id + '"><td><span class="tabTitle">[T] ' + t.title + ' </span><span class="tabUrl"> ' + t.url + '</span></td></tr>');
    }
    return results$;
  }()));
  $('#selectorConsole').append('<table id="selectorList">' + ts + '</table>');
  return $('#selectorList tr:first').addClass("selected");
};
filteringTabs = function(text, tabs){
  var matchP;
  matchP = function(tab, queries){
    var q;
    return p.all(p.id, (function(){
      var i$, ref$, len$, results$ = [];
      for (i$ = 0, len$ = (ref$ = queries).length; i$ < len$; ++i$) {
        q = ref$[i$];
        results$.push(tab.title.toLowerCase().search(q) !== -1 || tab.url.toLowerCase().search(q) !== -1);
      }
      return results$;
    }()));
  };
  return p.filter(function(t){
    return matchP(t, text.toLowerCase().split(' '));
  }, tabs);
};
isFocusingForm = function(){
  var focusElems;
  console.log('isFocusingForm');
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
  NeutralMode.keyMap = function(e){
    switch (e.keyCode) {
    case KEY_CODE.START_HITAHINT:
      constructor.keyUpHitAHintStart();
      break;
    case KEY_CODE.FOCUS_FORM:
      constructor.keyUpFocusForm();
      break;
    case KEY_CODE.TOGGLE_SELECTOR:
      constructor.keyUpSelectorToggle();
      break;
    case KEY_CODE.BACK_HISTORY:
      constructor.keyUpHistoryBack();
      break;
    default:
      (function(){
        return console.log('default');
      });
    }
    return e.preventDefault();
  };
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
    Main.formInputFieldIndex = 0;
    return $(FORM_INPUT_FIELDS).eq(Main.formInputFieldIndex).focus();
  };
  NeutralMode.keyUpSelectorToggle = function(){
    Main.mode = SelectorMode;
    $('#selectorConsole').show();
    return $('#selectorInput').focus();
  };
  NeutralMode.keyUpHistoryBack = function(){
    return history.back();
  };
  function NeutralMode(){}
  return NeutralMode;
}());
HitAHintMode = (function(){
  HitAHintMode.displayName = 'HitAHintMode';
  var prototype = HitAHintMode.prototype, constructor = HitAHintMode;
  HitAHintMode.keyMap = function(e){
    switch (e.keyCode) {
    case KEY_CODE.CANCEL:
      constructor.keyUpCancel();
      break;
    default:
      constructor.keyUpHintKey(e.keyCode);
    }
    return e.preventDefault();
  };
  HitAHintMode.firstKeyCode = null;
  HitAHintMode.keyUpCancel = function(){
    Main.mode = NeutralMode;
    Main.links.removeClass('links');
    return $('.hintKey').remove();
  };
  HitAHintMode.keyUpHintKey = function(keyCode){
    var idx;
    console.log('hit!: ' + keyCode + ', 1stkey: ' + this.firstKeyCode);
    if (!isHitAHintKey(keyCode)) {
      return;
    }
    if (this.firstKeyCode === null) {
      return this.firstKeyCode = keyCode;
    } else {
      idx = keyCodeToIndex(this.firstKeyCode, keyCode);
      Main.links[idx].click();
      Main.mode = NeutralMode;
      Main.links.removeClass('links');
      $('.hintKey').remove();
      return this.firstKeyCode = null;
    }
  };
  function HitAHintMode(){}
  return HitAHintMode;
}());
FormFocusMode = (function(){
  FormFocusMode.displayName = 'FormFocusMode';
  var prototype = FormFocusMode.prototype, constructor = FormFocusMode;
  FormFocusMode.keyMap = function(e){
    switch (e.keyCode) {
    case KEY_CODE.MOVE_NEXT_FORM:
      constructor.keyUpFormNext();
      break;
    case KEY_CODE.MOVE_PREV_FORM:
      constructor.keyUpFormPrev();
      break;
    case KEY_CODE.CANCEL:
      constructor.keyUpCancel();
      break;
    default:
      (function(){
        return console.log('default');
      });
    }
    return e.preventDefault();
  };
  FormFocusMode.keyUpFormNext = function(){
    console.log('keyUpFormNext');
    Main.formInputFieldIndex += 1;
    console.log(Main.formInputFieldIndex);
    console.log($(FORM_INPUT_FIELDS));
    console.log($(FORM_INPUT_FIELDS).eq(Main.formInputFieldIndex));
    if ($(FORM_INPUT_FIELDS).eq(Main.formInputFieldIndex) != null) {
      return $(FORM_INPUT_FIELDS).eq(Main.formInputFieldIndex).focus();
    }
  };
  FormFocusMode.keyUpFormPrev = function(){
    console.log('keyUpFormPrev');
    Main.formInputFieldIndex -= 1;
    console.log(Main.formInputFieldIndex);
    console.log($(FORM_INPUT_FIELDS));
    console.log($(FORM_INPUT_FIELDS).eq(Main.formInputFieldIndex));
    if ($(FORM_INPUT_FIELDS).eq(Main.formInputFieldIndex) != null) {
      return $(FORM_INPUT_FIELDS).eq(Main.formInputFieldIndex).focus();
    }
  };
  FormFocusMode.keyUpCancel = function(){
    Main.mode = NeutralMode;
    return $(':focus').blur();
  };
  function FormFocusMode(){}
  return FormFocusMode;
}());
SelectorMode = (function(){
  SelectorMode.displayName = 'SelectorMode';
  var prototype = SelectorMode.prototype, constructor = SelectorMode;
  SelectorMode.keyMap = function(e){
    switch (e.keyCode) {
    case KEY_CODE.CANCEL:
      constructor.keyUpCancel();
      break;
    case KEY_CODE.TOGGLE_SELECTOR:
      constructor.keyUpSelectorToggle();
      break;
    case KEY_CODE.MOVE_NEXT_SELECTOR_CURSOR:
      constructor.keyUpSelectorCursorNext();
      break;
    case KEY_CODE.MOVE_PREV_SELECTOR_CURSOR:
      constructor.keyUpSelectorCursorPrev();
      break;
    case KEY_CODE.ENTER_SELECTOR_CURSOR:
      constructor.keyUpSelectorCursorEnter();
      break;
    default:
      constructor.keyUpSelectorFiltering();
    }
    return e.preventDefault();
  };
  SelectorMode.keyUpCancel = function(){
    Main.mode = NeutralMode;
    $('#selectorConsole').hide();
    return $(':focus').blur();
  };
  SelectorMode.keyUpSelectorFiltering = function(){
    var text;
    console.log('keyUpSelectorFiltering');
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
    tabId = $('#selectorList tr.selected').attr('id').split('-')[1];
    constructor.keyUpCancel();
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
Main.start = function(){
  var _clickables;
  Main.mode = NeutralMode;
  _clickables = $('a');
  Main.links = _clickables.length === void 8 ? [_clickables] : _clickables;
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
  $(FORM_INPUT_FIELDS).focus(function(){
    console.log('form focus');
    return Main.mode = FormFocusMode;
  });
  $(FORM_INPUT_FIELDS).blur(function(){
    console.log('form blur');
    return Main.mode = NeutralMode;
  });
  return $(document).keyup(function(e){
    console.log('keyCode: ' + e.keyCode);
    console.log('mode: ' + Main.mode);
    return Main.mode.keyMap(e);
  });
};
Main.start();