var n;
if (window.webkitNotifications) {
  console.log("Notifications are supported!");
  if (webkitNotifications.checkPermission() === 0) {
    n = webkitNotifications.createNotification('icon.png', 'fugaq', 'messsssee');
    n.show();
    console.log('createNotification');
  } else {
    webkitNotifications.requestPermission();
    console.log('requestPermission');
  }
} else {
  console.log("Notifications are not supported for this Browser/OS version yet.");
}