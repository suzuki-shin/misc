var finishTimer, startTimer;
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
startTimer = function(minutes){
  chrome.alarms.create("xxtest", {
    delayInMinutes: minutes
  });
  return chrome.alarms.onAlarm.addListener(finishTimer);
};