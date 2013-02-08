class Background

Background.suggestList = []

chrome.omnibox.onInputStarted.addListener(->
  console.log('inputStarted:')
  listTabs = (tabs) ->
    console.log('listTabs')
    list = [{content: t.title, description: t.title} for t in tabs]
    console.log(list)
    Background.suggestList = Background.suggestList +++ list
  chrome.tabs.query({currentWindow: true}, listTabs)
)

chrome.omnibox.onInputChanged.addListener(((text, suggest) ->
  console.log('inputChanged: ' + text)

  list = [
#     {content: text + " one!", description: "the first 1"}
#     {content: text + " number two!!", description: "the 2 entry"}
#     {content: text + " number three!!!", description: "the 3 entry"}
  ]
  console.log(list)
  Background.suggestList = Background.suggestList +++ list
  console.log(Background.suggestList)
  suggest(Background.suggestList)

#   suggest([
#     {content: text + " one!", description: "the first 1"}
#     {content: text + " number two!!", description: "the 2 entry"}
#   ])
))

chrome.omnibox.onInputEntered.addListener(((text) ->
  console.log('inputEntered: ' + text)
  alert('You just typed "' + text + '"')
))

