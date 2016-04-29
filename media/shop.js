(function() {
  $(document).foundation();
  jQuery(function($) {
    var HEADER, PAGE, addToCart, addToCartFail, addToCartPass, alignCaption, auto_play, cart_dropdown_timer, delay, fadeOutCartDropdown, imgZoom, isFirefox, large_photos, large_thumbs, log, mainMenu, mobileMenu, recentCartItemPopUp, retinaLogo, searchAndAccount, slideDownCartDropdown, smallPromos, small_photos, small_thumbs, startTimer, stickyFooter, stopResetTimer, toggleCartDropdown, validateSize;
    PAGE = $('body');
    HEADER = $('.main-header');
    log = function(value) {
      return console.log(value);
    };
    stickyFooter = function() {
      var total_content_height;
      total_content_height = $('.main-header').outerHeight() + $('.main-content').outerHeight() + $('.main-footer').outerHeight();
      if ($(window).outerHeight() > total_content_height) {
        return $('.main-content').css({
          'min-height': $(window).outerHeight() - $('.main-header').outerHeight() - $('.main-footer').outerHeight()
        });
      }
    };
    stickyFooter();
    $(window).resize(function() {
      return stickyFooter();
    });
    retinaLogo = function() {
      if ($('.main-header .title img').length && window.devicePixelRatio >= 2) {
        return $('.main-header .title img').imagesLoaded(function() {
          $(this).width($(this).naturalWidth());
          return $(this).attr('src', $(this).attr('data-retina'));
        });
      }
    };
    retinaLogo();
    searchAndAccount = function() {
      $('.searchbar-open').click(function() {
        $(this).closest('.menu').fadeOut(100, function() {
          $('.main-header .searchbar-container').fadeIn(200);
          return $('.main-header .searchbar-container .search-box').focus();
        });
        return false;
      });
      $('.searchbar-close').click(function() {
        $('.main-header .searchbar-container').fadeOut(100, function() {
          return $('.search-account .menu').fadeIn(200);
        });
        return false;
      });
      $('.account-open').click(function() {
        $(this).closest('.menu').fadeOut(100, function() {
          return $('.account-container').fadeIn(200);
        });
        return false;
      });
      return $('.account-close').click(function() {
        $('.account-container').fadeOut(100, function() {
          return $('.search-account .menu').fadeIn(200);
        });
        return false;
      });
    };
    searchAndAccount();
    mainMenu = function() {
      var dropdown_panel, main_header, main_menu_dropdown_timer, slideUpPanel, startTimer, stopResetTimer;
      dropdown_panel = $(".main-menu-dropdown-panel .row");
      main_header = $(".template-index .main-header");
      HEADER.find(".main-menu .widescreen .dropdown > a").click(function() {
        var autoHeight, curHeight, dropdown, sub_nav;
        dropdown = $(this).parent();
        sub_nav = dropdown.find(".sub-nav .columns");
        if (PAGE.hasClass('template-index') && PAGE.hasClass('with-slider') && Modernizr.touch) {
          if ($('.main-header').hasClass('dropdown-open')) {
            if (dropdown.hasClass("active")) {
              startTimer();
            }
          } else {
            $('.main-header .bg').fadeIn();
          }
        }
        if (dropdown.hasClass("active")) {
          slideUpPanel();
        } else if ($('.main-header').hasClass('dropdown-open')) {
          dropdown_panel.find(".columns").animate({
            opacity: 0
          }, 200);
          dropdown_panel.find('.columns').remove();
          HEADER.find(".main-menu .dropdown").removeClass('active');
          dropdown.addClass("active");
          sub_nav.clone().appendTo(".main-menu-dropdown-panel .row");
          dropdown_panel.find(".columns").delay(200).animate({
            opacity: 1
          }, 200);
          curHeight = dropdown_panel.height();
          autoHeight = dropdown_panel.css('height', 'auto').outerHeight();
          dropdown_panel.height(curHeight).animate({
            height: autoHeight
          }, 400);
        } else {
          dropdown_panel.find('.columns').remove();
          $('.main-header').addClass('dropdown-open');
          dropdown.addClass("active");
          sub_nav.clone().appendTo(".main-menu-dropdown-panel .row");
          dropdown_panel.slideDown(400, function() {
            return dropdown_panel.css("height", dropdown_panel.outerHeight());
          });
          dropdown_panel.find(".columns").delay(200).animate({
            opacity: 1
          }, 200);
        }
        return false;
      });
      slideUpPanel = function() {
        $('.main-header').removeClass('dropdown-open');
        dropdown_panel.find(".columns").animate({
          opacity: 0
        }, 200);
        return dropdown_panel.delay(200).slideUp(function() {
          HEADER.find(".main-menu .dropdown").removeClass('active');
          dropdown_panel.find('.columns').remove();
          return dropdown_panel.css('height', 'auto');
        });
      };
      main_menu_dropdown_timer = '';
      if (Modernizr.touch === false) {
        $('.main-header').mouseenter(function() {
          if (PAGE.hasClass('template-index') && PAGE.hasClass('with-slider')) {
            $('.main-header .bg').fadeIn();
          }
          return stopResetTimer();
        }).mouseleave(function() {
          if ($('.main-header').hasClass('dropdown-open')) {
            return startTimer();
          } else {
            if (PAGE.hasClass('template-index') && main_header.css("position") === "absolute") {
              return $('.main-header .bg').stop(true, true).fadeOut();
            }
          }
        });
      }
      startTimer = function() {
        return main_menu_dropdown_timer = setTimeout((function() {
          slideUpPanel();
          if (PAGE.hasClass('template-index') && PAGE.hasClass('with-slider')) {
            return $('.main-header .bg').delay(300).fadeOut();
          }
        }), 500);
      };
      return stopResetTimer = function() {
        return clearTimeout(main_menu_dropdown_timer);
      };
    };
    mainMenu();
    mobileMenu = function() {
      var dropdown_links, mobile_menu, mobile_menu_link;
      mobile_menu_link = $('.mobile-tools .menu');
      mobile_menu = $('.mobile-menu');
      dropdown_links = mobile_menu.find("a.dropdown-link");
      mobile_menu_link.click(function() {
        mobile_menu.toggle();
        return false;
      });
      return dropdown_links.click(function() {
        var sub_menu;
        sub_menu = $(this).closest('li').find('.sub-nav:eq(0)');
        sub_menu.slideToggle();
        $(this).find('.glyph.plus').toggle();
        $(this).find('.glyph.minus').toggle();
        return false;
      });
    };
    mobileMenu();
   
    if (Modernizr.touch === false) {
      $('.product-grid .product-item').mouseenter(function() {
        return $(this).find('.image-wrapper').animate({
          opacity: 0.5
        }, 100);
      }).mouseleave(function() {
        return $(this).find('.image-wrapper').stop(true, true).animate({
          opacity: 1
        }, 300);
      });
    }
    if (PAGE.hasClass('template-index')) {
      auto_play = false;
      if (home_slider_auto_enabled) {
        auto_play = home_slider_rotate_frequency;
      }
      $('.slider .slides').owlCarousel({
        singleItem: true,
        navigation: false,
        paginationNumbers: false,
        scrollPerPageNav: true,
        slideSpeed: 800,
        pagination: true,
        autoPlay: auto_play
      });
      $('.product-slider .product-grid').owlCarousel({
        items: 4,
        navigation: true,
        scrollPerPage: true,
        slideSpeed: 800,
        lazyLoad: true,
        pagination: false,
        navigationText: false
      });
      $('.product-slider .product-item').show();
      alignCaption = function() {
        var slider_height, slider_width, top_offset;
        top_offset = $('.main-header').outerHeight();
        slider_height = $('.slider').outerHeight() - 10;
        slider_width = $('.slider').outerWidth();
        return $('.slider .caption').each(function() {
          var caption_height, caption_width, left_offset, middle_offset;
          caption_height = $(this).outerHeight();
          caption_width = $(this).outerWidth();
          if ($(this).hasClass('top')) {
            $(this).css('top', top_offset);
          } else if ($(this).hasClass('middle')) {
            middle_offset = (top_offset + ((slider_height - top_offset) / 2) - (caption_height / 2)) - 30;
            $(this).css('top', middle_offset);
          }
          if ($(this).hasClass('center')) {
            left_offset = (slider_width - caption_width) / 2;
            return $(this).css('left', left_offset);
          }
        });
      };
      $('.slider img').first().imagesLoaded(function() {
        alignCaption();
        return $('.slider .caption').css({
          opacity: 1
        });
      });
      delay = (function() {
        var timer;
        timer = 0;
        return function(callback, ms) {
          clearTimeout(timer);
          return timer = setTimeout(callback, ms);
        };
      })();
      $(window).resize(function() {
        return delay(function() {
          alignCaption();
          return stickyFooter();
        }, 500);
      });
    }
    smallPromos = function() {
      return $('.small-promos .image-text-widget').mouseenter(function() {
        return $(this).find('.caption').fadeIn(300);
      }).mouseleave(function() {
        return $(this).find('.caption').stop(true, true).fadeOut(300);
      });
    };
    smallPromos();
    if (PAGE.hasClass('template-list-collections')) {
      $('.collection-item').mouseenter(function() {
        return $(this).find('.caption').fadeIn(300);
      }).mouseleave(function() {
        return $(this).find('.caption').stop(true, true).fadeOut(300);
      });
    }
    if (PAGE.hasClass('template-product')) {
      large_photos = $('.photos.show-for-medium-up');
      large_thumbs = $('.thumbs.show-for-medium-up');
      small_photos = $('.show-for-small .photos');
      small_thumbs = $('.show-for-small .thumbs');
      imgZoom = function(index) {
        return large_photos.find('.container').zoom({
          url: large_photos.find('.photo').eq(index).attr('data-zoom')
        });
      };
      large_photos.find('.container').on("mouseover", function() {
        return large_photos.find('.zoomImg').css({
          opacity: 1
        });
      });
      large_photos.find('.photo').first().addClass("active").fadeIn();
      small_photos.find('.photo').first().addClass("active").fadeIn();
      //imgZoom(0);
      large_photos.find('.photo.active').imagesLoaded(function() {
        return large_photos.find('.container').css({
          "max-height": large_photos.find('.photo').eq(0).find('img').height(),
          "max-width": large_photos.find('.photo').eq(0).find('img').width()
        });
      });
      large_thumbs.find('.thumb').click(function() {
        var index;
        index = $(this).index();
        large_photos.find('.container').find('.zoomImg').remove();
        return large_photos.find('.photo.active').removeClass("active").fadeOut(300, function() {
          return large_photos.find('.photo').eq(index).addClass("active").fadeIn(300, function() {
            large_photos.find('.container').css({
              "max-height": large_photos.find('.photo').eq(index).find('img').height(),
              "max-width": large_photos.find('.photo').eq(index).find('img').width()
            });
            //return imgZoom(index);
          });
        });
      });
      small_thumbs.find('.thumb').click(function() {
        var index;
        index = $(this).index();
        return small_photos.find('.photo.active').removeClass("active").fadeOut(300, function() {
          return small_photos.find('.photo').eq(index).addClass("active").fadeIn(300, function() {
            small_photos.find('.container').css({
              "max-height": small_photos.find('.photo').eq(index).find('img').height(),
              "max-width": small_photos.find('.photo').eq(index).find('img').width()
            });
            //return imgZoom(index);
          });
        });
      });
    }
    if (PAGE.hasClass('template-cart')) {
      setTimeout(function() {
        Foundation.libs.forms.refresh_custom_select($('#address_country'), true);
        return Foundation.libs.forms.refresh_custom_select($('#address_province'), true);
      }, 500);
      $('#address_country').change(function() {
        $('#address_province_container').hide();
        return setTimeout(function() {
          if ($("#address_province").has('option').length > 0) {
            $('#address_province_container').show();
            return Foundation.libs.forms.refresh_custom_select($('#address_province'), true);
          } else {
            return $('#address_province_container').hide();
          }
        }, 500);
      });
    }
    isFirefox = typeof InstallTrigger !== "undefined";
    if (isFirefox) {
      return $('img').addClass('image-scale-hack');
    }
  }); 
  return false; 
}).call(this);
 
