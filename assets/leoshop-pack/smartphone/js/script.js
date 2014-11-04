/*-----------------------------------------------------------------------------------

 	Script - All Custom frontend jQuery scripts & functions
 
-----------------------------------------------------------------------------------*/

jQuery(window).load(function($) {	
	

	
	
	/*---------------------------------------------- 
				R E S P ON S I V E   N A V 
	------------------------------------------------*/
	jQuery('<a class="open-responsive-nav" href="">open</a>').appendTo(".menu");
	jQuery('<div class="menu-responsive"><div class="wrapper"><nav id="responsive-nav"><ul class="clearfix"></ul></nav></div></div>').appendTo("header");
	
	var mainnav = jQuery("nav#main-nav > ul").html();
	jQuery("nav#responsive-nav > ul").html(mainnav);
	
	
	jQuery('body').on("click", ".open-responsive-nav", function() { 
		jQuery('.menu-responsive').slideToggle(300);
		return false;
	});
	
	jQuery('nav#responsive-nav').on("click", "a", function() {
		if (jQuery(this).parent().children('ul').length > 0) {
			jQuery(this).parent().children('ul').slideToggle(300);
			return false;
		} else {
			return true;
		}
	});
	
	
	initialise();
	
});  // END jQuery(window).load(function($) {




jQuery(window).resize(function($) {	
	initialise();
	
	if( jQuery().isotope ) {
		var $container = jQuery('.masonry');
		$container.isotope( 'reLayout');
	}
}); // END jQuery(window).resize(function($) {
	
	
	


/* functions which need to be reinitialised when resizing window */
function initialise() {
	

	
	
}