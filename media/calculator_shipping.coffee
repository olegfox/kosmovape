class CityField

  CityField.kladr = []
  CityField.variantsDelivery = {
    'courier': false
    'points': false
  }
  CityField.variantsDeliveryPost = {
    'err': true
  }
  CityField.maxTotalPrice = 5000 # Минимальная сумма, при которой действует только оплата онлайн
  CityField.requestStatus = 0 # Если в 1, то запросы на наш сервер отработали
  CityField.margin = 0 # Процент скидки при оплате онлайн
  CityField.countRequestForMargin = 0

  constructor: () ->
    CityField.kladr_key = '97d13f084f24de48a7a6311259b40518' # ключ к кладр
    CityField.kladr_token = 'db2ef881e129cd5dd73b362a307f1d10' # token кладр
    CityField.kladr_limit = 5 # limit кладр
    CityField.field_id = "#" + 'shipping_address_city' # id поля города
    CityField.id_delivery_courier = 415531 # id поля способа доставки курьером
    CityField.id_delivery_points = 415532 # id поля способа доставки пункт выдачи
    CityField.id_delivery_point_description = 3224898 # id поля описания пункта выдачи
    CityField.id_delivery_post_calc = 435233 # id поля способа доставки почта россии
    CityField.id_payment = 344685 # id поля оплаты при получении
    CityField.id_payment_postcalc = 359944 # id поля наложенный платеж
    CityField.id_payment_online = 310842 # id поля банковская карта
    CityField.id_payment_online_2 = 364405 # id поля оплата онлайн со скидкой
    CityField.id_payment_rko = 3247644 # id поля с рко

    #    CityField.kladr_key = 'cc6ee94721ba7afe85ddb77f636ebcce' # ключ к кладр
    #    CityField.kladr_token = '16cb20407b4bbfd0ecf63ea2f25349e3' # token кладр
    #    CityField.kladr_limit = 5 # limit кладр
    #    CityField.field_id = "#" + 'shipping_address_city' # id поля города
    #    CityField.id_delivery_courier = 442365 # id поля способа доставки курьером
    #    CityField.id_delivery_points = 440773 # id поля способа доставки пункт выдачи
    #    CityField.id_delivery_point_description = 3275250 # id поля описания пункта выдачи
    #    CityField.id_delivery_post_calc = 440774 # id поля способа доставки почта россии
    #    CityField.id_payment = 362751 # id поля оплаты при получении
    #    CityField.id_payment_postcalc = 362752 # id поля наложенный платеж
    #    CityField.id_payment_online = 362750 # id поля оплата онлайн
    #    CityField.id_payment_online_2 = 362769 # id поля оплата онлайн со скидкой
    #    CityField.id_payment_rko = 3275251 # id поля с рко
    $(CityField.field_id).parent().append('<div class="address__autocomplete"></div>')
    CityField.autocompleteBlock = $('.address__autocomplete')
    CityField.limitDefault = 15000 # лимит в секундах умолчанию
    CityField.limit = CityField.limitDefault

  ###*
  # Метод инициализации поля ввода города
  ###
  init: () ->
# Ограничение по времени обработки оформления заказа
    CityField.limiter()
    # Дублируем итоговую стоимость
    $('#payment_gateways').append('<div class="total_price"><p class="fl">Итого:</p><p class="fr price prices-current"></p></div>')

    # Добавляем прелоадер к способам доставки
    $('.delivery_variants').addClass('loader')
    if $('.delivery_variants tbody .load').length == 0
      $('.delivery_variants tbody').append('<tr class="load"><td></td></tr>')

    # Добавляем прелоадер к способам оплаты
    $('.payment_variants').addClass('loader')
    if $('.payment_variants tbody .load').length == 0
      $('.payment_variants tbody').append('<tr class="load"><td></td></tr>')

    # Скрываем оплату онлайн со скидкой
    $('#order_payment_gateway_id_' + CityField.id_payment_online_2).parent().parent().hide()

    # Переименование оплаты онлайн со скидкой в оплату онлайн
    #    $('label[for="order_payment_gateway_id_' + CityField.id_payment_online_2 + '"]').html($('label[for="order_payment_gateway_id_' + CityField.id_payment_online + '"]').html())

    # Блокировка кнопки заказа
    $('input[type="submit"]').hide()

    # Событие изменения индекса
    console.log 'zip object ' + $('#shipping_address_zip').length
    if $('#shipping_address_zip').length > 0

      console.log 'check zip'

      # Потеря фокуса
      $('#shipping_address_zip').bind 'blur', () ->
        console.log 'check zip blur'

        if CityField.requestStatus == 1 &&
           $('#shipping_address_zip').attr('data-value') != $('#shipping_address_zip').val() &&
           $('#shipping_address_zip').val().length > 0

          $('#shipping_address_zip').attr('data-value', $('#shipping_address_zip').val())
          CityField.getDelivery()

      # Нажатие ENTER
      $('#shipping_address_zip').bind 'keydown', (e) ->
        if e.keyCode == 13
          console.log 'check zip ENTER'

          if CityField.requestStatus == 1 &&
             $('#shipping_address_zip').attr('data-value') != $('#shipping_address_zip').val() &&
             $('#shipping_address_zip').val().length > 0

            $('#shipping_address_zip').attr('data-value', $('#shipping_address_zip').val())
            CityField.getDelivery()

    # Переносим подпись с городом в пункте выдачи на одну строку
    #    $('.delivery_variants tr:nth-child(2)').find('#my').insertBefore($('.delivery_variants tr:nth-child(2)').find('#my').parent().find('> label > br'))

    # Отключение автозаполнения поля с городом
    $(CityField.field_id).attr('autocomplete', 'off')

    if $(CityField.field_id).val().length == 0 || !Cookies.get('customstreetwear_kladr_city')
      CityField.geoIp()
    else
# Получение списка товаров и скидок в корзине
      CityField.getProductsAndSales(CityField.getDelivery)

    # Событие потери фокуса с поля ввода города
    $(CityField.field_id).bind 'blur', () ->
      if CityField.autocompleteBlock.css('display') == 'block'
        setTimeout () ->
          if $('.address__autocomplete__item--selected').length > 0
            $('.address__autocomplete__item--selected').click()
          else
            $('.address__autocomplete__item').eq(0).click()

          # Если значение в поле город пусто
          if $(CityField.field_id).val() == ''
            CityField.kladr['city'] = ''
            CityField.kladr['city_kladr'] = ''
            CityField.kladr['index'] = ''
            CityField.kladr['region'] = ''
            CityField.kladr['code'] = ''

          # Если введенный город не найден в кладре
          if $('.address__autocomplete div').length == 0
            CityField.kladr['city'] = $(CityField.field_id).val()
            CityField.kladr['city_kladr'] = $(CityField.field_id).val()
            CityField.kladr['index'] = ''
            CityField.kladr['region'] = $(CityField.field_id).val()
            CityField.kladr['code'] = ''

          # Получение списка товаров и скидок в корзине
          CityField.getProductsAndSales(CityField.getDelivery)
        , 300

    # Событие ввода с клавиатуры в поле ввода города при нажатии ENTER
    $(CityField.field_id).bind 'keydown', (e) ->
      if e.keyCode == 13
