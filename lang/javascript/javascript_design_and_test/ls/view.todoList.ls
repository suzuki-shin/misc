class TodoListView
  ($el) ->
    @$el = $el

  add = (todo) ->
    item = new TodoListItemView(todo)
    @$el.append(item.$el)

class TodoListItemView
  (todo) ->
    @todo = todo
    @$el = $('<li><input type="checkbox">' + todo.text + '</li>')
    @$checkbox = @$el.find('input[type="checkbox"]')

  onchangeCheckbox =->
    @todo.setComplete(@$checkbox.is(':checked'))

  onchangeComplete =->
    if @todo.complete
      @$el.addClass('complete')
    else
      @$el.removeClass('complete')

    @$checkbox.attr('checked', @todo.complete)
