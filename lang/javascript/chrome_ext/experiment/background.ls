class Background

Background.tabs = []

Background.filterByInputQuery = (tabs, text) ->
  p = prelude
  matchFunc = (tab, regs) ->
    p.all(p.id, [tab.title.search(re) isnt -1 or tab.url.search(re) isnt -1 for re in regs])
#     yyy = [tab.title.search(re) isnt -1 or tab.url.search(re) isnt -1 for re in regs]
#     console.log('yyy')
#     console.log(yyy)
#     xxx = p.all(p.id, yyy)
#     console.log('tab')
#     console.log(tab)
#     console.log('xxx')
#     console.log(xxx)
#     xxx

  regs = [new RegExp(t) for t in text.split(" ")]
  console.log('regs')
  console.log(regs)
  [{content: t.title + ' ' + t.url, description: t.title + ' ' + t.url} for t in tabs when matchFunc(t, regs)]

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

chrome.omnibox.onInputEntered.addListener(((text) ->
  console.log('inputEntered: ' + text)
  alert('You just typed "' + text + '"')
))