# Получение списка товаров и скидок в корзине
        CityField.getProductsAndSales(CityField.getDelivery)

    # Событие ввода с клавиатуры в поле ввода города
    $(CityField.field_id).bind 'keyup', (e) ->
      CityField.getKladr()

  ###*
  # Вычисление итоговой стоимости
  ###
  CityField.calcTotal = () ->
    total_price_cart = parseInt(CityField.order.total_price) # суммарная стоимость товаров в корзине
    rel_price = $('.delivery_variants tr.select input[type="radio"]').attr('rel')
    delivery_price = parseInt($(rel_price).attr('data-price')) # сумма доставки

    # Получение суммы скидки
    salePrice = 0

    # Скидка на оплату онлайн
    salePriceOnline = 0

    if !$('.payment_variants').hasClass('loader')

# Общие скидки
      if CityField.sales.length > 0
        $(CityField.sales).each (i, e) ->
          salePrice += Math.abs(parseInt(e.amount))

      if CityField.maxTotalPrice > CityField.order.total_price &&
         CityField.for_order.payments[CityField.id_payment_online_2] != undefined &&
         $('#order_payment_gateway_id_' + CityField.id_payment_online).parent().hasClass('select')
        salePriceOnline += Math.abs(Math.floor(parseFloat($('#summ_' + CityField.id_payment_online_2).attr('data-price'))))

    total_price = total_price_cart + delivery_price

    result = {
      delivery_price: delivery_price
      total_price_cart: total_price_cart
      total_sale_price: salePrice + salePriceOnline
      sale_price: salePrice
      sale_price_online: salePriceOnline
      total_price: total_price
    }

    return result

  ###*
  # Скрытие способов доставки при превышении максимальной стоимости
  ###
  CityField.checkMaxTotalPrice = () ->
    if CityField.order.total_price > CityField.maxTotalPrice
      $('#order_payment_gateway_id_' + CityField.id_payment).parent().parent().remove()
      $('#order_payment_gateway_id_' + CityField.id_payment_postcalc).parent().parent().remove()

    return true

  ###*
  # Получение ip клиента
  ###
  CityField.getIp = () ->
    ip = Cookies.get('customstreetwear_ip')
    if !ip
      $.post 'http://82.196.3.195:8008/ip.php',
        (response) ->
          d = new Date(new Date().getTime() + 60 * 60 * 1000)
          Cookies.set('customstreetwear_ip', response, {expires: d.toUTCString()});
          ip = response

    return ip

  ###*
  # Получение индексов кладра для города
  ###
  CityField.getIndexKladr = (geoData) ->
    cityName = geoData['city']['name_ru']
    regionName = geoData['region']['name_ru']
    cid = null
    cindex = null
    rid = null

    paramCity = {
      'key': @kladr_key,
      'token': @kladr_token,
      'limit': @kladr_limit,
      'query': cityName,
      'contentType': 'city',
      'limit': 1
    }

    # Получение индекса для региона
    getZipForRegion = () ->
      $.ajax {
        'url': 'http://kladr-api.ru/api.php',
        dataType: "jsonp",
        'data': {
          'key': @kladr_key,
          'token': @kladr_token,
          'limit': @kladr_limit,
          'query': regionName,
          'contentType': 'region',
          'limit': 1
        },
        success: (response) ->
          if response.result[0]['id']
            rid = response.result[0]['id']
            getZipForCity()
      }

    # Получение индекса для города
    getZipForCity = () ->
      if rid
        paramCity['regionId'] = rid
      else
        return

      $.ajax {
        'url': 'http://kladr-api.ru/api.php',
        dataType: "jsonp",
        'data': paramCity,
        success: (response) ->
          if response.result[0]['id']
            cid = response.result[0]['id']
            cindex = response.result[0]['zip']

            if !cid
              return

            geoData['region']['id'] = rid
            geoData['city']['id'] = cid
            geoData['city']['index'] = cindex

            getZipForCityId()
      }


    # Поиск почтового индекса по id города
    getZipForCityId = () ->
      if cindex == null
        street = null

        $.ajax {
          'url': 'http://kladr-api.ru/api.php',
          dataType: "jsonp",
          'data': {
            'key': @kladr_key,
            'token': @kladr_token,
            'limit': @kladr_limit,
            'query': '',
            'contentType': 'street',
            'cityId': cid,
            'limit': 1
          },
          success: (response) ->
            street = response

            if !street['result'] || !street['result'][0]
              return null

            if street['result'][0]['zip'] != null
              geoData['city']['index'] = street['result'][0]['zip']
            else
              sid = street['result'][0]['id']

              # Поиск почтового индекса по id улицы
              $.ajax {
                'url': 'http://kladr-api.ru/api.php',
                dataType: "jsonp",
                'data': {
                  'key': @kladr_key,
                  'token': @kladr_token,
                  'limit': @kladr_limit,
                  'query': '',
                  'contentType': 'building',
                  'streetId': sid,
                  'limit': 1
                },
                success: (response) ->
                  street = response
                  if street['result'][0]['zip']
                    geoData['city']['index'] = street['result'][0]['zip']
                    return geoData
                  else
                  return null
              }
        }

    getZipForRegion()

    return geoData

  ###*
  # Определение местоположения клиента по IP
  ###
  CityField.geoIp = () ->
    updateCityField = (geoIp) ->
      $(CityField.field_id)[0].value = geoIp['city']['name_ru']
      CityField.kladr['city'] = geoIp['city']['name_ru']
      CityField.kladr['city_kladr'] = geoIp['city']['name_ru']
      CityField.kladr['index'] = geoIp['city']['ind']
      CityField.kladr['region'] = geoIp['region']['name_ru']
      CityField.kladr['kladr_code'] = geoIp['city']['index']
      # Получение списка товаров и скидок в корзине
      CityField.getProductsAndSales(CityField.getDelivery)

    if !Cookies.get('customstreetwear_geoip')
#      CityField.getIp()
      $.post 'http://82.196.3.195:8008/ip.php',
        (response) ->
          $.get 'http://ru2.sxgeo.city/8SANV/json/' + response, (response) ->
            geoIp = response

            if geoIp
              geoIp = CityField.getIndexKladr(geoIp)

            if geoIp
              d = new Date(new Date().getTime() + 60 * 60 * 1000)
              Cookies.set('customstreetwear_geoip', JSON.stringify(geoIp), {expires: d.toUTCString()});
            updateCityField(geoIp)

    else
      geoIp = JSON.parse(Cookies.get('customstreetwear_geoip'))
      updateCityField(geoIp)

    if geoIp && geoIp['country']['name_en'].toLowerCase() != 'russia'
      return null

  ###*
  # Получение списка товаров и скидок в корзине
  ###
  CityField.getProductsAndSales = (callback) ->

