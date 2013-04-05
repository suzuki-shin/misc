minToMilSec = (minutes) -> minutes * 60 * 1000

startTimer = (minutes) ->
  console.log('startTimer')
  setTimeout(finishTimer, minToMilSec(minutes))

finishTimer =->
  console.log('finishTimer')
  if window.webkitNotifications
    console.log("Notifications are supported!")
    if webkitNotifications.checkPermission() is 0
      n = webkitNotifications.createNotification('icon.png', 'fugaq', 'time up!')
      n.show()
      console.log('createNotification')
    else
      webkitNotifications.requestPermission()
      console.log('requestPermission')
  else
    console.log("Notifications are not supported for this Browser/OS version yet.")

startTimer(1)
