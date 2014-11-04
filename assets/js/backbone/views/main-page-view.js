if((typeof App === 'undefined') || (App == null)){
  App = {};
}

App.MainPageView = Backbone.View.extend({
//  el: "#sign-in-page",
  template: JST['assets/templates/backbone/main-page.html'],

  initialize: function(options) {

  },

  render: function(){
    return this.template();
  },

  afterRender: function() {
  }

});
