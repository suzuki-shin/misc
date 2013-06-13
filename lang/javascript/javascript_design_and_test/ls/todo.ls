$(->
  # 要素取得
  $form = $('.todoForm')
  $input = form.find('input[type="text"]')
  $list = $('.todoList')

  # フォームがサブミットされたら
  $form.submit(->
    e.preventDefault();

    # 要素つくって
    text = $input.val()
    html = '<li><input type="checkbox">' + text + '</li>'
    $li = $(html)

    $li.find('input[type="checkbox"]').change(->
      $(this).closest('li').toggleClass('complete')
    )

    $list.append($li)
  )
)