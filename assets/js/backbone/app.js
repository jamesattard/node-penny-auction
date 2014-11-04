if((typeof App === 'undefined') || (App == null)){
  App = {};
}

_.extend(App, {
  init: function(inConfig) {
    this.config = {};
    this.config = _.extend(this.config, inConfig);
    return this;
  },

  start: function() {
    var pageModel, pageView, router;
    console.log('app started', App);
    App.viewportUser = new App.UserModel;
    pageModel = new App.PageModel;
    pageView = new App.PageView({
      model: pageModel,
      views: {
        'main': new App.MainPageView,
        'login': new App.LoginPageView,
        'sign-up': new App.SignUpPageView
      }
    });

    router = new App.MainRouter({
      model: pageModel
    });
    App.router = router;
    Backbone.history.start({
      pushState: true
    });
    return $(document).on("click", "a[href^='/']", function(event) {
      var href, passThrough, url;
      href = $(event.currentTarget).attr('href');
      passThrough = href.indexOf('sign-out') >= 0;
      if (!passThrough && !event.altKey && !event.ctrlKey && !event.metaKey && !event.shiftKey) {
        event.preventDefault();
        url = href.replace(/^\//, '').replace('\#\!\/', '');
        router.navigate(url, {
          trigger: true
        });
        return false;
      }
    });
  }
});
