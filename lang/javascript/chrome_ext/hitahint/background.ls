tabSelect = (f) ->
  chrome.tabs.query({currentWindow: true}, (tabs) ->
    console.log(tabs)
    f(tabs)
  )

console.log('background')

chrome.extension.onMessage.addListener((msg, sender, sendResponse) ->
  console.log(msg)
#   sendResponse(msg.mes + "---")
  if msg.mes == "makeSelectorConsole"
    tabSelect(sendResponse)
  else if msg.mes == "keyUpSelectorCursorEnter"
    console.log('tabs.update')
    console.log(msg)
    chrome.tabs.update(parseInt(msg.tabId), {active: true})
  true
)
