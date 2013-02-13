console.log('hitahint')

KEY_CODE_HITAHINT_START = 69
KEY_CODE_FOCUS_FORM = 70
KEY_CODE_CANCEL = 27
KEY_CODE_SELECTOR_START = 187


_HINT_KEYS = {65:'a', 66:'b', 67:'c', 68:'d', 69:'e', 70:'f', 71:'g', 72:'h', 73:'i', 74:'j', 75:'k', 76:'l', 77:'m', 78:'n', 79:'o', 80:'p', 81:'q', 82:'r', 83:'s', 84:'t', 85:'u', 86:'v', 87:'w', 88:'x', 89:'y', 90:'z'}
HINT_KEYS = {}
for k1, v1 of _HINT_KEYS
  for k2, v2 of _HINT_KEYS
    HINT_KEYS[parseInt(k1) * 100 + parseInt(k2)] = v1 + v2

keyCodeToIndex = (firstKeyCode, secondKeyCode) ->
  $.inArray(parseInt(firstKeyCode) * 100 + parseInt(secondKeyCode), [parseInt(k) for k,v of HINT_KEYS])

indexToKeyCode = (index) -> [k for k,v of HINT_KEYS][index]

isHitAHintKey = (keyCode) ->
  $.inArray(String(keyCode), [k for k,v of _HINT_KEYS]) isnt -1

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
  @keyUpOthers =-> false

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

  @keyUpOthers =-> false

class FormFocusMode
  @keyUpHitAHintStart =-> false
  @keyUpFocusForm =-> false

  @keyUpCancel =->
    Main.mode = NeutralMode
    $(':focus').blur()

  @keyUpHintKey = (keyCode) -> false
  @keyUpOthers =-> false

$(->
  Main.mode = NeutralMode
  Main.links = if $('a').length is undefined then [$('a')] else $('a')

  $('input, textarea').focus(->
    console.log('form focus')
    Main.mode = FormFocusMode
  )
  $('input, textarea').blur(->
    console.log('form blur')
    Main.mode = NeutralMode
  )

  $(document).keyup((e) ->
    console.log('keyCode: ' + e.keyCode)
    console.log('mode: ' + Main.mode)

    if e.keyCode == KEY_CODE_HITAHINT_START
      Main.mode.keyUpHitAHintStart()
    else if e.keyCode == KEY_CODE_FOCUS_FORM
      Main.mode.keyUpFocusForm()
    else if e.keyCode == KEY_CODE_CANCEL
      Main.mode.keyUpCancel()
    else if isHitAHintKey(e.keyCode)
      Main.mode.keyUpHintKey(e.keyCode)
    else
      Main.mode.keyUpOthers()
  )
)