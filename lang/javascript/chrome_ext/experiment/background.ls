chrome.omnibox.onInputChanged.addListener(((text, suggest) ->
  console.log('inputChanged: ' + text)

#   chrome.tabs.query({currentWindow: true}, listTabs)

#   listTabs = (tabs) ->
#     list = [{content: text, description: t.title} for t in tabs]
#     console.log(list)
#     suggest(list)

  list = [
    {content: text + " one!", description: "the first 1"}
    {content: text + " number two!!", description: "the 2 entry"}
    {content: text + " number three!!!", description: "the 3 entry"}
  ]
  suggest(list)
#   suggest([
#     {content: text + " one!", description: "the first 1"}
#     {content: text + " number two!!", description: "the 2 entry"}
#   ])
))

chrome.omnibox.onInputEntered.addListener(((text) ->
  console.log('inputEntered: ' + text)
  alert('You just typed "' + text + '"')
))

