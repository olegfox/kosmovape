// Generated by CoffeeScript 1.10.0
(function() {
  var $descriptionQuantityObjects, h3Length, href;

  if ($('#order_form').length === 0) {
    $('.html_checkout').removeClass('html_checkout');
  }

  if ($('.back_to_shop').length > 0) {
    href = $('span.red').parent().find('a').attr('href');
    if (href !== void 0) {
      window.location.href = href;
    }
  }

  if ($('.html_checkout').length > 0) {
    $('.set-sidebar').appendTo($('#order_form'));
    $descriptionQuantityObjects = $('.set-list .description p');
    $descriptionQuantityObjects.each(function(i, e) {
      var descriptionQuantity;
      descriptionQuantity = $(e).html();
      return $(e).html(descriptionQuantity.replace('1 x ', ''));
    });
    if ($('.set-sidebar .set-meta .fc').length === 4) {
      $('.set-sidebar .set-meta .fc').eq(0).remove();
    }
    $('.html_checkout').css('opacity', 1);
    if ($('#regular_client input').length === 0) {
      $('#regular_client').hide();
    }
    if ($('#contacts').length > 0) {
      $('#contacts').remove();
    }
    $('input[type="checkbox"]').parent().remove();
    $('#shipping_address_city').parent().find('.small').addClass('show');
    $('#order_form h3').eq(0).remove();
    h3Length = $('#order_form h3').length;
    $('#order_form h3').eq(h3Length - 1).addClass('left');
    $('#order_form h3').eq(h3Length - 2).addClass('left');
    $('#order_form h3').eq(h3Length - 3).remove();
    $('header .section--header > .wrap').append('<div class="checkout_contacts"><a href="tel:8 800 715-88-31">8 800 715-88-31</a><div class="checkout_mode">10:00 — 20:00</div></div>');
    $('header .section--header > .wrap').append('<a class="back_to_cart" href="/cart_items">вернуться в корзину</a>');
    $('table.variants tr').click(function() {
      if (!$(this).hasClass('select')) {
        $(this).parent().find('tr.select').removeClass('select');
        $(this).addClass('select');
        return $(this).find('input[type="radio"]').eq(0).attr('checked', 'checked').prop('checked', true).trigger('change').click();
      }
    });
    $('.set-sidebar').insertAfter($('#order_form > div:last'));
    $('.set-sidebar .fc.b p.fl').text('Итого:');
    $('#order_form').find('input[type="submit"]').val('Оформить заказ');
    $('select#pvz').on('change', function() {
      if ($(this).parent().hasClass('error') && ($(this).find('option:selected').val()).length > 0) {
        return $(this).parent().removeClass('error');
      }
    });
    $('input').on('change keyup', function() {
      if ($(this).hasClass('error')) {
        return $(this).removeClass('error');
      }
    });
    $('textarea').on('change keyup', function() {
      if ($(this).hasClass('error')) {
        return $(this).removeClass('error');
      }
    });
    $('input[type="radio"]').on('change', function() {
      if ($(this).prop('checked')) {
        $(this).parent().parent().parent().find('td.radio.select').removeClass('select');
        return $(this).parent().addClass('select');
      }
    });
    $('#shipping_address_address').attr('placeholder', 'улица, дом, корпус, квартира');
    $('label').each(function(i, e) {
      if ($(e).html().match(':')) {
        return $(e).html($(e).html().replace(':', ''));
      }
    });
    window.onresize = function() {
      console.log('window width = ' + $(window).width());
      if ($(window).width() <= 967) {
        return $('.set-sidebar').removeClass('sticky');
      }
    };
    setTimeout(function() {
      var offsetTop;
      offsetTop = $('.set-sidebar').offset().top;
      console.log('offsetTop = ' + offsetTop);
      return window.onscroll = function() {
        if ($(window).width() > 967) {
          if ($(window).scrollTop() > offsetTop) {
            if (!$('.set-sidebar').hasClass('sticky')) {
              return $('.set-sidebar').addClass('sticky');
            }
          } else {
            if ($('.set-sidebar').hasClass('sticky')) {
              return $('.set-sidebar').removeClass('sticky');
            }
          }
        }
      };
    }, 1000);
  }

}).call(this);

//# sourceMappingURL=redisign_checkout.js.map