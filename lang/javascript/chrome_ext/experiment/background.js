chrome.omnibox.onInputChanged.addListener(function(text, suggest){
  var list;
  console.log('inputChanged: ' + text);
  list = [
    {
      content: text + " one!",
      description: "the first 1"
    }, {
      content: text + " number two!!",
      description: "the 2 entry"
    }, {
      content: text + " number three!!!",
      description: "the 3 entry"
    }
  ];
  return suggest(list);
});
chrome.omnibox.onInputEntered.addListener(function(text){
  console.log('inputEntered: ' + text);
  return alert('You just typed "' + text + '"');
});