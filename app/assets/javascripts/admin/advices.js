$(function(){
	$(".admin_advices").each(function(e) {
	  
    $('body').on('cocoon:after-insert', function(e, addedPartial){
      addedPartial.find('.advice_companies_focus').focus();
      addedPartial.find('.advice_videos_focus').focus();
      addedPartial.find('.advice_photos_focus').focus();
      addedPartial.find('.advice_files_focus').focus();
      addedPartial.find('.advice_advices_focus').focus();
      select = addedPartial.find('select').first();
      // First select is the company, I can't get it by class, so for the moment the only way it is
      select.change(function(){
        if(select.attr("data-type") == 'company'){
          company_id = select.val();
          $.ajax({
            url: '/admin/advices/offices_data?company_id=' + company_id,
            dataType: 'json',
            success: function(data){
              office_select = addedPartial.find('select').last();
              office_select.html("<option></option>"); // clean the options before add new ones.
              $.each(data, function (i, item) {
                  office_select.append($('<option>', { 
                      value: item.id,
                      text : item.name 
                  }));
              });
            },
            error: function(data){
              console.log('error: ', data);
            } 
          });
        }
      })
    });

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

  
  $.each($('.advice_company_select'), function(i, company){
    $(company).change(function(){
      company_id = $(company).val();
      office_select = $('#' + $(company).attr('data-officeSelectID'));
      $.ajax({
        url: '/admin/advices/offices_data?company_id=' + company_id,
        dataType: 'json',
        success: function(data){
          $(office_select).html("<option></option>"); // clean the options before add new ones.
          $.each(data, function (i, item) {
              $(office_select).append($('<option>', { 
                  value: item.id,
                  text : item.name 
              }));
          });
        },
        error: function(data){
          console.log('error: ', data);
        } 
      });
    });
  });

});





