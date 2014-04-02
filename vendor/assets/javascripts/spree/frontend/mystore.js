$(document).ready(function() {
  var toggleLoader, setupFilters, filterProducts,
      state = 0,
      Link  = $.noUiSlider.Link;

  toggleLoader = function() {
    $('#overlay-with-spinner').toggle();
  };

  filterProducts = function() {
    var input = $(this);
    var path = window.location.pathname;
    var queryString = input.attr('type') == 'radio' ? 'scope=filters&primary_taxon_id='+input.val() : $('#sidebar_products_search').serialize()+'&scope=filters';
    var fullPath = path + '?' + queryString;
    var contentContainer = $('#wrapper');

    $.ajax({
      url: fullPath,
      beforeSend: toggleLoader
    })
      .done(function(html) {
        state += 1;

        $('html, body').animate({
          scrollTop: $('#subheader').offset().top
        }, 500, function() {
          contentContainer.replaceWith(html);
          setupFilters();
          History.pushState({state: state}, 'state '+state, '?'+queryString);
        });
      })
      .fail(function() {
        contentContainer.html('Oops! something went wrong. Please try again')
      }).always(toggleLoader);
  };

  setupFilters = function() {
    var checkBoxFilters = $('#sidebar input[type="checkbox"]');
    var radioButtonFilters = $('#sidebar input[type="radio"]');
    var priceRange = $('#price .price-range');
    var startPrice = parseInt(priceRange.data('start-price'));
    var endPrice =  parseInt(priceRange.data('end-price'));
    var maximumPrice = parseInt(priceRange.data('max-price'));
    var minimumPrice = parseInt(priceRange.data('min-price'));
    var minPriceInput = $('#min-price');
    var maxPriceInput = $('#max-price');

    $('#sidebar').iCheck({
      cursor: true,
      checkboxClass: 'icheckbox_square-blue',
      radioClass: 'iradio_square-blue'
    });

    checkBoxFilters.on('ifChanged', filterProducts);

    radioButtonFilters.on('ifChecked', filterProducts);

    priceRange.noUiSlider({
      start: [startPrice, endPrice],
      connect: true,
      range: {
        min: minimumPrice,
        max: maximumPrice
      },
      serialization: {
        lower: [new Link({
          target: minPriceInput
        })],
        upper: [new Link({
          target: maxPriceInput
        })],
        format: {
          decimals: 0
        }
      }
    });

    priceRange.on('set', filterProducts);

    minPriceInput.unbind();
    maxPriceInput.unbind();

    $('#min-price, #max-price').on('blur', function() {
      var minPrice = $('#min-price').val();
      var maxPrice = $('#max-price').val();

      priceRange.val([minPrice, maxPrice], {set: true, animate: true});
    });

    // Custom scrollbar
    $('.filter_choices').mCustomScrollbar({
      theme: 'dark-thick'
    });

    // Filter collapse
   $('h6.taxonomy-root, h6.filter-title').on('click', function() {
     var title = $(this)
     var arrow = title.find('.arrow');

     title.next().toggle('slideUp', function() {
       arrow.toggleClass('up');
       arrow.toggleClass('down');
     });
   }); 
  };

  // Filter handlers
  setupFilters();

  // Infinite scroll
  $('#products').infinitescroll({
    navSelector: 'nav.pagination',
    nextSelector: 'nav.pagination a[rel=next]',
    itemSelector: '.product-row',
    loading: {
      finishedMsg: "<em>No more products!</em>",
      msgText: '<em>Loading more products...</em>'
    },
    animate: true
  });
});
