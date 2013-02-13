var tabSelect;
tabSelect = function(f){
  return chrome.tabs.query({
    currentWindow: true
  }, function(tabs){
    console.log(tabs);
    return f(tabs);
  });
};
console.log('background');
chrome.extension.onMessage.addListener(function(msg, sender, sendResponse){
  console.log(msg);
  tabSelect(sendResponse);
  return true;
});