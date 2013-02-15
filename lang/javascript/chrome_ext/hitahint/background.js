var tabSelect, historySelect;
tabSelect = function(f, list){
  return chrome.tabs.query({
    currentWindow: true
  }, function(tabs){
    var e;
    return f(list.concat((function(){
      var i$, ref$, len$, results$ = [];
      for (i$ = 0, len$ = (ref$ = tabs).length; i$ < len$; ++i$) {
        e = ref$[i$];
        results$.push({
          id: e.id,
          title: e.title,
          url: e.url,
          type: 'tab'
        });
      }
      return results$;
    }())));
  });
};
historySelect = function(f, list){
  return chrome.history.search({
    text: '',
    maxResults: 100
  }, function(hs){
    var e;
    console.log('hs');
    console.log(hs);
    return f(list.concat((function(){
      var i$, ref$, len$, results$ = [];
      for (i$ = 0, len$ = (ref$ = hs).length; i$ < len$; ++i$) {
        e = ref$[i$];
        results$.push({
          id: e.id,
          title: e.title,
          url: e.url,
          type: 'history'
        });
      }
      return results$;
    }())));
  });
};
console.log('background');
chrome.extension.onMessage.addListener(function(msg, sender, sendResponse){
  console.log(msg);
  if (msg.mes === "makeSelectorConsole") {
    tabSelect(function(es){
      return historySelect(sendResponse, es);
    }, []);
  } else if (msg.mes === "keyUpSelectorCursorEnter") {
    console.log(msg);
    if (msg.type === "tab") {
      console.log('tabs.update');
      chrome.tabs.update(parseInt(msg.id), {
        active: true
      });
    } else {
      alert('history.update ' + msg.id);
    }
  }
  return true;
});