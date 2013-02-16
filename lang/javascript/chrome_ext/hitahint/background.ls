tabSelect = (f, list) ->
  chrome.tabs.query({currentWindow: true}, (tabs) ->
    f(list.concat([{id: e.id, title: e.title, url: e.url, type: 'tab'} for e in tabs]))
  )

historySelect = (f, list) ->
  chrome.history.search({text:'', maxResults: 100}, (hs) ->
    f(list.concat([{id: e.id, title: e.title, url: e.url, type: 'history'} for e in hs]))
  )

bookmarkSelect = (f, list) ->
  chrome.bookmarks.search("h", (es) ->
    f(list.concat([{id: e.id, title: e.title, url: e.url, type: 'bookmark'} for e in es when e.url?]))
  )

console.log('background')

chrome.extension.onMessage.addListener((msg, sender, sendResponse) ->
  console.log(msg)
  if msg.mes == "makeSelectorConsole"
    bookmarkSelect_ = (list) -> bookmarkSelect(sendResponse, list)
    historySelect_ = (list) -> historySelect(bookmarkSelect_, list)
    tabSelect(historySelect_, [])
  else if msg.mes == "keyUpSelectorCursorEnter"
    console.log(msg)
    if msg.item.type == "tab"
      console.log('tabs.update')
      chrome.tabs.update(parseInt(msg.item.id), {active: true})
    else
      chrome.tabs.create({url: msg.item.url})
  true
)
