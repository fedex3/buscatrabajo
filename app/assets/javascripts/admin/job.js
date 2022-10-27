//= require bootstrap-tagsinput
//= require bootstrap3-typeahead

$(function(){
	$(".admin_jobs").each(function(e) {
	  
    $(document).on('click', 'form[role="search"] button[type="submit"]', function(event) {
      event.preventDefault();
      var $form = $(this).closest('form'),
      $input = $form.find('input');

      link = $form.attr('action');
      params = "";
      if ($input.val() != ""){
        if (params == ""){
          params = "?q=" + $input.val();
        } 
        else{
          params = "&q=" + $input.val();
        }
      }

      window.location.href = link + params;
    });
	});

});

$(document).ready(function() {
  // Load the js only for form view where the field is defined
  if($('#job_skill_list').val() != undefined){
    $('#job_skill_list').tagsinput({
      typeahead: {
        source: function(query) {
          return $.get('/jobs_skills');
        }
      },
    });
    $('#job_skill_list').on('itemAdded', function(event) {
      setTimeout(function() {
      $('.bootstrap-tagsinput :input').val('');
      }, 0);
    });
  }
});



