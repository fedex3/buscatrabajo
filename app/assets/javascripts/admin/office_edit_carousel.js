$(function(){
    $("#media_objs_carousel_nil").sortable({
        connectWith: ["#media_objs_carousel"]
    });
    $("#media_objs_carousel").sortable({
        connectWith: ["#media_objs_carousel_nil"]
    });
    $("#update_carousel").click(function(){
        $.ajax({
            url: $("#media_objs_carousel_nil").data("url"),
            type: "PATCH",
            data: $("#media_objs_carousel_nil").sortable('serialize'),
        });
        $.ajax({
            url: $("#media_objs_carousel").data("url"),
            type: "PATCH",
            data: $("#media_objs_carousel").sortable('serialize'),
        });
        alert("Se han actualizado satisfactoriamente las columnas")
    });
});