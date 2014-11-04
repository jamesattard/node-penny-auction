if((typeof App === 'undefined') || (App == null)){
  App = {};
}

App.PageModel = Backbone.Model.extend({
  defaults: {
    activeRouter: ''
  }
});

