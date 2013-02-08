var Background;
Background = (function(){
  Background.displayName = 'Background';
  var prototype = Background.prototype, constructor = Background;
  function Background(){}
  return Background;
}());
Background.tabs = [];
Background.filterByInputQuery = function(tabs, text){
  var re, filtered, i$, len$, t;
  re = new RegExp(text);
  console.log('re');
  console.log(re);
  filtered = [];
  for (i$ = 0, len$ = tabs.length; i$ < len$; ++i$) {
    t = tabs[i$];
    console.log('tab');
    console.log(t);
    if (t.url.search(re) !== -1) {
      console.log(t.url);
      filtered.push({
        content: t.title + ' ' + t.url,
        description: t.title + ' ' + t.url
      });
    }
  }
  return filtered;
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
chrome.omnibox.onInputEntered.addListener(function(text){
  console.log('inputEntered: ' + text);
  return alert('You just typed "' + text + '"');
});