# Удаление сообщения о недоступности способов доставки
    $('#delivery_variants .message_delivery').remove()

    # Добавляем прелоадер к способам доставки
    $('.delivery_variants').show()
    $('.delivery_variants').addClass('loader')
    if $('.delivery_variants tbody .load').length == 0
      $('.delivery_variants tbody').append('<tr class="load"><td></td></tr>')

    # Блокировка кнопки заказа
    $('input[type="submit"]').hide()

    # Получение скидки для оплаты онлайн
    #    $.post 'http://' + CityField.login + ':' + CityField.pass + '@' + document.domain + '/admin/payment_gateways/' + CityField.id_payment_online_2, (response) ->
    #      console.log response
    #    return

    # Получение скидок и списка товаров в заказе
    getSalesAndOrder = (order) ->
      CityField.order = order

      CityField.quantity_products = 0

      CityField.products = CityField.order.order_lines

      $.each CityField.products, (index, item) ->
        CityField.quantity_products += parseInt(item.quantity)

      CityField.sales = CityField.order.discounts

      # Удаление размеров из названия товара в списке

      if !$('.set-list').hasClass('set-list-item-ready')

        $('.set-list-item').each (i, e) ->
          $.each CityField.products, (index, item) ->
            html = $(e).find('.description p').html()

            if i == index
              console.log html.match(CityField.products[index].title)
              size = 'Размер ' + html.substr(CityField.products[index].title.indexOf('('), CityField.products[index].title.length).replace(/\(|\)/g, '')
              $(e).find('.description p:first-child').html(CityField.products[index].title)
              $(e).find('.description p:last-child').html(size + ', <span>' + $(e).find('.description p:last-child').html() + '</span>')
              $(e).find('.description p:first-child').after('<p>' + CityField.products[index].comment.substr(0, CityField.products[index].comment.indexOf(',')) + '</p>')

        $('.set-list').addClass('set-list-item-ready')
        $('.set-list-item .description').css('opacity', 1)

      # Проверка максимальной стоимости
      CityField.checkMaxTotalPrice()

      callback()

    cartOrderFormCookie = Cookies.get('cart_order_form')

    if cartOrderFormCookie

      order = JSON.parse(cartOrderFormCookie)
      getSalesAndOrder(order)

    else

      $.getJSON '/cart_items_with_accessories.json', (order) ->

        getSalesAndOrder(order)

      .fail () ->
        CityField.getProductsAndSales(callback)

    return

  ###*
  # Получение списка городов из kladr
  ###
  CityField.getKladr = () ->
    query = $(@field_id).val().replace("ё", "е")
    CityField.clearKladr()
    CityField.autocompleteBlock.removeClass('trans')
    $.ajax {
      'url': 'http://kladr-api.ru/api.php',
      dataType: "jsonp",
      'data': {
        'key': @kladr_key,
        'token': @kladr_token,
        'limit': @kladr_limit,
        'query': query,
        'contentType': 'city',
        'withParent': 1
      },
      success: (response) ->
        html = CityField.buildVariants(response.result, query, response.searchContext)
        CityField.autocompleteBlock.show()
        CityField.autocompleteBlock.html(html)
        if CityField.autocompleteBlock.find('*').length == 0
          CityField.autocompleteBlock.addClass('trans')
        CityField.clickAutocompleteItem()
    }

  ###*
  # Вывод скидки в сайдбаре
  ###
  CityField.setSaleSidebar = () ->
    prices = CityField.calcTotal()

    if $('.set-sidebar .set-meta-custom').length > 0
      $('.set-sidebar .set-meta-custom').remove()

    total_price_view = '<div class="fc b"><p class="fl">Итого:</p><p class="fr prices-current">' + prices.total_price + ' руб.</p></div>'

    if prices.total_sale_price > 0 || prices.delivery_price > 0

      $('.set-sidebar').append('<div class="set-meta set-meta-custom"></div>')

      if prices.total_sale_price > 0

        $('.set-sidebar .set-meta-custom').append('<div class="fc meta_sale"><p class="fl">Скидка:</p><p class="fr prices-current">-' + prices.total_sale_price + ' руб.</p></div>')
        total_price_view = '<div class="fc b prices-sale"><p class="fl">Итого:</p><p class="fr prices-current"><span>' + (prices.total_price + prices.sale_price) + ' руб.</span>' + (prices.total_price - prices.sale_price_online) + ' руб.</p></div>'

      if prices.delivery_price > 0

        $('.set-sidebar .set-meta-custom').append('<div class="fc"><p class="fl">Доставка:</p><p class="fr prices-current">' + prices.delivery_price + ' руб.</p></div>')


    $('.set-sidebar .set-meta-custom').append(total_price_view)

  ###*
  # Получение данных о доставке
  ###
  CityField.getDelivery = () ->

# Ограничение по времени обработки оформления заказа
    CityField.limit = CityField.limitDefault
    CityField.limiter()

    # Параметры запроса способов доставки

    index = if CityField.kladr['index'] then CityField.kladr['index'] else Cookies.get('customstreetwear_kladr_index')

    if $('#shipping_address_zip').val().length > 0
      index = parseInt($('#shipping_address_zip').val())

    params = {
      city: $.trim(if CityField.kladr['city'] then CityField.kladr['city'] else Cookies.get('customstreetwear_kladr_city')).replace('г. ', ''),
      city_kladr: $.trim(if CityField.kladr['city_kladr'] then CityField.kladr['city_kladr'] else Cookies.get('customstreetwear_kladr_city_kladr')).replace('г. ', ''),
      index: index,
      region: $.trim(if CityField.kladr['region'] then CityField.kladr['region'] else Cookies.get('customstreetwear_kladr_region')),
      kladr_code: $.trim(if CityField.kladr['kladr_code'] then CityField.kladr['kladr_code'] else Cookies.get('customstreetwear_kladr_code')),
      products: JSON.stringify(CityField.products),
      sales: JSON.stringify(CityField.sales)
    }

    # Удаление блока с РКО
    $('.rko').remove()

    # Сброс статуса запроса
    CityField.requestStatus = 0

    # Удаление сообщения о недоступности способов доставки
    $('#delivery_variants .message_delivery').remove()

    # Позакать блок со способами доставки
    $('.delivery_variants').show()

    #Прелодер для способов доставки
    $('.delivery_variants').addClass('loader')
    if $('.delivery_variants tbody .load').length == 0
      $('.delivery_variants tbody').append('<tr class="load"><td></td></tr>')

    #Прелодер для способов оплаты
    $('.payment_variants').addClass('loader')
    if $('.payment_variants tbody .load').length == 0
      $('.payment_variants tbody').append('<tr class="load"><td></td></tr>')

    # Блокировка поля город
    $(@field_id).prop('disabled', true)

    # Скрытие всех способов доставки
    $('#order_delivery_variant_id_' + CityField.id_delivery_courier).parent().parent().hide()
    $('#order_delivery_variant_id_' + CityField.id_delivery_points).parent().parent().hide()
    $('#order_delivery_variant_id_' + CityField.id_delivery_post_calc).parent().parent().hide()

    if !CityField.kladr['region']
      CityField.kladr['region'] = CityField.kladr['city_kladr']

    # Получение скидки для оплаты онлайн

    getMargin = () ->
      $.ajax {
        url: '/payment/for_order.json',
        type: 'PUT',
        dataType: 'json',
        data: $('#order_form').serialize(),
        timeout: 10000,
        success: (data) ->
          CityField.countRequestForMargin++

          CityField.for_order = data

          if data.payments[CityField.id_payment_online_2] != undefined || CityField.countRequestForMargin > 2
            if data.payments[CityField.id_payment_online_2] != undefined
              CityField.margin = Math.abs(parseInt(data.payments[CityField.id_payment_online_2].margin))

            CityField.countRequestForMargin = 0

            callbackDelivery()
          else
            getMargin()
      }

    getMargin()

    callbackDelivery = () ->

