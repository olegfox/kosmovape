if $('#order_form').length == 0
  $('.html_checkout').removeClass('html_checkout')

# Редирект на оплату
if $('.back_to_shop').length > 0
  href = $('span.red').parent().find('a').attr('href')
  if href != undefined
    window.location.href = href

if $('.html_checkout').length > 0

  # Перемещение сайдбара со списком товаров в конец формы
  $('.set-sidebar').appendTo($('#order_form'))

  # Удаление количества товара из сайдбара
  $descriptionQuantityObjects = $('.set-list .description p')
  $descriptionQuantityObjects.each (i, e) ->
    descriptionQuantity = $(e).html()
    $(e).html(descriptionQuantity.replace('1 x ', ''))

  # Удаление парной скидки из списка товаров в сайдбаре
  if $('.set-sidebar .set-meta .fc').length == 4
    $('.set-sidebar .set-meta .fc').eq(0).remove()

  $('.html_checkout').css('opacity', 1)

  if $('#regular_client input').length == 0
    $('#regular_client').hide()

  if $('#contacts').length > 0
    $('#contacts').remove()

  $('input[type="checkbox"]').parent().remove()

#  # Фокус на первое не заполненное поле на веб версии
#  if !(new MobileDetect(window.navigator.userAgent)).mobile() && !(new MobileDetect(window.navigator.userAgent)).tablet()
#    $('#order_form').find('input, textarea, select').each (i, e) ->
#      if ($(e).is('select') && $(e).find('option:selected').val() == '') || ($(e).val() == '')
#        $(window).scrollTop($(e).offset().top)
#        $(e).addClass('focus').focus()
#        return false

  # Показать описание у города
  $('#shipping_address_city').parent().find('.small').addClass('show')

  # Выставляем заголовки слева
  $('#order_form h3').eq(0).remove()
  h3Length = $('#order_form h3').length
  $('#order_form h3').eq(h3Length - 1).addClass('left')
  $('#order_form h3').eq(h3Length - 2).addClass('left')
  $('#order_form h3').eq(h3Length - 3).remove()

  # Добавление телефона и режима работы
  $('header .section--header > .wrap').append('<div class="checkout_contacts"><a href="tel:8 800 715-88-31">8 800 715-88-31</a><div class="checkout_mode">10:00 — 20:00</div></div>')

  # Добавление ссылки "Вернутся в корзину"
  $('header .section--header > .wrap').append('<a class="back_to_cart" href="/cart_items">вернуться в корзину</a>')

  # Выделение способа рамкой
  $('table.variants tr').click () ->
    if !$(this).hasClass('select')
      $(this).parent().find('tr.select').removeClass('select')
      $(this).addClass('select')
      $(this).find('input[type="radio"]').eq(0).attr('checked', 'checked').prop('checked', true).trigger('change').click()

  # Итого вниз
  $('.set-sidebar').insertAfter($('#order_form > div:last'))
  $('.set-sidebar .fc.b p.fl').text('Итого:')

  # Надпись оформление заказа
  $('#order_form').find('input[type="submit"]').val('Оформить заказ')

  # Изменение состояния input radio
  #$('input[type="radio"]').attrchange({
  #  trackValues: true,
  #  callback: (e) ->
  #    if e.attributeName == 'checked'
  #      if $(this).prop('checked')
  #        $(this).parent().addClass('select')
  #      else
  #        $(this).parent().removeClass('select')
  #})

  # Сброс стиля ошибки у полей формы
  $('select#pvz').on 'change', () ->
    if $(this).parent().hasClass('error') && ($(this).find('option:selected').val()).length > 0
      $(this).parent().removeClass('error')

  $('input').on 'change keyup', () ->
    if $(this).hasClass('error')
      $(this).removeClass('error')

  $('textarea').on 'change keyup', () ->
    if $(this).hasClass('error')
      $(this).removeClass('error')

  $('input[type="radio"]').on 'change', () ->
    if $(this).prop('checked')
      $(this).parent().parent().parent().find('td.radio.select').removeClass('select')
      $(this).parent().addClass('select')

  # Placeholder для адреса
  $('#shipping_address_address').attr('placeholder', 'улица, дом, корпус, квартира')

  # Удаление двоеточия в названии полей
  $('label').each (i, e) ->
    if $(e).html().match(':')
      $(e).html($(e).html().replace(':', ''))

  # Закрепеление списка товара в форме оформления заказа
  window.onresize = () ->
    console.log 'window width = ' + $(window).width()
    if $(window).width() <= 967
      $('.set-sidebar').removeClass('sticky')

  setTimeout () ->
    offsetTop = $('.set-sidebar').offset().top
    console.log 'offsetTop = ' + offsetTop
    window.onscroll = () ->
      if $(window).width() > 967
        if $(window).scrollTop() > offsetTop
          if !$('.set-sidebar').hasClass('sticky')
            $('.set-sidebar').addClass('sticky')
        else
          if $('.set-sidebar').hasClass('sticky')
            $('.set-sidebar').removeClass('sticky')
  , 1000
