$(document).ready(function() {
  var state = 0;
  var Link = $.noUiSlider.Link;

  var toggleLoader = function() {
    $('#overlay-with-spinner').toggle();
  };

  // Price slider filter
  var maximumPrice = myStore.maximum_product_price || 1000;
  var minimumPrice = myStore.minimum_product_price || 1;
  var setupFilters = function() {
    $('#sidebar input[type="checkbox"], #sidebar input[type="radio"]').iCheck({
      cursor: true,
      checkboxClass: 'icheckbox_square-blue',
      radioClass: 'iradio_square-blue'
    });

    $('#sidebar input[type="checkbox"]').on('ifChanged', filterProducts);

    $('#sidebar input[type="radio"]').on('ifChecked', filterProducts);

    $('#price .price-range').noUiSlider({
      start: [minimumPrice, maximumPrice],
      connect: true,
      range: {
        min: minimumPrice,
        max: maximumPrice
      },
      serialization: {
        lower: [new Link({
          target: $('#min-price')
        })],
        upper: [new Link({
          target: $('#max-price')
        })],
        format: {
          decimals: 0
        }
      }
    });

    $('#price .price-range').on('set', filterProducts);

    $('#min-price').unbind();
    $('#max-price').unbind();

    $('#min-price, #max-price').on('blur', function() {
      var minPrice = $('#min-price').val();
      var maxPrice = $('#max-price').val();

      $('#price .price-range').val([minPrice, maxPrice], {set: true, animate: true});
    });

    // Custom scrollbar
    $('#sidebar .filter_choices').mCustomScrollbar({
      theme: "dark-thick"
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


  var filterProducts = function() {
    var path = window.location.pathname;
    var queryString = $('#sidebar_products_search').serialize()+'&scope=filters';
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
