$(function() {
	$('.field, textarea').focus(function() {
        if(this.title==this.value) {
            this.value = '';
        }
    }).blur(function(){
        if(this.value=='') {
            this.value = this.title;
        }
    });

    $('#navigation ul li').hover( function(){
        $(this).addClass('active');
    }, function() {
        $(this).removeClass('active');
    });

    $('.col ul li a').hover( function (){
        $(this).addClass('active');
    }, function() {
        $(this).removeClass('active');     
    });

    $('input[type=checkbox]').prettyCheckboxes({
        checkboxWidth: 11,
        checkboxHeight: 12
    });

    $("#slider").jcarousel({
        scroll: 1,
        auto: 3,
        wrap: 'both',
        vertical: 'true',
        initCallback: mycarousel_initCallback,       
        buttonNextHTML: null,
        buttonPrevHTML: null,
         itemVisibleInCallback: {
            onAfterAnimation: function(c, o, i, s) {
                $('.slider-controls a').removeClass('active');
                $('.slider-controls a:eq('+ (i-1) +')').addClass('active');
            }
        }
    });

    $(".products-slider").jcarousel({
        scroll: 1,
        auto: 3,
        wrap: 'circular'       
    });

    if ($.browser.msie && $.browser.version == 6) {
        DD_belatedPNG.fix('#slider img, a.buy-now, .price-label, .sale-label, span.bullet, .submit-button, .holder');
    }

    $(".product").click(function(){
        window.location=$(this).find("a").attr("href");
        return false;
    });  
});

function mycarousel_initCallback(carousel) {
    $('.slider-controls a').bind('click', function() {
        $('.slider-controls a').removeClass('active');
        $(this).addClass('active');
        carousel.scroll(jQuery.jcarousel.intval(jQuery(this).text()));
        return false;
    });

    $('#next').bind('click', function() {
        carousel.next();
        return false;
    });

    $('#prev').bind('click', function() {
        carousel.prev();
        return false;
    });
};    