# Курьер и Пункты выдачи
      $.post 'http://82.196.3.195:8008/delivery.php',
        params
        (response) ->
          $(CityField.field_id).prop("disabled", false)
          CityField.variantsDelivery = response

          $('.delivery_info').remove()

          # После получения способов доставки курьер и пункты выдачи делаем запрос к почте россии
          $.post 'http://82.196.3.195:8008/postcalc.php',
            params
            (response) ->
              $(CityField.field_id).prop("disabled", false)
              CityField.variantsDeliveryPost = response

              # Установка статуса запроса
              CityField.requestStatus = 1

              # Если заказ меньше заданной суммы, то выводим скидку
              if CityField.order.total_price <= CityField.maxTotalPrice
                CityField.setSaleForOnlinePay()
              else

# Выводим способ оплаты почта росии
                CityField.changeVariantsDeliveryPostcalc()

                # Выводим способ оплаты курьер и пункты выдачи
                CityField.changeVariantsDelivery()

              # Разблокировка кнопки заказа
              $('input[type="submit"]').show()

              return
            'JSON'

          return
        'JSON'

    return

  ###*
  # Установка РКО
  ###
  CityField.setRKO = (rko, rko_class) ->
    console.log 'setRKO' + rko + $('#order_payment_gateway_id_' + CityField.id_payment_postcalc).parent().parent().css('display')
    $('#payment_gateways .rko').remove()
    if CityField.maxTotalPrice > CityField.order.total_price
      $('#payment_gateways').append('<div class="rko ' + rko_class + '"></div>')
      $('#payment_gateways .' + rko_class).html('+ ' + rko + ' руб')

  ###*
  # Вывод сообщения о невозможности посчитать доставку
  ###
  CityField.outputMessageDelivery = () ->
    $('#delivery_variants .message_delivery').remove()
    $('#delivery_variants').append('<div class="message_delivery">Не удалось посчитать доставку, будет рассчитано оператором при подтверждении заказа.</div>')
    $('.delivery_variants').hide()

  ###*
  # Проверка способов доставки, если нет, то выводим сообщение
  ###
  CityField.checkEnableDelivery = () ->
    console.log 'checkEnableDelivery' + CityField.limit

    if CityField.limit != -1

      countVisible = 0
      $('#delivery_variants tr').each (i, e) ->
        if $(e).css('display') == 'none'
          countVisible++

      if $('#delivery_variants tr:not(.not_available)').length == 0 ||
         $('#delivery_variants tr').length == countVisible

        CityField.outputMessageDelivery()
        $('#order_field_' + CityField.id_delivery_point_description).val('')
        $('.set-sidebar .fc.b p.fl').text('Итого:')
      else
        $('#delivery_variants .message_delivery').remove()
        $('.set-sidebar .fc.b p.fl').text('Итого:')
        $('.delivery_variants').show()

        # Добавляем прелоадер к способам оплаты
        $('.payment_variants').addClass('loader')
        if $('.payment_variants tbody .load').length == 0
          $('.payment_variants tbody').append('<tr class="load"><td></td></tr>')

  ###*
  # Установка скидки на оплату онлайн
  ###
  CityField.setSaleForOnlinePay = () ->
    console.log 'setSale = '

    # Добавляем РКО к способам доставки
    CityField.changeVariantsDeliveryPostcalc(true)
    CityField.changeVariantsDelivery(true)

  ###*
  # Вывод срока доставки
  ###
  CityField.printEstimate = (min, max) ->
    estimate = ''
    if min
      estimate += min
    if max
      estimate += '-' + max + ' ' + CityField.dayText(max)
    else
      estimate += ' ' + CityField.dayText(min)
    return estimate

  ###*
  # Выбор варианта доставки (почта россии)
  ###
  CityField.changeVariantsDeliveryPostcalc = (rko) ->
    rko = rko || 0

    id_delivery_post_calc = CityField.id_delivery_post_calc

    if CityField.variantsDeliveryPost.err
      delivery = {
        "id": id_delivery_post_calc,
        "available": true,
        "active": true,
        "html_id": null,
        "price": null,
        "fields_values": [],
        "selected": false,
        "description": null,
        "description_html": null,
        "is_external": false,
        "external_url": null,
        "external_data": {}
      }

      $('#order_delivery_variant_id_' + id_delivery_post_calc).trigger('update:insales:delivery', delivery)
      $('#order_delivery_variant_id_' + id_delivery_post_calc).trigger('disable:insales:delivery')
      $('#order_delivery_variant_id_' + id_delivery_post_calc).parent().parent().hide()

      $('.delivery_variants tr:nth-child(3)').find('small').empty()
      # Обновление оплаты при получении
      $('#payment_gateways .rko_post').remove()
    else
      deliveryType = CityField.variantsDeliveryPost.deliveryType
      estimate = CityField.variantsDeliveryPost.estimate + ' ' + CityField.dayText(parseInt(CityField.variantsDeliveryPost.estimate))

      $('.delivery_variants tr:nth-child(3)').show()
      $('.delivery_variants tr:nth-child(3)').find('.price > span').addClass('show')

      setTimeout () ->
        if !CityField.variantsDelivery.courier && !CityField.variantsDelivery.points
          $('.delivery_variants tr:nth-child(3)').find('input[type="radio"]').click()
          $('.delivery_variants tr:nth-child(3)').find('input[type="radio"]').trigger('enable:insales:delivery')
      , 2000

      $('.delivery_variants tr:nth-child(3)').find('input[type="radio"]').click () ->

