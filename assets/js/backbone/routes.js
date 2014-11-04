if((typeof App === 'undefined') || (App == null)){
  App = {};
}

App.MainRouter = Backbone.Router.extend({
  options: null,
  initialize: function(options){
    this.options = options;
    if(!options || !options.model){
      throw new Error('router must be initialized with hash containing model');
    }
    console.log('router initialized with options', this.options);
  },

  routes: {
    ''         : 'main',
    '/'        : 'main',
    'login'    : 'login',
    'sign-up'  : 'signUp'
  },

  main: function() {
    console.log('Router:main');
    this.options.model.set('activeRouter', 'main');
  },

  login: function(){
    console.log('Router:login');
    this.options.model.set('activeRouter', 'login');
  },

  signUp: function(){
    console.log('Router:signUp');
    this.options.model.set('activeRouter', 'sign-up');
  }
});
