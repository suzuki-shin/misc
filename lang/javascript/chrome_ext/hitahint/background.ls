tabSelect = (f) ->
  chrome.tabs.query({currentWindow: true}, (tabs) ->
    console.log(tabs)
    f(tabs)
  )

console.log('background')

chrome.extension.onMessage.addListener((msg, sender, sendResponse) ->
  console.log(msg)
#   sendResponse(msg.mes + "---")
  tabSelect(sendResponse)
  true
)