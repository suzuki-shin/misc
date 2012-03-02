global = this

global.ftoh = (str) ->
  (fullchar2halfchar(c) for c in str).join('')


fullchar2halfchar = (char) ->
  if @table[char]? then @table[char] else char


selectFile = (ev) ->
  file = ev.target.files[0]

  reader = new FileReader()
  reader.readAsText(file)

  reader.onload = (ev) ->
#     textData = reader.result
#     alert textData
#     alert global.ftoh(textData)

    # downloadリンクを表示してそこからデータをDLさせる
    $('#download-link').attr('href', "data:application/octet-stream," + encodeURIComponent(global.ftoh(reader.result)))
    $('#download-link').show()

    # データ表示エリアに表示する
    $('#data-area').empty().append(global.ftoh(reader.result))

  reader.onerror = (ev) ->
    alert 'error'


_drop = (files) ->
  console?.log '_drop'
  reader = new FileReader()
  for f in files
    reader.readAsText(f)
    reader.onload =->
      $('#data-area').empty().append(global.ftoh(reader.result))

drop = (e) ->
  console?.log 'drop'
  if e.preventDefault
    e.preventDefault()
  _drop e.originalEvent.dataTransfer.files

###
# event
###
$ ->
  $(document).on 'change', '#selectFile', selectFile

  $("body").bind "drop", drop
  $("body").bind "dragenter", -> console?.log 'aaa'; false
  $("body").bind "dragover", -> console?.log 'bbb'; false
