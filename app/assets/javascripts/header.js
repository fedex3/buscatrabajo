$(function () {
  // Remove Search if user Resets Form or hits Escape!
  $('body, .navbar-header form[role="search"] button[type="reset"]').on('click keyup', function(event) {
    // console.log(event.currentTarget);
    if (event.which == 27 && $('.navbar-header form[role="search"]').hasClass('active') ||
      $(event.currentTarget).attr('type') == 'reset') {
      closeSearch();
    }
  });

  function closeSearch() {
    var $form = $('.navbar-header form[role="search"].active')
      $form.find('input').val('');
    $form.removeClass('active');
  }

  // Show Search if form is not active // event.preventDefault() is important, this prevents the form from submitting
  $(document).on('click', '.navbar-header form[role="search"]:not(.active) button[type="submit"]', function(event) {
    event.preventDefault();
    var $form = $(this).closest('form'),
      $input = $form.find('input');
    $form.addClass('active');
    $input.focus();

  });

  $(document).on('click', '.navbar-header form[role="search"].active button[type="submit"]', function(event) {
    event.preventDefault();
    var $form = $(this).closest('form'),
    $input = $form.find('input');
    query = $input.val().replace("  ", " ").replace(" ", "-")
    window.location.href = $form.attr('action') + "?q=" + query;
  });

  if($('#arrow_upward').length) {
    $(window).scroll(function(){
      if($(document).scrollTop() > 400) {
        $('#arrow_upward').show();
      }
      else{
        $('#arrow_upward').hide();
      }
    });

    $("#arrow_upward").click(function() {
       $("body, html").animate({ 
        scrollTop: $("#body_div").offset().top - 80
      }, 600);
    });
  }


  $(window).scroll(function(){ // scroll event
    var windowTop = $(window).scrollTop(); // returns number
    var limitSubHeader = 0
    if ($('#navbar_subheader_limit').length){
      limitSubHeader = $('#navbar_subheader_limit').offset().top - 40;
    }
    if (windowTop > limitSubHeader) {
      if (!$('#header_menu').hasClass('hidden-xs')){
        $('#header_menu').addClass('hidden-xs');
        $('#header_menu').addClass('hidden-sm');
      }

    } else {
      if ($('#header_menu').hasClass('hidden-xs')){
        $('#header_menu').removeClass('hidden-xs');
        $('#header_menu').removeClass('hidden-sm');
      }
    }
  });  
});


