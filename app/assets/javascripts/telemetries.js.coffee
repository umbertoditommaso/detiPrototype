# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/


changeTaskSettings = (selector,setting) -> (input = $(selector).siblings().find("#task_settings_#{setting}");
selected = $(selector).val();
input.val(selected);
)

$(document).ready -> $("#select_telemetry").change ->changeTaskSettings("#select_telemetry","good")
$(document).ready -> $("#telemetry_synt").change ->changeTaskSettings("#telemetry_synt","good")

setOptionsFor = (menuId,selectedId,request,service,attr,attch) -> ($(menuId).html("<option></option>");
id = $(selectedId).val();
$.getJSON "#{service}/#{id}/#{request}",attch,(data) -> ($.each data, (index, value) ->(val = eval("value.#{attr}");
$(menuId).append("<option value='#{value.id}'>#{val}</option>");)))

setDatalist = (selector,request,attr,attch) ->($(selector).html("<option></option>");
id = $("#telemetry").val();
$.getJSON "telemetries/#{id}/#{request}",attch,(data) -> ($.each data, (index, value) ->(val = eval("value.#{attr}");
$(selector).append("<option value='#{value.name}'>#{val}</option>");)))

$(document).ready ->$("#db_extract").change ->(changeTaskSettings("#db_extract","db");
setOptionsFor("#select_telemetry","#db_extract","telemetries","databases","name");)

$(document).ready -> $("#db_synth").change -> (changeTaskSettings("#db_synth","db");
setOptionsFor("#telemetry_synt","#db_synth","telemetries","databases","name");)


$(document).ready -> $("#packets").change ->(data = {packet:$("#packets").val()};
setDatalist("#parameters","parameters","spid",data);)

setTelemetryOptions = (selector,request,attrName,attch) -> setOptionsFor(selector,"#telemetry",request,"telemetries",attrName,attch)

$(document).ready -> $("#channel").change ->(data = {channel:$("#channel").val()};
setTelemetryOptions("#packets","packets","spid",data);)

$(document).ready -> $("#telemetry").change ->(setTelemetryOptions("#channel","virtual_channels","channel");
setTelemetryOptions("#packets","packets","spid");
setDatalist("#parameters","parameters","spid");
setDatalist("#synthetic","synthetic","name");
setDatalist("#logs","logs","name");
)

$(document).ready -> $("#telemetry_check").change -> changeTaskSettings("#telemetry_check","good")

$(document).ready -> $("#db_check").change -> (changeTaskSettings("#db_check","db");
setOptionsFor("#telemetry_check","#db_check","telemetries","databases","name");)

$(document).ready -> $("#explore_db").change -> setOptionsFor("#telemetry","#explore_db","telemetries","databases","name");