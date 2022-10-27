
$(function(){
    $("#media_objs_nil").sortable({
        connectWith: ["#media_objs_1", "#media_objs_2", "#media_objs_3"]
    });
    $("#media_objs_1").sortable({
        connectWith: ["#media_objs_nil", "#media_objs_2", "#media_objs_3"]
    });
    $("#media_objs_2").sortable({
        connectWith: ["#media_objs_1", "#media_objs_nil", "#media_objs_3"]
    });
    $("#media_objs_3").sortable({
        connectWith: ["#media_objs_1", "#media_objs_2", "#media_objs_nil"]
    });
    $("#update_order").click(function(){
        $.ajax({
            url: $("#media_objs_nil").data("url"),
            type: "PATCH",
            data: $("#media_objs_nil").sortable('serialize'),
        });
        $.ajax({
            url: $("#media_objs_1").data("url"),
            type: "PATCH",
            data: $("#media_objs_1").sortable('serialize'),
        });
        $.ajax({
            url: $("#media_objs_2").data("url"),
            type: "PATCH",
            data: $("#media_objs_2").sortable('serialize'),
        });
        $.ajax({
            url: $("#media_objs_3").data("url"),
            type: "PATCH",
            data: $("#media_objs_3").sortable('serialize'),
        });
        alert("Se han actualizado satisfactoriamente las columnas")
    });
});