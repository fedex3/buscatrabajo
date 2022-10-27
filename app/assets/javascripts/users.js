//= require bootstrap-tagsinput
//= require bootstrap3-typeahead
$(function () {
	// document ready
	$(".users").each(function (e) {
		$(".profile-image-upload").change(function (e) {
			$("#edit_user").submit();
		});

		// Load the js only for form view where the field is defined
		if ($("#user_skill_list").val() != undefined) {
			$("#user_skill_list").tagsinput({
				typeahead: {
					source: function (query) {
						return $.get("/jobs_skills?listable=true");
					},
				},
			});
			$("#user_skill_list").on("itemAdded", function (event) {
				setTimeout(function () {
					$(".bootstrap-tagsinput :input").val("");
				}, 0);
			});
		}

		if ($("#user_language_list").val() != undefined) {
			$("#user_language_list").tagsinput({
				typeahead: {
					source: function (query) {
						return $.get("/languages_skills");
					},
				},
			});
			$("#user_language_list").on("itemAdded", function (event) {
				setTimeout(function () {
					$(".bootstrap-tagsinput :input").val("");
				}, 0);
			});
		}
	});
});
