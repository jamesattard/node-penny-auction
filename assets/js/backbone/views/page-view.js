if((typeof App === 'undefined') || (App == null)){
  App = {};
}

App.PageView = Backbone.View.extend({
  el: "#page-container",
  initialize: function(inOptions) {
    this.options = inOptions;
    _.bindAll(this, 'render');
    this.model.bind('change:activeRouter', this.render);
    return $('.js-page').hide();
  },

  render: function() {
    var activePageName = this.model.get('activeRouter');
    $('.js-pages-nav').removeClass('active');
    $(".js-pages-nav.js-" + activePageName).addClass('active');

    if (this.options.views[activePageName] && this.options.views[activePageName].render) {
      var contentHtml = this.options.views[activePageName].render();
      this.$el.html(contentHtml);
    }

    $('.js-page.active').removeClass('active').hide();
    $("#" + activePageName + "-page").addClass('active').fadeIn();

    if(this.options.views[activePageName] && this.options.views[activePageName].afterRender){
      this.options.views[activePageName].afterRender();
    }
  }
});
