// Generated by CoffeeScript 1.7.1
var SuccessJsonResponse, _;

_ = require("underscore");

SuccessJsonResponse = (function() {
  function SuccessJsonResponse(data, messages) {
    this.data = data != null ? data : {};
    this.messages = messages != null ? messages : [];
    if (_.isString(this.messages)) {
      this.messages = [this.messages];
    }
  }

  SuccessJsonResponse.prototype.toJSON = function() {
    return {
      data: this.data,
      messages: this.messages
    };
  };

  return SuccessJsonResponse;

})();

GLOBAL.SuccessJsonResponse = SuccessJsonResponse;
