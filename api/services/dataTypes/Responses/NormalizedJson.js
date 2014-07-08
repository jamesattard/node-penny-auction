// Generated by CoffeeScript 1.7.1
var NormalizedJson;

NormalizedJson = (function() {
  function NormalizedJson(data, messages) {
    this.data = data != null ? data : {};
    this.messages = messages != null ? messages : [];
    if (_.isString(this.messages)) {
      this.messages = [this.messages];
    }
  }

  NormalizedJson.prototype.toJSON = function() {
    return {
      data: this.data,
      messages: this.messages
    };
  };

  return NormalizedJson;

})();

exports.NormalizedJson = NormalizedJson;