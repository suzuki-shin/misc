var Background;
Background = (function(){
  Background.displayName = 'Background';
  var prototype = Background.prototype, constructor = Background;
  function Background(){}
  return Background;
}());
Background.suggestList = [];
chrome.omnibox.onInputStarted.addListener(function(){
  var listTabs;
  console.log('inputStarted:');
  listTabs = function(tabs){
    var list, res$, i$, len$, t;
    console.log('listTabs');
    res$ = [];
    for (i$ = 0, len$ = tabs.length; i$ < len$; ++i$) {
      t = tabs[i$];
      res$.push({
        content: t.title,
        description: t.title
      });
    }
    list = res$;
    console.log(list);
    return Background.suggestList = Background.suggestList.concat(list);
  };
  return chrome.tabs.query({
    currentWindow: true
  }, listTabs);
});
chrome.omnibox.onInputChanged.addListener(function(text, suggest){
  var list;
  console.log('inputChanged: ' + text);
  list = [{
    content: text + " one!",
    description: "the first 1"
  }];
  console.log(list);
  Background.suggestList = Background.suggestList.concat(list);
  console.log(Background.suggestList);
  return suggest(Background.suggestList);
});
chrome.omnibox.onInputEntered.addListener(function(text){
  console.log('inputEntered: ' + text);
  return alert('You just typed "' + text + '"');
});