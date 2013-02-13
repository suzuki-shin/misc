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
  if (msg.mes === "makeSelectorConsole") {
    tabSelect(sendResponse);
  } else if (msg.mes === "keyUpSelectorCursorEnter") {
    console.log('tabs.update');
    console.log(msg);
    chrome.tabs.update(parseInt(msg.tabId), {
      active: true
    });
  }
  return true;
});