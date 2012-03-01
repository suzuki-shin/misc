glbal = this

glbal.ftoh = (str) ->
  (fullchar2halfchar(c) for c in str).join('')

fullchar2halfchar = (char) ->
  if @table[char]? then @table[char] else char

# file api
selectFile = (ev) ->
  file = ev.target.files[0]
  alert file.name + ' is selected!'

  reader = new FileReader()
  reader.readAsText(file)

  reader.onload = (ev) ->
    console.log 'readeronload'
    textData = reader.result
    alert textData
    alert glbal.ftoh(textData)
    console.log textData.split("\n")
    file_name = (file.name.match /^(\w+)/)[0]
    file_name or= 'xxxxx'
    console.log file_name
    $('#download-link').attr('href', "data:application/octet-stream," + encodeURIComponent(reader.result))
    $('#download-link').show()
#     db.transaction (tx) -> saveIfNotExists(tx, file_name, textData)

  reader.onerror = (ev) ->
    alert 'error'


outPut = (ev) ->
  file = ev.target.files[0]
  alert file.name + ' is selected!'

  reader = new FileReader()
  reader.readAsText(file)

  reader.onload = (ev) ->
    @.attr('href', "data:application/octet-stream," + encodeURIComponent(reader.result))


###
# event
###
$ ->
  $(document).on 'change', '#selectFile', selectFile

  $(document).on 'click', '#download-link', outPut