if ($('.main-header .mobile-tools').is(":hidden")) { 
  $(function(){
  	new InSales.Cart({
		selector: '.addtocart',
		draw: function(cart){ 
        $('.cart-link .number').html(cart.items_count);
        $('.recently-added .items-count .number').html(cart.items_count);
        $('.recently-added .total-price').html(InSales.formatMoney(cart.total_price, cv_currency_format));
          return false;
		}
	});  
  })
    
   cart_dropdown_timer = '';
   function toggleCartDropdown() {
      $('.main-header .recently-added').slideToggle('fast');
    };
   function slideDownCartDropdown() {
     $('.main-header .recently-added').slideDown('fast');
    };

    function fadeOutCartDropdown() {
      $('.main-header .recently-added').fadeOut('fast');
    };

    $('.main-header .recently-added').mouseenter(function() {
      stopResetTimer();
    });

    $('.main-header .recently-added').mouseleave(function() {
      startTimer();
    });

    function startTimer() {
      return cart_dropdown_timer = setTimeout((function() {
        return fadeOutCartDropdown();
      }), 4000);
    };

    function stopResetTimer() {
      clearTimeout(cart_dropdown_timer);
    }; 

    addToCartFail = function(obj, status) {
      $('.recently-added .error').show();
      $('.recently-added table').hide();
      $('.recently-added div.row').hide();
      slideDownCartDropdown();
      return startTimer();
    };
	function initAjaxAddToCartButton(handle, onAddToCart) {    
	  $(handle).on('click',function(){ 
		  addOrderItem( jQuery(this).parents("form:first"), onAddToCart);
			$("html, body").animate({scrollTop: 0}); 
			new_cart_row = '<tr>';
			new_cart_row += '<td class="cart-item">';
			new_cart_row += '<a href="">';
			new_cart_row += '<img src="'+$(this).attr('data-img')+'" alt="'+$(this).attr('data-title')+'">';
			new_cart_row += '</a>';
			new_cart_row += '</td>';
			new_cart_row += '<td class="cart-detail">';
			new_cart_row += '<h2><a href="">'+$(this).attr('data-title')+'</a></h2>';
			new_cart_row += '</td>';
			new_cart_row += '<td class="cart-price">'+$('#price').html()+'</td>';
			new_cart_row += '</tr>';
			$('.recently-added tbody').html(new_cart_row);
			$('.recently-added .error').hide();
			$('.recently-added table').show();
			$('.recently-added div.row').show();
			slideDownCartDropdown();
			startTimer();
			return false;
	  });
	}

	function addOrderItem(form, onAddToCart) {
			var fields = form.serialize();
			var action = form.attr("action").split("?");
			var url = action[0] + ".json";
			var lang = action[1] ? "?"+action[1] : "";
			var path = url + lang;    
			jQuery.ajax({
				url: path,
				type: 'post',
				data: fields,
				dataType: 'json',
				success: onAddToCart,
				error: hide_preloader
			});
	  
	}
}
  
