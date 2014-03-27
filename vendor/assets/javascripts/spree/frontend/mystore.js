$(document).ready(function() {
  var state = 0;
  var Link = $.noUiSlider.Link;

  var showLoder = function(container) {
    container.html('<img class="ajax-loader" src="/assets/loading.gif">');
  }

  $('#sidebar input[type="checkbox"]').iCheck({
    cursor: true,
    checkboxClass: 'icheckbox_square-blue'
  });

  var filterProducts = function() {
    var path = window.location.pathname;
    var queryString = $('#sidebar_products_search').serialize()+'&scope=filters';
    var fullPath = path + '?' + queryString;
    var contentContainer = $('#content');

    $.ajax({
      url: fullPath,
      beforeSend: function() {
        showLoder(contentContainer);
      }
    })
    .done(function(html) {
      state +=1 
     
      $('html, body').animate({
        scrollTop: $('#subheader').offset().top
      }, 500, function() {
        contentContainer.hide().html(html).slideDown(500);
        History.pushState({state: state}, 'state '+state, '?'+queryString);
      });
    })
    .fail(function() {
      contentContainer.html('Oops! something went wrong. Please try again')
    });
  }

  $('#sidebar input[type="checkbox"]').on('ifChanged', function() {
    filterProducts();
  });

  // Price slider filter
  var maximumPrice = myStore.maximum_product_price || 1000;
  var minimumPrice = myStore.minimum_product_price || 1;
  $('#price .price-range').noUiSlider({
    start: [minimumPrice, maximumPrice],
    connect: true,
    range: {
      min: minimumPrice,
      max: maximumPrice
    },
    connect: true,
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
});
