@ftoh = (str) ->
  (fullchar2halfchar(c) for c in str).join('')

fullchar2halfchar = (char) ->
  if @table[char]? then @table[char] else char
#   char.replace(/[ａ-Ｚ]/, (c) -> "@")