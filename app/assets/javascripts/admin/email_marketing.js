$(function(){
	$(".admin_email_marketings").each(function(e) {
	  $('body').on('cocoon:after-insert', function(e, addedPartial){
      addedPartial.find('.email_marketing_photo_focus').focus();
    });

	});
});
