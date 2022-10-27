function enable_event_selector(){
  if($("#webinar_webinar_type option:selected").val() == "webinar_from_event"){
    $("#webinar_company_special_event_id").prop('disabled', false);
  }
}