$(->
  # 要素取得
  $form = $('.todoForm')
  $input = form.find('input[type="text"]')
  $list = $('.todoList')
  $usual = $('.usualList li')

  # 共通処理(リストを追加する部分)を関数に切り出した
  addList = (text) ->
    html = '<li><input type="checkbox">' + text + '</li>'
    $li = $(html)

    $li.find('input[type="checkbox"]').change(->
      $(this).closest('li').toggleClass('complete')
    )

    $list.append($li)

  # よく使う一覧をクリックしたらリストに追加
  $usual.click((e) ->
    e.preventDefault()

    text = $(this).text()
    addList(text)
  )

  # フォームがサブミットされたら
  $form.submit((e) ->
    e.preventDefault()

    # 要素つくって
    text = $input.val()
    addList(text)
  )
)