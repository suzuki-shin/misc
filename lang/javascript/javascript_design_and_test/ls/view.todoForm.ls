# formを管理する
class todoFormView
  ($el) ->
    @$el = $el
    @$input = @$el.find('input[type="text"]')

  onsubmit = (e) ->
    e.preventDefault()
    Todo.add(@$input.val())
