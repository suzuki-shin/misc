global = this

global.ftoh = (str) ->
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
    alert global.ftoh(textData)
    console.log textData.split("\n")
#     file_name = (file.name.match /^(\w+)/)[0]
#     file_name or= 'xxxxx'
#     console.log file_name
    $('#download-link').attr('href', "data:application/octet-stream," + encodeURIComponent(global.ftoh(reader.result)))
    $('#download-link').show()

  reader.onerror = (ev) ->
    alert 'error'


###
# event
###
$ ->
  $(document).on 'change', '#selectFile', selectFile
