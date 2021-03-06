var Background;
Background = (function(){
  Background.displayName = 'Background';
  var prototype = Background.prototype, constructor = Background;
  function Background(){}
  return Background;
}());
Background.tabs = [];
Background.filterByInputQuery = function(tabs, text){
  var p, matchFunc, regs, res$, i$, ref$, len$, t, results$ = [];
  p = prelude;
  matchFunc = function(tab, regs){
    var re;
    return p.all(p.id, (function(){
      var i$, ref$, len$, results$ = [];
      for (i$ = 0, len$ = (ref$ = regs).length; i$ < len$; ++i$) {
        re = ref$[i$];
        results$.push(tab.title.search(re) !== -1 || tab.url.search(re) !== -1);
      }
      return results$;
    }()));
  };
  res$ = [];
  for (i$ = 0, len$ = (ref$ = text.split(" ")).length; i$ < len$; ++i$) {
    t = ref$[i$];
    res$.push(new RegExp(t));
  }
  regs = res$;
  console.log('regs');
  console.log(regs);
  for (i$ = 0, len$ = tabs.length; i$ < len$; ++i$) {
    t = tabs[i$];
    if (matchFunc(t, regs)) {
      results$.push({
        content: t.url,
        description: t.title + ' ' + t.url
      });
    }
  }
  return results$;
};
chrome.omnibox.onInputStarted.addListener(function(){
  var listTabs;
  console.log('inputStarted:');
  listTabs = function(tabs){
    console.log('listTabs');
    console.log(tabs);
    return Background.tabs = tabs;
  };
  return chrome.tabs.query({}, listTabs);
});
chrome.omnibox.onInputChanged.addListener(function(text, suggest){
  var matchTabs;
  console.log('inputChanged: ' + text);
  matchTabs = Background.filterByInputQuery(Background.tabs, text);
  console.log('matchTabs');
  console.log(matchTabs);
  return suggest(matchTabs);
});
chrome.omnibox.onInputEntered.addListener(function(url){
  var _tabIds, res$, i$, ref$, len$, t, tabId;
  console.log('inputEntered: ' + url);
  res$ = [];
  for (i$ = 0, len$ = (ref$ = Background.tabs).length; i$ < len$; ++i$) {
    t = ref$[i$];
    if (t.url === url) {
      res$.push(t.id);
    }
  }
  _tabIds = res$;
  if (_tabIds === []) {
    return;
  }
  tabId = _tabIds[0];
  console.log(tabId);
  return chrome.tabs.get(tabId, function(tab){
    console.log('tab get');
    console.log(tab);
    if (tab && !tab.selected) {
      return chrome.tabs.update(tabId, {
        selected: true
      });
    }
  });
});