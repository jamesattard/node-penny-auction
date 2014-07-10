// Generated by CoffeeScript 1.7.1

/*
Module dependencies
 */
var actionUtil, createRecord, util;

util = require("util");

actionUtil = require("sails/lib/hooks/blueprints/actionUtil");


/*
Create Record

post /:modelIdentity

An API call to find and return a single model instance from the data adapter
using the specified criteria.  If an id was specified, just the instance with
that unique id will be returned.

Optional:
@param {String} callback - default jsonp callback param (i.e. the name of the js function returned)
@param {*} * - other params will be used as `values` in the create
 */

module.exports = createRecord = function(req, res) {
  var Model, created, data;
  Model = actionUtil.parseModel(req);
  data = actionUtil.parseValues(req);
  return Model.create(data).exec(created = function(err, newInstance) {
    if (err) {
      return res.negotiate(err);
    }
    if (req._sails.hooks.pubsub) {
      if (req.isSocket) {
        Model.subscribe(req, newInstance);
        Model.introduce(newInstance);
      }
      Model.publishCreate(newInstance, !req.options.mirror && req);
    }
    return res.created(newInstance.toJSON(req.query.jsonFormat));
  });
};
