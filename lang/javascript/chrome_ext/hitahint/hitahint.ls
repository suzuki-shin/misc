p = prelude

FORM_INPUT_FIELDS = 'input[type!="hidden"], textarea, select'
# CLICKABLES = 'a, input, button, textarea, select'

ITEM_TYPE_OF = {tab: 'TAB', history: 'HIS', bookmark: 'BKM', websearch: 'WEB', command: 'COM'}
SELECTOR_NUM = 20

KEY_CODE =
  START_HITAHINT: 69            # e
  FOCUS_FORM: 70                # f
  TOGGLE_SELECTOR: 186          # ;
  CANCEL: 27                    # ESC
  MOVE_NEXT_SELECTOR_CURSOR: 40 # down
  MOVE_PREV_SELECTOR_CURSOR: 38 # up
  ENTER_SELECTOR_CURSOR: 13     # ENTER
  MOVE_NEXT_FORM: 34            # pageup
  MOVE_PREV_FORM: 33            # pagedown
  BACK_HISTORY: 72              # h

_HINT_KEYS = {65:'A', 66:'B', 67:'C', 68:'D', 69:'E', 70:'F', 71:'G', 72:'H', 73:'I', 74:'J', 75:'K', 76:'L', 77:'M', 78:'N', 79:'O', 80:'P', 81:'Q', 82:'R', 83:'S', 84:'T', 85:'U', 86:'V', 87:'W', 88:'X', 89:'Y', 90:'Z'}
HINT_KEYS = {}
for k1, v1 of _HINT_KEYS
  for k2, v2 of _HINT_KEYS
    HINT_KEYS[parseInt(k1) * 100 + parseInt(k2)] = v1 + v2

WEB_SEARCH_LIST =
  {title: 'google検索', url: 'https://www.google.co.jp/#hl=ja&q=', type: 'websearch'}
  {title: 'alc辞書', url: 'http://eow.alc.co.jp/search?ref=sa&q=', type: 'websearch'}


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

# (tab|history|bookmark|,,,)のリストをうけとりそれをhtmlにしてappendする
# makeSelectorConsole :: [{title, url, type}] -> IO Jquery
makeSelectorConsole = (list) ->
  if $('#selectorList') then $('#selectorList').remove()
  console.log(list)
  ts = p.concat(
    p.take(SELECTOR_NUM,
           ['<tr id="' + t.type + '-' + t.id + '"><td><span class="title">['+ ITEM_TYPE_OF[t.type] + '] ' + t.title + ' </span><span class="url"> ' + t.url + '</span></td></tr>' for t in list]))
  $('#selectorConsole').append('<table id="selectorList">' + ts + '</table>')
  $('#selectorList tr:first').addClass("selected")

# 受け取ったテキストをスペース区切りで分割して、その要素すべてが(tab|history|bookmark)のtitleかtabのurlに含まれるtabのみ返す
# filtering :: String -> [{title, url, type}] -> [{title, url, type}]
filtering = (text, list) ->
  # queriesのすべての要素がtitleかurlに見つかるかどうかを返す
  # titleAndUrlMatch :: Elem -> [String] -> Bool
  matchP = (elem, queries) ->
    p.all(p.id, [elem.title.toLowerCase().search(q) isnt -1 or
                 elem.url.toLowerCase().search(q) isnt -1 or
                 ITEM_TYPE_OF[elem.type].toLowerCase().search(q) isnt -1 for q in queries])
  p.filter(((t) -> matchP(t, text.toLowerCase().split(' '))), list)

# 現在フォーカスがある要素がtextタイプのinputかtextareaである(文字入力可能なformの要素)かどうかを返す
# isFocusingForm :: Bool
isFocusingForm =->
  console.log('isFocusingForm')
  focusElems = $(':focus')
  console.log(focusElems.attr('type'))
  focusElems[0] and (
    (focusElems[0].nodeName.toLowerCase() == "input" and focusElems.attr('type') == "text") or
    focusElems[0].nodeName.toLowerCase() == "textarea"
  )


class Main

# 何のモードでもない状態を表すモードのクラス
class NeutralMode
  @keyMap = (e) ->
    switch e.keyCode
    case KEY_CODE.START_HITAHINT  then @@keyUpHitAHintStart()
    case KEY_CODE.FOCUS_FORM      then @@keyUpFocusForm()
    case KEY_CODE.TOGGLE_SELECTOR then @@keyUpSelectorToggle()
    case KEY_CODE.BACK_HISTORY    then @@keyUpHistoryBack()
    default (-> console.log('default'))
    e.preventDefault()

  @keyUpHitAHintStart =->
    Main.mode = HitAHintMode
    Main.links.addClass('links').html((i, oldHtml) ->
      if HINT_KEYS[indexToKeyCode(i)]?
      then '<div class="hintKey">' + HINT_KEYS[indexToKeyCode(i)] + '</div> ' + oldHtml
      else oldHtml)

  @keyUpFocusForm =->
    Main.mode = FormFocusMode
    Main.formInputFieldIndex = 0
    $(FORM_INPUT_FIELDS).eq(Main.formInputFieldIndex).focus()

  @keyUpSelectorToggle =->
    Main.mode = SelectorMode
    $('#selectorConsole').show()
    $('#selectorInput').focus()

  @keyUpHistoryBack =->
    history.back()


