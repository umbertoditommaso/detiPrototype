

setDataList = (select,selector,request,attr,attch) ->($(selector).html("<option></option>");
id = $(select).val();
$.getJSON "databases/#{id}/#{request}",attch,(data) -> ($.each data, (index, value) ->(val = eval("value.#{attr}");
$(selector).append("<option value='#{value.name}'>#{val}</option>");)))
######################################################################
setDbToSelectedValue = (selector) -> (dbSettings = $(selector).siblings().find("#task_settings_db");
selected = $(selector).val();
dbSettings.val(selected);
)
########################################################################################
########################################################################################
good_files_uploader = () ->($("#experiment_upload").fileupload({dataType:'json','progressInterval':1000,

add: (e,data) -> (@file = data.files[0];
data.context = $('<div/>').appendTo('#experiment_files');
node = $('<p/>').append($('<span/>')).text(@file.name);
node.append('<br>').append($('<button/>').addClass('btn btn-primary').prop('disabled', false).text('Upload').click -> (data.submit().always(() -> this.remove(););));
node.append($('<div/>').addClass("progress-bar"));
node.find(".progress-bar").progressbar();
node.appendTo(data.context);),

progress: (e,data) -> (data.context.find(".progress-bar").progressbar({value:parseInt(data.loaded / data.total * 100, 10)})),

done: (e,data) -> (data.context.text("Upload #{data.files[0].name} finished.");),});)
################################################################################################################################################################################
db_files_uploader = () -> $("#db_exp_upload").fileupload({dataType:'json',
add: (e,data) -> (data.context = $('<button/>').text("#{data.files[0].name}")
                .appendTo($("#db_exp_status"))
                .click -> (data.context = $('<p/>').text('Uploading...').replaceAll($(this));
                data.submit();
                );),
done: (e,data) -> (data.context.text("#{data.files[0].name} uploaded");
setDataList("#db_gen_exp","#exp_dbfiles","files","version");)})
#############################################################################################
changeTaskSettings = (selector,setting) -> (input = $(selector).siblings().find("#task_settings_#{setting}");
selected = $(selector).val();
input.val(selected);
)
##########################################################################################
setOptionsFor = (menuId,selectedId,request,service,attr,attch) -> ($(menuId).html("<option></option>");
id = $(selectedId).val();
$.getJSON "#{service}/#{id}/#{request}",attch,(data) -> ($.each data, (index, value) ->(val = eval("value.#{attr}");
$(menuId).append("<option value='#{value.id}'>#{val}</option>");)))
############################################################################################

$(document).ready -> (db_files_uploader();
good_files_uploader();
$("#db_exp").change -> (setDbToSelectedValue("#db_exp");
$("#experiment_upload").fileupload('option','url',"/databases/#{$("#db_exp").val()}/telemetries/import");
setOptionsFor("#select_telemetry_exp","#db_exp","telemetries","databases","name");)
$("#db_gen_exp").change -> (setDataList("#db_gen_exp","#exp_dbfiles","files","version");
$("#db_exp_upload").fileupload(
    'option',
    'url',
    "/databases/#{$("#db_gen_exp").val()}/upload");
setDbToSelectedValue("#db_gen_exp");)
$("#select_telemetry_exp").change -> (changeTaskSettings("#select_telemetry_exp","good")))