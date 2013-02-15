p = prelude

KEY_CODE =
  'START_HITAHINT': 69          # e
  'FOCUS_FORM': 70              # f
  'TOGGLE_SELECTOR': 186        # ;
  'CANCEL': 27                  # ESC
  'MOVE_NEXT_SELECTOR_CURSOR': 40 # down
  'MOVE_PREV_SELECTOR_CURSOR': 38 # up
  'ENTER_SELECTOR_CURSOR': 13     # ENTER

_HINT_KEYS = {65:'A', 66:'B', 67:'C', 68:'D', 69:'E', 70:'F', 71:'G', 72:'H', 73:'I', 74:'J', 75:'K', 76:'L', 77:'M', 78:'N', 79:'O', 80:'P', 81:'Q', 82:'R', 83:'S', 84:'T', 85:'U', 86:'V', 87:'W', 88:'X', 89:'Y', 90:'Z'}
HINT_KEYS = {}
for k1, v1 of _HINT_KEYS
  for k2, v2 of _HINT_KEYS
    HINT_KEYS[parseInt(k1) * 100 + parseInt(k2)] = v1 + v2

# 打ったHintKeyの一打目と二打目のキーコードをうけとり、それに対応するクリック要素のインデックスを返す
# keyCodeToIndex :: Int -> Int -> Int
keyCodeToIndex = (firstKeyCode, secondKeyCode) ->
  $.inArray(parseInt(firstKeyCode) * 100 + parseInt(secondKeyCode), [parseInt(k) for k,v of HINT_KEYS])

# インデックスを受取り、HintKeyのリストの中から対応するキーコードを返す
# indexToKeyCode :: Int -> String
indexToKeyCode = (index) -> [k for k,v of HINT_KEYS][index]

# キーコードを受取り、それがHintKeyかどうかを返す
# isHitAHintKey :: Int -> Bool
isHitAHintKey = (keyCode) ->
  $.inArray(String(keyCode), [k for k,v of _HINT_KEYS]) isnt -1

# tabのリストをうけとりそれをhtmlにしてappendする
# makeSelectorConsole :: [Tab] -> IO Jquery
makeSelectorConsole = (tabs) ->
  if $('#selectorList') then $('#selectorList').remove()
  console.log(tabs)
  ts = p.concat(['<tr id="' + t.id + '"><td><span class="tabTitle">' + t.title + ' </span><span class="tabUrl"> ' + t.url + '</span></td></tr>' for t in tabs])
  $('#selectorConsole').append('<table id="selectorList">' + ts + '</table>')
  $('#selectorList tr:first').addClass("selected")

# 受け取ったテキストをスペース区切りで分割して、その要素すべてがtabのtitleかtabのurlに含まれるtabのみ返す
# filteringTabs :: String -> [Tab] -> [Tab]
filteringTabs = (text, tabs) ->
  # queriesのすべての要素がtabのtitleかtabのurlに見つかるかどうかを返す
  # titleAndUrlMatch :: Tab -> [String] -> Bool
  titleAndUrlMatch = (tab, queries) ->
    p.all(p.id, [tab.title.toLowerCase().search(q) isnt -1 or tab.url.toLowerCase().search(q) isnt -1 for q in queries])
  p.filter(((t) -> titleAndUrlMatch(t, text.split(' '))), tabs)

# 現在フォーカスがある要素がtextタイプのinputかtextareaである(文字入力可能なformの要素)かどうかを返す
# isFocusingForm :: Bool
isFocusingForm =->
  focusElems = $(':focus')
  console.log(focusElems.attr('type'))
  focusElems[0] and (
    (focusElems[0].nodeName.toLowerCase() == "input" and focusElems.attr('type') == "text") or
    focusElems[0].nodeName.toLowerCase() == "textarea"
  )


class Main

# 何のモードでもない状態を表すモードのクラス
class NeutralMode
  @keyMap = (keyCode) ->
    switch keyCode
    case KEY_CODE.START_HITAHINT  then @@keyUpHitAHintStart()
    case KEY_CODE.FOCUS_FORM      then @@keyUpFocusForm()
    case KEY_CODE.TOGGLE_SELECTOR then @@keyUpSelectorToggle()
    default (-> console.log('default'))

  @keyUpHitAHintStart =->
    Main.mode = HitAHintMode
    Main.links.addClass('links').html((i, oldHtml) ->
      if HINT_KEYS[indexToKeyCode(i)]?
      then '<div class="hintKey">' + HINT_KEYS[indexToKeyCode(i)] + '</div> ' + oldHtml
      else oldHtml)

  @keyUpFocusForm =->
    Main.mode = FormFocusMode
    $('input[type="text"], textarea')[0].focus()

  @keyUpSelectorToggle =->
    Main.mode = SelectorMode
    $('#selectorConsole').show()
    $('#selectorInput').focus()


class HitAHintMode
  @keyMap = (keyCode) ->
    switch keyCode
    case KEY_CODE.CANCEL then @@keyUpCancel()
    default @@keyUpHintKey(keyCode)

  @firstKeyCode = null

  @keyUpCancel =->
    Main.mode = NeutralMode
    Main.links.removeClass('links')
    $('.hintKey').remove()

  @keyUpHintKey = (keyCode) ->
    console.log('hit!: ' + keyCode + ', 1stkey: ' + @firstKeyCode)
    return if not isHitAHintKey(keyCode)

    if @firstKeyCode is null
      @firstKeyCode = keyCode
    else
      idx = keyCodeToIndex(@firstKeyCode,  keyCode)
      Main.links[idx].click()
      Main.mode = NeutralMode
      Main.links.removeClass('links')
      $('.hintKey').remove()
      @firstKeyCode = null


class FormFocusMode
  @keyMap = (keyCode) ->
    switch keyCode
    case KEY_CODE.CANCEL then @@keyUpCancel()
    default (-> console.log('default'))

  @keyUpCancel =->
    Main.mode = NeutralMode
    $(':focus').blur()

class SelectorMode
  @keyMap = (keyCode) ->
    switch keyCode
    case KEY_CODE.CANCEL                    then @@keyUpCancel()
    case KEY_CODE.TOGGLE_SELECTOR           then @@keyUpSelectorToggle()
    case KEY_CODE.MOVE_NEXT_SELECTOR_CURSOR then @@keyUpSelectorCursorNext()
    case KEY_CODE.MOVE_PREV_SELECTOR_CURSOR then @@keyUpSelectorCursorPrev()
    case KEY_CODE.ENTER_SELECTOR_CURSOR     then @@keyUpSelectorCursorEnter()
    default @@keyUpSelectorFiltering()

  @keyUpCancel =->
    Main.mode = NeutralMode
    $('#selectorConsole').hide()
    $(':focus').blur()

  @keyUpSelectorFiltering =->
    console.log('keyUpSelectorFiltering')
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
    @@keyUpCancel()
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