# Обновление способов оплаты
        CityField.checkPaymentMethods()
        # Описание типа почтовой доставки в админке
        descriptionDeliveryPost = 'Почта России ' + CityField.variantsDeliveryPost.deliveryType
        $('#order_field_' + CityField.id_delivery_point_description).val(descriptionDeliveryPost)

      # Обновление способа доставки с курьером
      delivery = {
        "id": id_delivery_post_calc,
        "available": true,
        "active": true,
        "html_id": '#order_delivery_variant_id_' + id_delivery_post_calc,
        "price": CityField.variantsDeliveryPost.totalCost,
        "fields_values": [],
        "selected": false,
        "description": null,
        "description_html": deliveryType + '<br/>' + estimate,
        "is_external": false,
        "external_url": null,
        "external_data": {}
      }

      $('#order_delivery_variant_id_' + id_delivery_post_calc).trigger('update:insales:delivery', delivery)

  ###*
  # Склонение дней
  ###
  CityField.dayText = (day, type) ->
    type = type || 0

    declOfNum = (number, titles) ->
      cases = [2, 0, 1, 1, 1, 2]

      return titles[if (number % 100 > 4 && number % 100 < 20) then 2 else cases[if (number % 10 < 5) then number % 10 else 5]]

    if type
      return declOfNum(day, ['рабочего дня', 'рабочих дней', 'рабочих дней'])
    else
      return declOfNum(day, ['рабочий день', 'рабочих дня', 'рабочих дней'])

  ###*
  # Выбор варианта доставки (курьер или пункт выдачи)
  ###
  CityField.changeVariantsDelivery = (rko) ->
    rko = rko || false

    $('.delivery_variants script').remove()

    id_delivery_courier = CityField.id_delivery_courier
    id_delivery_points = CityField.id_delivery_points

    if !CityField.variantsDelivery.courier

      delivery = {
        "id": id_delivery_courier,
        "available": true,
        "active": true,
        "html_id": null,
        "price": null,
        "fields_values": [],
        "selected": false,
        "description": null,
        "description_html": null,
        "is_external": false,
        "external_url": null,
        "external_data": {}
      }

      $('#order_delivery_variant_id_' + id_delivery_courier).trigger('update:insales:delivery', delivery)
      $('#order_delivery_variant_id_' + id_delivery_courier).trigger('disable:insales:delivery')
      $('#order_delivery_variant_id_' + id_delivery_courier).parent().parent().hide()

      $('.delivery_variants tr:nth-child(1)').find('.name > div').empty().removeClass('show')
      $('.delivery_variants tr:nth-child(1)').find('small').empty()
      # Обновление оплаты при получении
      $('#payment_gateways .rko_courier').remove()
    else
      partner = 'Служба доставки ' + CityField.variantsDelivery.courier.parnter_name
      estimate = ''
      if CityField.variantsDelivery.courier.min_estimate
        estimate += CityField.variantsDelivery.courier.min_estimate
      if CityField.variantsDelivery.courier.max_estimate
        estimate += '-' + CityField.variantsDelivery.courier.max_estimate
        estimate += ' ' + CityField.dayText(CityField.variantsDelivery.courier.max_estimate)
      else
        estimate += ' ' + CityField.dayText(CityField.variantsDelivery.courier.min_estimate)

      $('.delivery_variants tr:nth-child(1)').show()
      $('.delivery_variants tr:nth-child(1)').find('.name > div').eq(0).hide()
      $('.delivery_variants tr:nth-child(1)').find('.price > span').addClass('show')
      $('.delivery_variants tr:nth-child(1)').find('input[type="radio"]').click()
      $('.delivery_variants tr:nth-child(1)').find('input[type="radio"]').click () ->
#        $('#order_field_3224898').val('')
# Обновление способов оплаты
        CityField.checkPaymentMethods()

        $('#order_field_' + CityField.id_delivery_point_description).val('')

      # Обновление способа доставки с курьером
      delivery = {
        "id": id_delivery_courier,
        "available": true,
        "active": true,
        "html_id": '#order_delivery_variant_id_' + id_delivery_courier,
        "price": CityField.variantsDelivery.courier.cost + if rko then CityField.variantsDelivery.courier.RKO else 0,
        "fields_values": [],
        "selected": false,
        "description": null,
        "description_html": partner + '<br/>' + estimate,
        "is_external": false,
        "external_url": null,
        "external_data": {}
      }

      $('#order_delivery_variant_id_' + id_delivery_courier).trigger('update:insales:delivery', delivery)


    if !CityField.variantsDelivery.points
      delivery = {
        "id": id_delivery_points,
        "available": true,
        "active": true,
        "html_id": null,
        "price": null,
        "fields_values": [],
        "selected": false,
        "description": null,
        "description_html": null,
        "is_external": false,
        "external_url": null,
        "external_data": {}
      }

      $('#order_delivery_variant_id_' + id_delivery_points).trigger('update:insales:delivery', delivery)
      #      setTimeout () ->
      $('#order_delivery_variant_id_' + id_delivery_points).trigger('disable:insales:delivery')
      $('#order_delivery_variant_id_' + id_delivery_points).parent().parent().hide()
      #      , 2000
      $('.delivery_variants tr:nth-child(2)').find('select#pvz').find('option').remove()
      $('.delivery_variants tr:nth-child(2)').find('#my').empty()
      $('.delivery_variants tr:nth-child(2)').find('small').empty()

    else
      if !CityField.variantsDelivery.courier
        $('.delivery_variants tr:nth-child(2)').find('input[type="radio"]').click()

      $('.delivery_variants tr:nth-child(2)').show()

      $('.delivery_variants tr:nth-child(2)').find('input[type="radio"]').click () ->
#        $('#order_field_3224898').val($('select#pvz').val())

