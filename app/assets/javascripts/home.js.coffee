# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
$(document).ready -> $(".accordion").accordion( {collapsible: false,heightStyle: "content"});

$(document).ready -> 
 $("#tabs").tabs({beforeLoad: ( event, ui ) -> (ui.jqXHR.error -> (ui.panel.html("Couldn't load this tab. We'll try to fix this as soon as possible. " +"If this wouldn't be a demo." ););)});
 #$("ul.css-tabs").tabs("div.css-panes > div");


$(document).ready ->($("#rest_menu").menu();
$("#rest_menu").css({left:$("#rest_menu_tab").position().left});
$("#rest_menu").mouseleave -> $("#rest_menu").hide();
$("#rest_menu").hide();
$("#rest_menu_tab").mouseover ->( $(".mouseover_menu").hide();
$("#rest_menu").show());)


changeTaskSettings = (selector,setting) -> (input = $(selector).siblings().find("#task_settings_#{setting}");
selected = $(selector).val();
input.val(selected);
)

setOptionsFor = (menuId,selectedId,request,service,attr,attch) -> ($(menuId).html("<option></option>");
id = $(selectedId).val();
$.getJSON "#{service}/#{id}/#{request}",attch,(data) -> ($.each data, (index, value) ->(val = eval("value.#{attr}");
$(menuId).append("<option value='#{value.id}'>#{val}</option>");)))

$(document).ready -> ($("#db_export").change -> (changeTaskSettings("#db_export","db");
setOptionsFor("#telemetry_export","#db_export","telemetries","databases","name"))
$("#telemetry_export").change -> (changeTaskSettings("#telemetry_export","good"))
$("#target_export").change ->(changeTaskSettings("#target_export","targets")))