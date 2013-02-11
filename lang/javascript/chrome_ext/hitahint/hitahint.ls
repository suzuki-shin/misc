console.log('hitahint')

KEY_CODE_HITAHINT_START = 69
KEY_CODE_FOCUS_FORM = 70
KEY_CODE_CANCEL = 27

HINT_KEYS =
  65:'a'
  66:'b'
  67:'c'
  68:'d'
  69:'e'
  70:'f'
  71:'g'
  72:'h'
  73:'i'
  74:'j'
  75:'k'
  76:'l'
  77:'m'
  78:'n'
  79:'o'
  80:'p'
  81:'q'
  82:'r'
  83:'s'
  84:'t'
  85:'u'


keyCodeToIndex = (keyCode) -> keyCode - 65
indexToKeyCode = (index) -> index + 65
isHitAHintKey = (keyCode) ->
  $.inArray(String(keyCode), [k for k,v of HINT_KEYS]) isnt -1

class Main

class NewtralMode

NewtralMode.keyUpHitAHintStart =->
  Main.mode = HitAHintMode
  $('a').addClass('links').html((i, oldHtml) ->
    if HINT_KEYS[indexToKeyCode(i)]?
    then '<div class="hintKey">' + HINT_KEYS[indexToKeyCode(i)] + '</div> ' + oldHtml
    else oldHtml)

NewtralMode.keyUpFocusForm =->
  Main.mode = FormFocusMode
  $('input, textarea')[0].focus()

NewtralMode.keyUpCancel =-> false
NewtralMode.keyUpHintKey = (keyCode) -> false
NewtralMode.keyUpOthers =-> false

class HitAHintMode

HitAHintMode.keyUpHitAHintStart =-> false
HitAHintMode.keyUpFocusForm =-> false

HitAHintMode.keyUpCancel =->
  Main.mode = NewtralMode
  $('a').removeClass('links')
  $('.hintKey').remove()

HitAHintMode.keyUpHintKey = (keyCode) ->
  console.log('hit!: ' + keyCode)
  $('a')[keyCodeToIndex(keyCode)].click()
  Main.mode = NewtralMode
  $('a').removeClass('links')
  $('.hintKey').remove()

HitAHintMode.keyUpOthers =-> false

class FormFocusMode

FormFocusMode.keyUpHitAHintStart =-> console.log('')
FormFocusMode.keyUpFocusForm =-> console.log('')

FormFocusMode.keyUpCancel =->
  Main.mode = NewtralMode
  $(':focus').blur()

FormFocusMode.keyUpHintKey = (keyCode) -> false
FormFocusMode.keyUpOthers =-> false

$(->
  Main.mode = NewtralMode

  $('input, textarea').focus(-> Main.mode = FormFocusMode)

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