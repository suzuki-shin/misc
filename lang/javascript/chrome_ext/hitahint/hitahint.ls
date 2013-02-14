console.log('hitahint')

p = prelude

_HINT_KEYS = {65:'A', 66:'B', 67:'C', 68:'D', 69:'E', 70:'F', 71:'G', 72:'H', 73:'I', 74:'J', 75:'K', 76:'L', 77:'M', 78:'N', 79:'O', 80:'P', 81:'Q', 82:'R', 83:'S', 84:'T', 85:'U', 86:'V', 87:'W', 88:'X', 89:'Y', 90:'Z'}
HINT_KEYS = {}
for k1, v1 of _HINT_KEYS
  for k2, v2 of _HINT_KEYS
    HINT_KEYS[parseInt(k1) * 100 + parseInt(k2)] = v1 + v2

keyCodeToIndex = (firstKeyCode, secondKeyCode) ->
  $.inArray(parseInt(firstKeyCode) * 100 + parseInt(secondKeyCode), [parseInt(k) for k,v of HINT_KEYS])

indexToKeyCode = (index) -> [k for k,v of HINT_KEYS][index]

isHitAHintKey = (keyCode) ->
  $.inArray(String(keyCode), [k for k,v of _HINT_KEYS]) isnt -1

makeSelectorConsole = (tabs) ->
  if $('#selectorList') then $('#selectorList').remove()
  console.log(tabs)
  ts = p.concat(['<tr id="' + t.id + '"><td>' + t.title + '</td></tr>' for t in tabs])
  $('#selectorConsole').append('<table id="selectorList">' + ts + '</table>')
  $('#selectorList tr:first').addClass("selected")

filteringTabs = (text, tabs) ->
  p.filter(((t) -> t.title.search(text) isnt -1), tabs)

isFocusingForm =->
  focusElems = $(':focus')
  console.log(focusElems.attr('type'))
  focusElems[0] and (
    (focusElems[0].nodeName.toLowerCase() == "input" and focusElems.attr('type') == "text") or
    focusElems[0].nodeName.toLowerCase() == "textarea"
  )

class Main

class NeutralMode
  @keyMap = (keyCode) ->
    switch keyCode
    case 69 then @@keyUpHitAHintStart()
    case 70 then @@keyUpFocusForm()
    case 186 then @@keyUpSelectorToggle()
    default (-> console.log('default'))

  @keyUpHitAHintStart =->
    Main.mode = HitAHintMode
    Main.links.addClass('links').html((i, oldHtml) ->
      if HINT_KEYS[indexToKeyCode(i)]?
      then '<div class="hintKey">' + HINT_KEYS[indexToKeyCode(i)] + '</div> ' + oldHtml
      else oldHtml)

  @keyUpFocusForm =->
    Main.mode = FormFocusMode
    $('input, textarea')[0].focus()

  @keyUpSelectorToggle =->
    Main.mode = SelectorMode
    $('#selectorConsole').show()
    $('#selectorInput').focus()


class HitAHintMode
  @keyMap = (keyCode) ->
    switch keyCode
    case 27 then @@keyUpCancel()
    default @@keyUpHintKey(keyCode)

  @firstKeyCode = null

  @keyUpCancel =->
    Main.mode = NeutralMode
    Main.links.removeClass('links')
    $('.hintKey').remove()

  @keyUpHintKey = (keyCode) ->
    console.log('hit!: ' + keyCode + ', 1stkey: ' + @firstKeyCode)
    if not isHitAHintKey(keyCode)
      console.log('not isHitAHintKey')
      console.log(isHitAHintKey(keyCode))
      return

    if @firstKeyCode is null
      @firstKeyCode = keyCode
    else
      idx = keyCodeToIndex(@firstKeyCode,  keyCode)
      console.log('idx: ' + idx)
      console.log(Main.links)
      Main.links[idx].click()
      Main.mode = NeutralMode
      Main.links.removeClass('links')
      $('.hintKey').remove()
      @firstKeyCode = null


class FormFocusMode
  @keyMap = (keyCode) ->
    switch keyCode
    case 27 then @@keyUpCancel()
    default (-> console.log('default'))

  @keyUpCancel =->
    Main.mode = NeutralMode
    $(':focus').blur()

class SelectorMode
  @keyMap = (keyCode) ->
    switch keyCode
    case 27 then @@keyUpCancel()
    case 186 then @@keyUpSelectorToggle()
    case 40 then @@keyUpSelectorCursorNext()
    case 38 then @@keyUpSelectorCursorPrev()
    case 13 then @@keyUpSelectorCursorEnter()
    default @@keyUpOthers()

  @keyUpCancel =->
    Main.mode = NeutralMode
    $('#selectorConsole').hide()
    $(':focus').blur()

  @keyUpOthers =->
    console.log('keyUpOthers')
    text = $('#selectorInput').val()
    console.log(text)
    makeSelectorConsole(filteringTabs(text, Main.tabs))
    $('#selectorConsole').show()

  @keyUpSelectorToggle =->
    Main.mode = NeutralMode
    $('#selectorConsole').hide()

  @keyUpSelectorCursorNext =->
    console.log('keyUpSelectorCursorNext')
    $('#selectorList .selected').removeClass("selected").next("tr").addClass("selected")

  @keyUpSelectorCursorPrev =->
    console.log('keyUpSelectorCursorPrev')
    $('#selectorList .selected').removeClass("selected").prev("tr").addClass("selected")

  @keyUpSelectorCursorEnter =->
    console.log('keyUpSelectorCursorEnter')
    tabId = $('#selectorList tr.selected').attr('id')
    console.log(tabId)
    chrome.extension.sendMessage({mes: "keyUpSelectorCursorEnter", tabId: tabId}, ((res) -> console.log(res)))

$(->
  Main.mode = NeutralMode
  Main.links = if $('a').length is void then [$('a')] else $('a')
  if isFocusingForm() then Main.mode = FormFocusMode

  chrome.extension.sendMessage({mes: "makeSelectorConsole"}, ((tabs) ->
    Main.tabs = tabs
    $('body').append('<div id="selectorConsole"><input id="selectorInput" type="text" /></div>')
    makeSelectorConsole(tabs)
  ))

  $('input[type="text"], textarea').focus(->
    console.log('form focus')
    Main.mode = FormFocusMode
  )
  $('input[type="text"], textarea').blur(->
    console.log('form blur')
    Main.mode = NeutralMode
  )

  $(document).keyup((e) ->
    console.log('keyCode: ' + e.keyCode)
    console.log('mode: ' + Main.mode)

    Main.mode.keyMap(e.keyCode)
  )
)