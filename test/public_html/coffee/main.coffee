require [
    "jquery",
    "jquery.alpha",
    "jquery.beta"
    "test"
],
($) ->
    $ ->
        $('body').alpha().beta()
        $('#test').on('click', hoge)
