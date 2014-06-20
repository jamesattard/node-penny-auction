// Generated by CoffeeScript 1.7.1
module.exports = {
  schema: true,
  attributes: {
    username: {
      type: "string",
      unique: true
    },
    email: {
      type: "email",
      unique: true
    },
    passports: {
      collection: "Passport",
      via: "user"
    },
    toJSON: function() {
      var data;
      data = this.toObject();
      delete data.password;
      return data;
    }
  }
};
