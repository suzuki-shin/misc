# Todoのデータ管理をするModelクラス
class Todo
  (data) ->
    @text = data.text
    @complete = data.complete

  @setComplete =->
#     @complete = complete
#     @trigger('change:complete', this)

  # 自身のインスタンスを保持する配列
  @list = []

  # 新規Todoを追加するためのクラスメソッド
  @add = (text) ->
    @list.append(Todo({text: text}))

