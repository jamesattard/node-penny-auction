if((typeof App === 'undefined') || (App == null)){
  App = {};
}

App.UserModel = Backbone.Model.extend({
  url: function() {
    if (this.get('id')) {
      return "/api/user/" + (this.get('id'));
    } else {
      return "/api/user";
    }
  },
  initialize: function() {},
  defaults: {
    username: "",
    email: "",
    country: "",
    dob: ""
  },
  getAvatar: function() {
    if (this.get('avatar')) {
      return ("/media/avatar/id" + (this.get('id')) + "/") + this.get('avatar') + "?" + (new Date).getTime();
    } else {
      return "/media/avatar/default.png";
    }
  }
});
