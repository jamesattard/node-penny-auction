if((typeof App === 'undefined') || (App == null)){
  App = {};
}

App.SignUpPageView = Backbone.View.extend({
//  el: "#sign-in-page",
  template: JST['assets/templates/backbone/sign-up-page.html'],

  initialize: function(options) {

  },

  render: function(){
    return this.template();
  },

  afterRender: function() {
//    return this._formValidation();
  }

//  _formValidation: function() {
//    this._signInForm = $('#sign-in-form');
//    return this._signInForm.validate({
//      rules: {
//        email: {
//          required: true,
//          email: true,
//          maxlength: 128
//        },
//        password: {
//          required: true
//        }
//      },
//      errorPlacement: function(error, element) {
//        if ($(element).hasClass('js-unite-errors')) {
//          return $('.js-error-holder').html(error);
//        } else {
//          return $(element).after(error);
//        }
//      },
//      submitHandler: (function(_this) {
//        return function() {
//          return helpers.ajax.post({
//            url: 'api/auth/local',
//            data: _this._signInForm.serialize(),
//            targetEl: _this._signInForm,
//            cbSuccess: function(response) {
//              console.log(response);
//              return $(location).attr('href', response.redirectTo);
//            }
//          });
//        };
//      })(this)
//    });
//  }
});
