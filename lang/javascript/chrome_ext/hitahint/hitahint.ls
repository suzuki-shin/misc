console.log('hitahint')

p = prelude

KEY_CODE_HITAHINT_START = 69
KEY_CODE_FOCUS_FORM = 70
KEY_CODE_CANCEL = 27
KEY_CODE_SELECTOR_TOGGLE = 186
KEY_CODE_SELECTOR_CURSOR_NEXT = 40
KEY_CODE_SELECTOR_CURSOR_PREV = 38
KEY_CODE_SELECTOR_CURSOR_ENTER = 13


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
  @keyUpHitAHintStart =->
    Main.mode = HitAHintMode
    Main.links.addClass('links').html((i, oldHtml) ->
      if HINT_KEYS[indexToKeyCode(i)]?
      then '<div class="hintKey">' + HINT_KEYS[indexToKeyCode(i)] + '</div> ' + oldHtml
      else oldHtml)

  @keyUpFocusForm =->
    Main.mode = FormFocusMode
    $('input, textarea')[0].focus()

  @keyUpCancel =-> false
  @keyUpHintKey = (keyCode) -> false

  @keyUpSelectorToggle =->
    Main.mode = SelectorMode
    $('#selectorConsole').show()
    $('#selectorInput').focus()

  @keyUpOthers =-> false
#   @keyUpAny = (keyCode) -> false


class HitAHintMode
  @firstKeyCode = null

  @keyUpHitAHintStart =-> false
  @keyUpFocusForm =-> false

  @keyUpCancel =->
    Main.mode = NeutralMode
    Main.links.removeClass('links')
    $('.hintKey').remove()

  @keyUpHintKey = (keyCode) ->
    console.log('hit!: ' + keyCode + ', 1stkey: ' + @firstKeyCode)
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

  @keyUpSelectorToggle =-> false
  @keyUpOthers =-> false

class FormFocusMode
  @keyUpHitAHintStart =-> false
  @keyUpFocusForm =-> false

  @keyUpCancel =->
    Main.mode = NeutralMode
    $(':focus').blur()

  @keyUpHintKey = (keyCode) -> false
  @keyUpSelectorToggle =-> false
  @keyUpOthers =-> false

class SelectorMode
  @keyUpHitAHintStart =-> @keyUpOthers()
  @keyUpFocusForm =-> @keyUpOthers()

  @keyUpCancel =->
    Main.mode = NeutralMode
    $('#selectorConsole').hide()
    $(':focus').blur()

  @keyUpHintKey =->  @keyUpOthers()
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

    if e.keyCode == KEY_CODE_HITAHINT_START
      console.log('KEY_CODE_HITAHINT_START')
      Main.mode.keyUpHitAHintStart()
    else if e.keyCode == KEY_CODE_FOCUS_FORM
      console.log('KEY_CODE_FOCUS_FORM')
      Main.mode.keyUpFocusForm()
    else if e.keyCode == KEY_CODE_CANCEL
      console.log('KEY_CODE_CANCEL')
      Main.mode.keyUpCancel()
    else if e.keyCode == KEY_CODE_SELECTOR_TOGGLE
      console.log('KEY_CODE_SELECTOR_TOGGLE')
      Main.mode.keyUpSelectorToggle()
    else if e.keyCode == KEY_CODE_SELECTOR_CURSOR_NEXT
      console.log('KEY_CODE_SELECTOR_CURSOR_NEXT')
      Main.mode.keyUpSelectorCursorNext(e.keyCode)
    else if e.keyCode == KEY_CODE_SELECTOR_CURSOR_PREV
      console.log('KEY_CODE_SELECTOR_CURSOR_PREV')
      Main.mode.keyUpSelectorCursorPrev(e.keyCode)
    else if e.keyCode == KEY_CODE_SELECTOR_CURSOR_ENTER
      console.log('KEY_CODE_SELECTOR_CURSOR_ENTER')
      Main.mode.keyUpSelectorCursorEnter()
    else if isHitAHintKey(e.keyCode)
      console.log('KEY_CODE_HIT_HINT')
      Main.mode.keyUpHintKey(e.keyCode)
    else
      console.log('KEY_CODE_DEFAULT')
      Main.mode.keyUpOthers()

#     switch
#     case e.keyCode == KEY_CODE_HITAHINT_START
#       console.log('KEY_CODE_HITAHINT_START')
#       if Main.mode.keyUpHitAHintStart() then break
#       fallthrough
#     case e.keyCode == KEY_CODE_FOCUS_FORM
#       console.log('KEY_CODE_FOCUS_FORM')
#       if Main.mode.keyUpFocusForm() then break
#       fallthrough
#     case e.keyCode == KEY_CODE_CANCEL
#       console.log('KEY_CODE_CANCEL')
#       if Main.mode.keyUpCancel() then break
#       fallthrough
#     case e.keyCode == KEY_CODE_SELECTOR_TOGGLE
#       console.log('KEY_CODE_SELECTOR_TOGGLE')
#       if Main.mode.keyUpSelectorToggle() then break
#       fallthrough
#     case e.keyCode == KEY_CODE_SELECTOR_CURSOR_NEXT
#       console.log('KEY_CODE_SELECTOR_CURSOR_NEXT')
#       if Main.mode.keyUpSelectorCursorNext(e.keyCode) then break
#       fallthrough
#     case e.keyCode == KEY_CODE_SELECTOR_CURSOR_PREV
#       console.log('KEY_CODE_SELECTOR_CURSOR_PREV')
#       if Main.mode.keyUpSelectorCursorPrev(e.keyCode) then break
#       fallthrough
#     case e.keyCode == KEY_CODE_SELECTOR_CURSOR_ENTER
#       console.log('KEY_CODE_SELECTOR_CURSOR_ENTER')
#       if Main.mode.keyUpSelectorCursorEnter() then break
#       fallthrough
#     case isHitAHintKey(e.keyCode)
#       console.log('KEY_CODE_HIT_HINT')
#       if Main.mode.keyUpHintKey(e.keyCode) then break
#       fallthrough
#     default
#       console.log('KEY_CODE_DEFAULT')
#       Main.mode.keyUpOthers()
  )
)