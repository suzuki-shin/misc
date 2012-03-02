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




###
# event
###
$ ->
  $(document).on 'change', '#selectFile', selectFile