# Обновление способов оплаты
        CityField.checkPaymentMethods()

        # Обновление РКО оплаты при получении
        payment = {
          "id": CityField.id_payment,
          "available": true,
          "active": true,
          "html_id": '#order_payment_gateway_id_' + CityField.id_payment,
          "price": parseInt($('#order_delivery_variant_id_' + CityField.id_delivery_points).parent().parent().find('option:selected').attr('data-rko')),
          "fields_values": [],
          "selected": false,
          "description": null,
          "description_html": null,
          "is_external": false,
          "external_url": null,
          "external_data": {}
        }

        $('#order_payment_gateway_id_' + CityField.id_payment).trigger('update:insales:payment', payment)

      #      $('#order_delivery_variant_id_' + id_delivery_points).trigger('enable:insales:delivery')
      estimate = 'от  '
      if CityField.variantsDelivery.points.min_estimate
        estimate += CityField.variantsDelivery.points.min_estimate
      if CityField.variantsDelivery.points.max_estimate
        estimate += '-' + CityField.variantsDelivery.points.max_estimate
        estimate += ' ' + CityField.dayText(CityField.variantsDelivery.points.max_estimate, 1)
      else
        estimate += ' ' + CityField.dayText(CityField.variantsDelivery.points.min_estimate, 1)

      price = CityField.variantsDelivery.points.cost

      $('.delivery_variants tr:nth-child(2)').find('.name > div').eq(0).hide()
      $('.delivery_variants tr:nth-child(2)').find('.price > span').addClass('show')
      $('.delivery_variants tr:nth-child(2)').find('select#pvz').find('option').remove()
      $('.delivery_variants tr:nth-child(2)').find('input[type="radio"]').css({
        'cursor': 'pointer',
        'opacity': 1
      })

      $('.delivery_variants tr:nth-child(2)').find('select#pvz').bind 'change', () ->

        # Добавляем прелоадер к способам оплаты
        $('.payment_variants').addClass('loader')
        if $('.payment_variants tbody .load').length == 0
          $('.payment_variants tbody').append('<tr class="load"><td></td></tr>')

        $('.delivery_info').remove()
        $(this).parent().parent().after('<div class="delivery_info"><ul></ul></div>')
        $optionSelected = $(this).find('option:selected')
        $deliveryInfoContainer = $('.delivery_info ul')
        adress = $optionSelected.attr('data-adress')
        adress1 = adress.substr(0, adress.indexOf(',')).toLowerCase()
        adress1 = adress1.split(' ')
        adress1.forEach(
          (e, i) ->
            adress1[i] = adress1[i].charAt(0).toUpperCase() + adress1[i].slice(1)
        )
        adress1 = adress1.join(' ')
        adress2 = adress.substr(adress.indexOf(','), adress.length)

        estimate = CityField.printEstimate($optionSelected.attr('data-min-estimate'), $optionSelected.attr('data-max-estimate'));

        $('#delivery_description_' + CityField.id_delivery_point_description).html(estimate)

        deliveryInfoArray = {
          "<div class='head'>Адрес:</div> ": adress1 + adress2
#          "<div class='head'>Как проехать:</div> ": "",
#          "<div class='head'>Срок хранения заказа:</div> ": "",
          "<div class='head'>Телефон:</div> ": $optionSelected.attr('data-phone')
          "<div class='head'>Время работы:</div> ": $optionSelected.attr('data-workTime')
        }

        $('#order_field_' + CityField.id_delivery_point_description).val('Пункт выдачи ' + $optionSelected.val())

        Object.keys(deliveryInfoArray).forEach((item, i) ->
          $deliveryInfoContainer.append('<li>' + item + " " + deliveryInfoArray[item] + '</li>')
        )

        $('.delivery_variants tr:nth-child(2)').find('input[type="radio"]').click()

        pr = $(this).find('option:selected').attr('data-price')
        $('#delivery_price').empty().append(pr + ' руб.')

        $('*[name="order[delivery_price]"]').val(pr)

        delivery = {
          "id": id_delivery_points,
          "available": true,
          "active": true,
          "html_id": '#order_delivery_variant_id_' + id_delivery_points,
          "price": parseInt(pr) + parseInt(if rko then $(this).find('option:selected').attr('data-rko') else 0),
          "fields_values": [],
          "selected": false,
          "description": null,
          "description_html": estimate,
          "is_external": false,
          "external_url": null,
          "external_data": {}
        }

        $('#order_delivery_variant_id_' + id_delivery_points).trigger('update:insales:delivery', delivery)

      arrayPrices = Object.keys(CityField.variantsDelivery.points.list).map((key) -> return CityField.variantsDelivery.points.list[key].price)

      if rko
        arrayRKO = Object.keys(CityField.variantsDelivery.points.list).map((key) -> return CityField.variantsDelivery.points.list[key].RKO)

      delivery = {
        "id": id_delivery_points,
        "available": true,
        "active": true,
        "html_id": '#order_delivery_variant_id_' + id_delivery_points,
        "price": Math.min.apply(Math, arrayPrices) + if rko then parseInt(Math.min.apply(Math, arrayRKO)) else 0,
        "fields_values": [],
        "selected": false,
        "description": null,
        "description_html": estimate,
        "is_external": false,
        "external_url": null,
        "external_data": {}
      }

      $('#order_delivery_variant_id_' + id_delivery_points).trigger('update:insales:delivery', delivery)

      #      $('.delivery_variants tr:nth-child(2)').find('#my').empty().append('в ' + $('#shipping_address_city').val())

      $('.delivery_variants tr:nth-child(2)').find('select#pvz').append('<option value="" selected disabled>Выберите пункт выдачи</option>')

      $.each CityField.variantsDelivery.points.list, (index, item) ->
        price = (parseInt(item.price) + parseInt(if rko then item.RKO else 0)) + ' РУБ.'
        $('.delivery_variants tr:nth-child(2)').find('select#pvz').append('<option value="' + item.name + ' ' + item.adress + ' ' + item.phone + '" data-adress="' + item.adress + '" data-rko="' + item.RKO + '"  data-code="' + item.code + '" data-price="' + item.price + '" data-min-estimate="' + item.min_estimate + '" data-max-estimate="' + item.max_estimate + '" data-worktime="' + item.workTime + '" data-phone="' + item.phone + '">' + item.name + ' - ' + price + '</option>')

  ###*
  # Обработка события нажатия на город в выпадающем списке
  ###
  CityField.clickAutocompleteItem = () ->
    CityField.autocompleteBlock.find('.address__autocomplete__item').click (e) ->
      CityField.autocompleteBlock.hide()
      selected = @
      contentType = 'city'
      id = selected.getAttribute('data-id')
      name = selected.getAttribute('data-full-name')
      if selected.getAttribute('data-parent-full-name').length > 0
        name = name + ', ' + selected.getAttribute('data-parent-full-name')
      data_name = selected.getAttribute('data-name')
      if contentType == 'street'
        name = selected.innerText or selected.textContent or ''
        data_name = selected.innerText or selected.textContent or ''
      name = name.trim()
      $(selected).addClass('address__autocomplete__item--selected')
      $(CityField.field_id)[0].value = name.replace('г. ', '')
      CityField.kladr['city'] = $(selected).attr('data-name')

      if $(selected).attr('data-parent-full-name').length > 0
        CityField.kladr['city_kladr'] = $(selected).attr('data-full-name') + ', ' + $(selected).attr('data-parent-full-name')
      else
        CityField.kladr['city_kladr'] = $(selected).attr('data-full-name')

      CityField.kladr['index'] = $(selected).attr('data-zip')
      CityField.kladr['region'] = if $(selected).attr('data-parent-value') then $(selected).attr('data-parent-value') else CityField.kladr['city_kladr']
      CityField.kladr['kladr_code'] = $(selected).attr('data-id')

      # Запись данных кладр в куки
      CityField.saveKladr(CityField.kladr['city'], CityField.kladr['city_kladr'], CityField.kladr['index'], CityField.kladr['region'], CityField.kladr['kladr_code'])


  ###*
  # Запись данных кладр в куки
  ###
  CityField.saveKladr = (city, kladr_city, index, region, code) ->
    d = new Date(new Date().getTime() + 60 * 60 * 1000)
    Cookies.set('customstreetwear_kladr_city', CityField.kladr['city'], {expires: d.toUTCString()})
    Cookies.set('customstreetwear_kladr_city_kladr', CityField.kladr['city_kladr'], {expires: d.toUTCString()})
    Cookies.set('customstreetwear_kladr_index', CityField.kladr['index'], {expires: d.toUTCString()})
    Cookies.set('customstreetwear_kladr_region', CityField.kladr['region'], {expires: d.toUTCString()})
    Cookies.set('customstreetwear_kladr_code', CityField.kladr['kladr_code'], {expires: d.toUTCString()})

  ###*
  # Проверка способов оплаты
  ###
  CityField.checkPaymentMethods = () ->
    CityField.checkEnableDelivery()

  ###*
  # Валидация email адреса
  ###
  CityField.isEmail = (email) ->
    regex = /^([a-zA-Z0-9_.+-])+\@(([a-zA-Z0-9-])+\.)+([a-zA-Z0-9]{2,4})+$/
    return regex.test(email)

  ###*
  # Валидация полей оформления заказа
  ###
  CityField.validate = (object) ->
    object = object || false

    errors = 0

    if object
      if $(object).parent().parent().hasClass('input--required')
        if $(object).attr('id') == 'client_phone'
          setTimeout () ->
            if $(object).val() == ''
              if $(object).addClass('error')
                errors++
          , 200
        else if $(object).attr('id') == 'client_email'
          if !CityField.isEmail($(object).val())
            if $(object).addClass('error')
              errors++
        else
          if $(object).val() == ''
            if $(object).addClass('error')
              errors++

      # Валидация полей до текущего
      $('.input').each (i, e) ->
        if $(e).hasClass('input--required')

          if $(object).parent().parent().offset().top == $(e).offset().top
            return false
          else
