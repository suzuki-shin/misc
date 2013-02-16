var tabSelect, historySelect, bookmarkSelect;
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
bookmarkSelect = function(f, list){
  return chrome.bookmarks.search("h", function(es){
    var e;
    return f(list.concat((function(){
      var i$, ref$, len$, results$ = [];
      for (i$ = 0, len$ = (ref$ = es).length; i$ < len$; ++i$) {
        e = ref$[i$];
        if (e.url != null) {
          results$.push({
            id: e.id,
            title: e.title,
            url: e.url,
            type: 'bookmark'
          });
        }
      }
      return results$;
    }())));
  });
};
console.log('background');
chrome.extension.onMessage.addListener(function(msg, sender, sendResponse){
  var bookmarkSelect_, historySelect_;
  console.log(msg);
  if (msg.mes === "makeSelectorConsole") {
    bookmarkSelect_ = function(list){
      return bookmarkSelect(sendResponse, list);
    };
    historySelect_ = function(list){
      return historySelect(bookmarkSelect_, list);
    };
    tabSelect(historySelect_, []);
  } else if (msg.mes === "keyUpSelectorCursorEnter") {
    console.log(msg);
    if (msg.item.type === "tab") {
      console.log('tabs.update');
      chrome.tabs.update(parseInt(msg.item.id), {
        active: true
      });
    } else {
      chrome.tabs.create({
        url: msg.item.url
      });
    }
  }
  return true;
});