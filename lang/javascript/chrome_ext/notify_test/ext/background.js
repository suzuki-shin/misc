var minToMilSec, startTimer, finishTimer;
minToMilSec = function(minutes){
  return minutes * 60 * 1000;
};
startTimer = function(minutes){
  console.log('startTimer');
  return setTimeout(finishTimer, minToMilSec(minutes));
};
finishTimer = function(){
  var n;
  console.log('finishTimer');
  if (window.webkitNotifications) {
    console.log("Notifications are supported!");
    if (webkitNotifications.checkPermission() === 0) {
      n = webkitNotifications.createNotification('icon.png', 'fugaq', 'time up!');
      n.show();
      return console.log('createNotification');
    } else {
      webkitNotifications.requestPermission();
      return console.log('requestPermission');
    }
  } else {
    return console.log("Notifications are not supported for this Browser/OS version yet.");
  }
};
startTimer(1);