#            console.log $(e).find('input').attr('id') + ' ' + $(e).find('input').val()
            if $(e).find('input:not([readonly])').eq(0).val() == ''
              if $(e).find('input').addClass('error')
                errors++

            if $(e).find('input').attr('id') == 'client_email' && !CityField.isEmail($(e).find('input').val())
              if $(e).find('input').addClass('error')
                errors++

            if $(e).find('textarea').val() == ''
              if $(e).find('textarea').addClass('error')
                errors++

    else
      selectValue = false
      if $('select#pvz option:selected').length > 0
        if ($('select#pvz option:selected').val()).length == 0
          selectValue = true

      if selectValue && $('#order_delivery_variant_id_' + CityField.id_delivery_points).prop('checked')
        $('select#pvz').parent().addClass('error')
        errors++
      else
        $('select#pvz').parent().removeClass('error')

      $('.input').each (i, e) ->
        if $(e).hasClass('input--required')
#          console.log $(e).find('input').attr('id') + ' ' + $(e).find('input').val()
          if $(e).find('input:not([readonly])').eq(0).val() == ''
            if $(e).find('input').addClass('error')
              errors++

          if $(e).find('input').attr('id') == 'client_email' && !CityField.isEmail($(e).find('input').val())
            if $(e).find('input').addClass('error')
              errors++

          if $(e).find('textarea').val() == ''
            if $(e).find('textarea').addClass('error')
              errors++

    if ($('.delivery_variants').hasClass('loader') || $('.payment_variants').hasClass('loader')) && CityField.limit >= 0
      errors++

    return if errors > 0 then false else true

  ###*
  # Лимит обработки получения доставки и оплаты
  ###
  CityField.limiter = () ->
    console.log 'set limiter'
#    if CityField.limit != -1
#      setTimeout () ->
#        if CityField.limit != -1
#          console.log 'end limiter'
#          CityField.limit = -1
#          CityField.outputMessageDelivery()
#          $('.payment_variants').removeClass('loader')
#          $('.payment_variants .load').remove()
#          $('#create_order').show()
#      , CityField.limit

  ###*
  # Очистка данных кладр в куки
  ###
  CityField.clearKladr = () ->
    Cookies.remove('customstreetwear_kladr_city')
    Cookies.remove('customstreetwear_kladr_city_kladr')
    Cookies.remove('customstreetwear_kladr_index')
    Cookies.remove('customstreetwear_kladr_region')
    Cookies.remove('customstreetwear_kladr_code')

  ###*
  # Построение выпадающего списка с городами
  ###
  CityField.buildVariants = (data, query, searchContext) ->
    data.map((el) ->
      fullName = el.name
      type = undefined
      if el.type == 'Автономный округ'
        type = 'autonomus'
      else if el.type == 'Область'
        fullName += ' область'
        type = 'region'
      else if el.type == 'Город'
        type = 'city'
        fullName = 'г. ' + fullName
      else if el.type == 'Республика'
        if !fullName.match(/Республика/gi)
          fullName = 'Республика ' + fullName
        type = 'resp'
      else
        fullName = el.type + ' ' + fullName
      result =
        id: el.id
        name: el.name
        'full-name': fullName
        type: type
        zip: el.zip
        okato: el.okato
      parent = {}
      if el.parents and el.parents.length
        parent = el.parents.filter((parent) ->
            parent.contentType == 'region'
          )[0] or {}
      result['parent-id'] = parent.id or 0
      result['parent-type'] = parent.contentType or ''
      result['parent-value'] = parent.name or ''
      result['parent-full-name'] = (result['parent-value'] + ' ' + (parent.type or '')).trim()
      result
    ).map((el, index) ->
      `var foundIndex`
      `var found`
      `var foundIndex`
      `var found`
      attrs = []
      for n of el
        if el.hasOwnProperty(n)
          attrs.push 'data-' + n + '="' + el[n] + '"'
      fullName = el['full-name']
      inner = ''
      try
        regExp = new RegExp(query, 'i')
        found = fullName.match(regExp)
        foundIndex = if found then found.index else fullName.length
      catch e
        found =
          index: 0
          0: ''
        foundIndex = 0
      inner += fullName.slice(0, foundIndex)
      if foundIndex != fullName.length
        inner += '<span class="address__autocomplete__item__highlight">' + found[0] + '</span>'
        inner += fullName.slice(found.index + found[0].length)
      if el['parent-full-name']
        inner += ', ' + el['parent-full-name']
      className = 'address__autocomplete__item'
      if index == 0
        className += ' address__autocomplete__item--selected'
      '<div class="' + className + '" ' + attrs.join(' ') + '>' + inner.replace('г. ', '') + '</div>'
    ).join ''

$order_form = $('#order_form')

if $order_form.length > 0

# Инициализируем поле с городом
  city = new CityField('cc6ee94721ba7afe85ddb77f636ebcce', '16cb20407b4bbfd0ecf63ea2f25349e3', 5, 'shipping_address_city', 415531, 415532, 3224898, 435233, 344685, 359944, 310842, 3247644)
  city.init()

  # Скрываем поле регион в форме оформления заказа
  $('#shipping_address_state').parent().parent().hide()
  $('#shipping_address_state option').remove()

  # Инициализация способов доставки
  $(document).on 'inited:insales:checkout:deliveries', (e) ->
    $(document).trigger('ready:insales:delivery')
    return false

  $(document).on 'selected:insales:checkout:delivery', (e) ->
    console.log 'selected:insales:checkout:delivery'
  #    $('#order_field_' + CityField.id_delivery_point_description).val('')

  # Обновление способов доставки
  $(document).on 'updated:insales:checkout:delivery', (e) ->
    console.log 'updated:insales:checkout:delivery'

    if CityField.requestStatus == 1

# Проверка, есть ли способы доставки и установка сообщения, в случае, если нет
      CityField.checkEnableDelivery()

      # Удаление прелоадера с блока со способами доставки
      $('.delivery_variants').removeClass('loader')
      $('.delivery_variants .load').remove()

#      CityField.limit = -1;

      # Проверка доступных способов оплаты
      CityField.checkPaymentMethods()
    return

  # Событие выбора способа доставки
  $(document).on 'selected:insales:delivery', (e) ->
    console.log 'selected:insales:delivery'
    $('.payment_variants input[type="radio"]').eq(0).click()
    # Добавляем прелоадер к способам оплаты
    $('.payment_variants').addClass('loader')
    if $('.payment_variants tbody .load').length == 0
      $('.payment_variants tbody').append('<tr class="load"><td></td></tr>')

  # Завершение обновления способов оплаты
  $(document).on 'updated:insales:payment', (e) ->

