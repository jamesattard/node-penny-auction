// Generated by CoffeeScript 1.7.1
var DevError;

DevError = (function() {
  function DevError(message) {
    this.message = message;
    this.name = this.constructor.name;
  }

  DevError.prototype = new Error();

  DevError.prototype.constructor = DevError;

  return DevError;

})();

GLOBAL.DevError = DevError;
