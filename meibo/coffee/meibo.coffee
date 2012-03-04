selectFile = (ev) ->
  console?.log (f.name for f in ev.target.files)


_drop = (files) ->
  console?.log '_drop'
#   reader = new FileReader()
  html = '<html><head></head><body><table>'
  for f in files
    console?.log f.name
    html = html + '<tr><td><img src="' + f.name + '"/></td></tr>'
  html = html + '</table></body></html>'
  console?.log html
  # downloadリンクを表示してそこからデータをDLさせる
#   $('#download-link').attr('href', "data:application/octet-stream," + encodeURIComponent(html))
  $('#download-link').attr('href', "data:text/html," + html)
  $('#download-link').show()


drop = (e) ->
  console?.log 'drop'
  if e.preventDefault
    e.preventDefault()
#   console?.log e.originalEvent.dataTransfer.files
  _drop e.originalEvent.dataTransfer.files

###
# event
###
$ ->
  $(document).on 'change', '#selectFile', selectFile

  $("body").bind "drop", drop
  $("body").bind "dragenter", -> false
  $("body").bind "dragover", -> false
