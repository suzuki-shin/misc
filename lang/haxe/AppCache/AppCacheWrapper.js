function AppCacheWrapper() {
  this.cache = window.applicationCache;
}
AppCacheWrapper.prototype.update = function() {
  this.cache.update();
}
AppCacheWrapper.prototype.swapCache = function() {
  this.cache.swapCache();
}