#    $('#order_payment_gateway_id_' + CityField.id_payment_rko).click()
#    $('#order_payment_gateway_id_' + CityField.id_payment_online).click()
    $(document).trigger 'selected:insales:payment'

    setTimeout () ->
      $('html.html_checkout .body.checkout #payment_gateways .total_price .fr').html($('html.html_checkout .body.checkout .set-sidebar #total_price').html())
      $('html.html_checkout .body.checkout #payment_gateways .total_price .fr span').remove()

      if Math.abs(parseInt($('#summ_' + CityField.id_payment_online).attr('data-price'))) == 0
        $('#order_payment_gateway_id_' + CityField.id_payment_online).parent().parent().find('.price').removeClass('show')

      if $('.payment_variants .load').length > 0

        console.log 'updated:insales:payment'

        # Если выбран способ доставки почта россии
        if $('#order_delivery_variant_id_' + CityField.id_delivery_post_calc).prop('checked')
          CityField.setRKO(CityField.variantsDeliveryPost.RKO, 'rko_post_calc')
        else
          $('.rko_post_calc').remove()

        # Если все способы оплаты загружены
        if $('.payment_variants tbody').height() > 0
# Удаление прелоадера с блока со способами оплаты
          if $('.delivery_variants .load').length == 0
            $('.payment_variants').removeClass('loader')
            CityField.setSaleSidebar()
            $('.payment_variants .load').remove()
            $('#payment_gateways .rko').show()
        else
          $('.payment_variants').addClass('loader')
          if $('.payment_variants tbody .load').length == 0
            $('.payment_variants tbody').append('<tr class="load"><td></td></tr>')

      CityField.setSaleSidebar()

    , 1000

  # Событие выбора способов оплаты
  $(document).on 'select:insales:payment', (e) ->
    CityField.setSaleSidebar()

  # Событие окончания выбора способов оплаты
  $(document).on 'selected:insales:payment', (e) ->
    CityField.setSaleSidebar()

    setTimeout () ->
      console.log 'selected:insales:payment'

      if Math.abs(parseInt($('#summ_' + CityField.id_payment_online_2).attr('data-price'))) > 0 &&
         parseInt($('#summ_' + CityField.id_payment_online).attr('data-price')) == 0 &&
         CityField.maxTotalPrice > CityField.order.total_price

# Устанавливаем скидку в оплату при получении
        payment = {
          "id": CityField.id_payment_online,
          "available": true,
          "active": true,
          "html_id": '#order_payment_gateway_id_' + CityField.id_payment_online,
          "price": Math.floor($('#summ_' + CityField.id_payment_online_2).attr('data-price')),
          "fields_values": [],
          "selected": false,
          "description": null,
          "description_html": null,
          "is_external": false,
          "external_url": null,
          "external_data": {}
        }

        console.log 'set payment'

        $('#order_payment_gateway_id_' + CityField.id_payment_online).trigger('update:insales:payment', payment)

        if $('label[for="order_payment_gateway_id_' + CityField.id_payment_online + '"]').length > 0
          $('#order_payment_gateway_id_' + CityField.id_payment_online).parent().parent().find('td.name').find('.sale_description').remove()
          if CityField.margin > 0
            $('#order_payment_gateway_id_' + CityField.id_payment_online).parent().parent().find('td.name').append('<div class="sale_description">Скидка при оплате онлайн ' + CityField.margin + '%</div>')

        $('#order_payment_gateway_id_' + CityField.id_payment_online).parent().parent().find('.price').addClass('show')

      # Если выбран способ доставки почта россии
      if $('#order_delivery_variant_id_' + CityField.id_delivery_post_calc).prop('checked')

# Если выбран способ оплаты Наложенный платеж
        if $('#order_payment_gateway_id_' + CityField.id_payment_postcalc).prop('checked')
          descriptionDeliveryPost = $('#order_field_' + CityField.id_delivery_point_description).val()
          descriptionDeliveryPost += ', РКО: ' + CityField.variantsDeliveryPost.RKO + ' руб.'
          $('#order_field_' + CityField.id_delivery_point_description).val(descriptionDeliveryPost)
        else
          descriptionDeliveryPost = 'Почта России ' + CityField.variantsDeliveryPost.deliveryType
          $('#order_field_' + CityField.id_delivery_point_description).val(descriptionDeliveryPost)

    , 1000

    return

  #Валидация полей оформления заказа на лету
  $('input, textarea, select').each (i, e) ->
    $(e).bind 'blur.validate', () ->
      CityField.validate(this)

  # Событие создания заказа
  orderFormSubmit = () ->
    $order_form.find('input[type="submit"]#create_order').bind 'click', () ->
      if CityField.validate()
        $order_form.submit()
      else
        $('input.error, textarea.error, select.error').eq(0).focus()
        if $('input.error, textarea.error, select.error').eq(0).offset() != undefined
          $(window).scrollTop($('input.error, textarea.error, select.error').eq(0).offset().top - 40)

    $order_form.bind 'submit', () ->
      if CityField.validate()

# Удаление области из города
        orderFormParams = $order_form.serializeArray()
        orderFormParams.forEach((e, i) ->
          if orderFormParams[i].name == 'shipping_address[city]'
            orderFormParams[i].value = orderFormParams[i].value.substr(0, orderFormParams[i].value.indexOf(','))
        )

        if $order_form.find('input[type="submit"]').val() != 'Обработка...'

          callbackSubmit = () ->
            $.post $order_form.attr('action'),
              $order_form.serialize(),
              (response, status, request) ->
                if status == 'success'
                  orig = response
                  res = orig.substr(orig.indexOf('/orders/successful?id='), orig.length)
                  res = res.substr('/orders/successful?id='.length, res.indexOf(')') - 3)
                  res = res.replace(' ', '')
                  order_id = res.substr(0, res.indexOf(';') - 2)

                  if (order_id)
                    orig_number = response
                    number = orig_number.substring(orig_number.indexOf('<title>'), orig_number.indexOf('</title>')).replace(/\D/g, '')

                    # Запись пункта выдачи
                    $.post 'http://82.196.3.195:8008/delivery_set.php',
                      {
                        'id': number
                      }
                    , () ->
                    setTimeout () ->
                      location.href = '/orders/' + order_id
                      return true
                    , 1000
                  else
                    $order_form.unbind('submit').submit()
                    return true

          if $('#order_payment_gateway_id_' + CityField.id_payment_online).prop('checked') && Math.abs(parseInt($('#summ_' + CityField.id_payment_online).attr('data-price'))) > 0

            $(document).on 'updated:insales:payment selected:insales:payment', (e) ->
              callbackSubmit()

            $('#order_payment_gateway_id_' + CityField.id_payment_online_2).click()

          else
            callbackSubmit()

          $order_form.find('input[type="submit"]').val('Обработка...')

      else
        $order_form.find('input[type="submit"]').val('Оформление заказа')

      return false

  orderFormSubmit()