class HitAHintMode
  @keyMap = (e) ->
    switch e.keyCode
    case KEY_CODE.CANCEL then @@keyUpCancel()
    default @@keyUpHintKey(e.keyCode)
    e.preventDefault()

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
  @keyMap = (e) ->
    switch e.keyCode
    case KEY_CODE.MOVE_NEXT_FORM then @@keyUpFormNext()
    case KEY_CODE.MOVE_PREV_FORM then @@keyUpFormPrev()
    case KEY_CODE.CANCEL         then @@keyUpCancel()
    default (-> console.log('default'))
    e.preventDefault()

  @keyUpFormNext =->
    console.log('keyUpFormNext')
    Main.formInputFieldIndex += 1
    console.log(Main.formInputFieldIndex)
    console.log($(FORM_INPUT_FIELDS))
    console.log($(FORM_INPUT_FIELDS).eq(Main.formInputFieldIndex))
    if $(FORM_INPUT_FIELDS).eq(Main.formInputFieldIndex)?
      $(FORM_INPUT_FIELDS).eq(Main.formInputFieldIndex).focus()
#     if $(FORM_INPUT_FIELDS)[Main.formInputFieldIndex]?
#       $(FORM_INPUT_FIELDS)[Main.formInputFieldIndex].focus()

  @keyUpFormPrev =->
    console.log('keyUpFormPrev')
    Main.formInputFieldIndex -= 1
    console.log(Main.formInputFieldIndex)
    console.log($(FORM_INPUT_FIELDS))
    console.log($(FORM_INPUT_FIELDS).eq(Main.formInputFieldIndex))
    if $(FORM_INPUT_FIELDS).eq(Main.formInputFieldIndex)?
      $(FORM_INPUT_FIELDS).eq(Main.formInputFieldIndex).focus()
#     if $(FORM_INPUT_FIELDS)[Main.formInputFieldIndex]?
#       $(FORM_INPUT_FIELDS)[Main.formInputFieldIndex].focus()

  @keyUpCancel =->
    Main.mode = NeutralMode
    $(':focus').blur()

class SelectorMode
  @keyMap = (e) ->
    switch e.keyCode
    case KEY_CODE.CANCEL                    then @@keyUpCancel()
    case KEY_CODE.TOGGLE_SELECTOR           then @@keyUpSelectorToggle()
    case KEY_CODE.MOVE_NEXT_SELECTOR_CURSOR then @@keyUpSelectorCursorNext()
    case KEY_CODE.MOVE_PREV_SELECTOR_CURSOR then @@keyUpSelectorCursorPrev()
    case KEY_CODE.ENTER_SELECTOR_CURSOR     then @@keyUpSelectorCursorEnter()
    default @@keyUpSelectorFiltering()
    e.preventDefault()

  @keyUpCancel =->
    Main.mode = NeutralMode
    $('#selectorConsole').hide()
    $(':focus').blur()

  @keyUpSelectorFiltering =->
    console.log('keyUpSelectorFiltering')
    text = $('#selectorInput').val()
    console.log(text)
    list = filtering(text, Main.list).concat(WEB_SEARCH_LIST)
    console.log(list)
    makeSelectorConsole(list)
#     makeSelectorConsole(filtering(text, Main.list).concat(WEB_SEARCH_LIST))
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
    [type, id] = $('#selectorList tr.selected').attr('id').split('-')
    url = $('#selectorList tr.selected span.url').text()
    query = $('#selectorInput').val()
    @@keyUpCancel()
    chrome.extension.sendMessage(
      {mes: "keyUpSelectorCursorEnter", item:{id: id, url: url, type: type, query: query}},
      ((res) -> console.log(res)))

Main.start =->
  Main.mode = NeutralMode
  _clickables = $('a')
  Main.links = if _clickables.length is void then [_clickables] else _clickables
  if isFocusingForm() then Main.mode = FormFocusMode

  chrome.extension.sendMessage({mes: "makeSelectorConsole"}, ((list) ->
    console.log('extension.sendMessage')
    console.log(list)
    Main.list = list
    $('body').append('<div id="selectorConsole"><input id="selectorInput" type="text" /></div>')
    makeSelectorConsole(list)
  ))

  $(FORM_INPUT_FIELDS).focus(->
    console.log('form focus')
    Main.mode = FormFocusMode
  )
  $(FORM_INPUT_FIELDS).blur(->
    console.log('form blur')
    Main.mode = NeutralMode
  )

  $(document).keyup((e) ->
    console.log('keyCode: ' + e.keyCode)
    console.log('mode: ' + Main.mode)
    Main.mode.keyMap(e)
  )

Main.start()
