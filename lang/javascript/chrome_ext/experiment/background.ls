class Background

Background.tabs = []

Background.filterByInputQuery = (tabs, text) ->
  p = prelude
  matchFunc = (tab, regs) ->
    p.all(p.id, [tab.title.search(re) isnt -1 or tab.url.search(re) isnt -1 for re in regs])

  regs = [new RegExp(t) for t in text.split(" ")]
  console.log('regs')
  console.log(regs)
  [{content: t.url, description: t.title + ' ' + t.url} for t in tabs when matchFunc(t, regs)]

chrome.omnibox.onInputStarted.addListener(->
  console.log('inputStarted:')
  listTabs = (tabs) ->
    console.log('listTabs')
    console.log(tabs)
    Background.tabs = tabs
  chrome.tabs.query({}, listTabs)
)

chrome.omnibox.onInputChanged.addListener(((text, suggest) ->
  console.log('inputChanged: ' + text)

  matchTabs = Background.filterByInputQuery(Background.tabs, text)
  console.log('matchTabs')
  console.log(matchTabs)
  suggest(matchTabs)
))

chrome.omnibox.onInputEntered.addListener(((url) ->
  console.log('inputEntered: ' + url)
  _tabIds = [t.id for t in Background.tabs when t.url == url]
  return if _tabIds == []

  tabId = _tabIds[0]
  console.log(tabId)
  chrome.tabs.get(tabId, ((tab) ->
    console.log('tab get')
    console.log(tab)
    if tab && not tab.selected
      chrome.tabs.update(tabId, { selected: true })
  ))
))
