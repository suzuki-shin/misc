console.log('hitahint')

KEY_CODE_HITAHINT_START = 69
KEY_CODE_FOCUS_FORM = 70
KEY_CODE_CANCEL = 27

MODE_NEWTRAL = 0
MODE_HITAHINT = 1
MODE_FORM_FOCUS = 2

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

# HINT_KEYS = [
#   'aa', 'ab', 'ac', 'ad', 'ae', 'af',
#   'ba', 'bb', 'bc', 'bd', 'be', 'bf',
#   'ca', 'cb', 'cc', 'cd', 'ce', 'cf',
#   'da', 'db', 'dc', 'dd', 'de', 'df',
#   'ea', 'eb', 'ec', 'ed', 'ee', 'ef',
# ]

class Main

$(->
  HINT_KEYS_LENGTH = HINT_KEYS.length
  links = $('a')
  Main.mode = MODE_NEWTRAL

  $(document).keyup((e) ->
    console.log(e.keyCode)
    console.log(Main.mode)

    if Main.mode == MODE_NEWTRAL
      if e.keyCode == KEY_CODE_HITAHINT_START
        Main.mode = MODE_HITAHINT
        links.addClass('links').html((i, oldHtml) ->
          if HINT_KEYS[i+65]?
          then
            console.log(HINT_KEYS[i+65])
            '<div class="hintKey">' + HINT_KEYS[i+65] + '</div> ' + oldHtml
          else oldHtml)
      else if e.keyCode == KEY_CODE_FOCUS_FORM
        Main.mode = MODE_FORM_FOCUS
        $('input, textarea')[0].focus()

    else if Main.mode == MODE_HITAHINT
      if e.keyCode == KEY_CODE_CANCEL
        Main.mode = MODE_NEWTRAL
        links.removeClass('links')
        $('.hintKey').remove();
      else if $.inArray(e, [k for k,v of HINT_KEYS]) isnt -1
        console.log('hit!: ' + e.keyCode)
      else
        console.log(e)
        console.log('mum')

    else if Main.mode == MODE_FORM_FOCUS
      if e.keyCode == KEY_CODE_CANCEL
        $(':focus').blur()
        Main.mode = MODE_NEWTRAL

    else
      console.log('else')
  )
)