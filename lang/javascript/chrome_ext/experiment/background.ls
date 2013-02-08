class Background

# Background.suggests = []
Background.tabs = []

Background.filterByInputQuery = (tabs, text) ->
  re = new RegExp(text)
  console.log('re')
  console.log(re)
#   [{content: t.title + ' ' + t.url, description: t.title + ' ' + t.url} for t in tabs if t.url.search(re) isnt -1]

  filtered = []
  for t in tabs
    console.log('tab')
    console.log(t)
    if (t.url.search(re) isnt -1) or (t.title.search(re) isnt -1)
      console.log(t.url)
      filtered.push({content: t.title + ' ' + t.url, description: t.title + ' ' + t.url})
  filtered

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

