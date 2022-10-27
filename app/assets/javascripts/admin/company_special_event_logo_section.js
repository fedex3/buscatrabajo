$(function(){ // document ready
    $('#section-title-field').change(function(e) {
        $(".logo-photos-field").prop("disabled", false)
    });
    $(".logo-photos-field").change(function(e) {
        $(".edit_company_special_event_logo_section").submit();
        $(".new_company_special_event_logo_section").submit();
    });
    $('#btn-send-form').on('click', function(e) {
        if($(".edit_company_special_event_logo_section").submit()){
            $(".edit_company_special_event_logo_section").submit();
            window.location.href ="/admin/company_special_events/"+e.target.dataset.num+"/edit";
        }
        if ($(".new_company_special_event_logo_section").submit()){
            $(".new_company_special_event_logo_section").submit();
            window.location.href ="/admin/company_special_events/"+e.target.dataset.num+"/edit";
        }
        });
});