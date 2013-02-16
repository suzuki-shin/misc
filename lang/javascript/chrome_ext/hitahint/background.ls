tabSelect = (f, list) ->
  chrome.tabs.query({currentWindow: true}, (tabs) ->
    f(list.concat([{id: e.id, title: e.title, url: e.url, type: 'tab'} for e in tabs]))
  )

historySelect = (f, list) ->
  chrome.history.search({text:'', maxResults: 100}, (hs) ->
    console.log('hs')
    console.log(hs)
    f(list.concat([{id: e.id, title: e.title, url: e.url, type: 'history'} for e in hs]))
  )

console.log('background')

chrome.extension.onMessage.addListener((msg, sender, sendResponse) ->
  console.log(msg)
  if msg.mes == "makeSelectorConsole"
    tabSelect(((es) -> historySelect(sendResponse, es)), [])
#     tabSelect(sendResponse)
  else if msg.mes == "keyUpSelectorCursorEnter"
    console.log(msg)
    if msg.type == "tab"
      console.log('tabs.update')
      chrome.tabs.update(parseInt(msg.id), {active: true})
    else
      alert('history.update ' + msg.id)
  true
)