function checkout(){
    var qSwaps = [];
    $(".cart_row input.qty").each(function(i) {
		qSwaps[i] = $(this).val();
        if ( $(this).attr('processed') ) { return; }
        $(this).attr('processed',true);
        $(this).bind("change keyup", function(e) {
            var el = $(this);
            var value = el.val();
            val = value.replace(/[^\d\.\,]+/g,'');
            if (val < 0){}
            if(val != value) el.val(val);
            if (val == qSwaps[i]) return;
            qSwaps[i] = val;
            //el.parents(".cart_row:first").find(".item-total").html( InSales.formatMoney(val*el.attr('price'), cv_currency_format) )
            recalculate_order();
        }).bind('blur',function(){
            var el = $(this);
            var value = el.val();
            val = value.replace(/[^\d\.\,]+/g,'');
            if (val < 0 || val == ""){ val = 0; }
            el.val(val);
            el.change();
        });
    });

    function recalculate_order() {
    	var fields =  new Object;
    	fields = $('#cartform').serialize();
      	var path = '/cart_items/update_all.json'
    	show_preloader();
		$.ajax({
			url:      path,
			type:     'post',
			data:     fields,
			dataType: 'json',
			success:  function(response) {
                $('.cart-link .number').html(response.items_count);
				$('.cart-total').html(InSales.formatMoney(response.total_price, cv_currency_format));
                hide_preloader();
			},
			error:  function(response) {  alert("произошла ошибка"); hide_preloader(); }
		});
    }
}
jQuery("document").ready(function($){
    
    var nav = $('.bottom-row');
  	var mobile = $(".mobile-menu");
    mobile.addClass("f-nav");
    var headerTop = $(".main-header");
  	var fixMenu = function() {
        if ($(this).scrollTop() > (headerTop.offset().top + headerTop.height() - nav.height())) {

          	mobile.css({"top":"65px", "position":"fixed"});
            nav.addClass("f-nav");
          	$("header.main-header").css("margin-top", nav.height());
        } else {
            nav.removeClass("f-nav");
          	$("header").css("margin-top", 0);
          	mobile.css({"top":"195px", "position":"absolute"});
        }    
    
    };
  	fixMenu();
    $(window).scroll(function () {
		fixMenu();
    });
 
});