// Generated by CoffeeScript 1.7.1
var ValidationError,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

ValidationError = (function(_super) {
  __extends(ValidationError, _super);

  function ValidationError() {
    if (arguments.length === 0) {
      throw DevError("No arguments passed to ValidationError constructor");
    }
    this._errors = [];
    if (arguments.length === 2) {
      this._addNew(arguments[0], arguments[1]);
    } else if (arguments.length === 1) {
      this._parseModeValidations(arguments[0]);
    }
  }

  ValidationError.prototype.toJSON = function() {
    return this._errors;
  };

  ValidationError.prototype._addNew = function(field, messages) {
    if (_.isString(messages)) {
      messages = [messages];
    }
    return this._errors.push({
      errorType: 'validation',
      field: field,
      messages: messages
    });
  };

  ValidationError.prototype._parseModeValidations = function(validationErrors) {
    var detail, details, field, messages, _i, _len;
    for (field in validationErrors) {
      details = validationErrors[field];
      messages = [];
      for (_i = 0, _len = details.length; _i < _len; _i++) {
        detail = details[_i];
        messages.push(detail.message);
      }
      this._addNew(field, messages);
    }
    return this._errors;
  };

  return ValidationError;

})(SerializableError);

GLOBAL.ValidationError = ValidationError;
