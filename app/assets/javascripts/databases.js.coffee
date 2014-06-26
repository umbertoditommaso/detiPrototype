# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/


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
good_files_uploader = () ->($("#good_upload").fileupload({dataType:'json','progressInterval':1000,
add: (e,data) -> (@file = data.files[0];
data.context = $('<div/>').appendTo('#good_files');
node = $('<p/>').append($('<span/>')).text(@file.name);
node.append('<br>').append($('<button/>').addClass('btn btn-primary').prop('disabled', false).text('Upload').click -> (data.submit().always(() -> this.remove(););));
node.append($('<div/>').addClass("progress-bar"));
node.find(".progress-bar").progressbar();
node.appendTo(data.context);),
progress: (e,data) -> (data.context.find(".progress-bar").progressbar({value:parseInt(data.loaded / data.total * 100, 10)})),
done: (e,data) -> (data.context.text("Upload #{data.files[0].name} finished.");),});)
################################################################################################################################################################################
db_files_uploader = () -> $("#db_upload").fileupload({dataType:'json',
add: (e,data) -> (data.context = $('<button/>').text("#{data.files[0].name}")
                .appendTo($("#db_upload_status"))
                .click -> (data.context = $('<p/>').text('Uploading...').replaceAll($(this));
                data.submit();
                );),
done: (e,data) -> (data.context.text("#{data.files[0].name} uploaded");
setDataList("#db_gen","#dbfiles","files","version");setDataList("#db_for_import","#imported","telemetries/uploaded","version");)});
####################################################################################################
$(document).ready -> (db_files_uploader();
$("#db_gen").change -> (setDataList("#db_gen","#dbfiles","files","version");
$("#db_upload").fileupload(
    'option',
    'url',
    "/databases/#{$("#db_gen").val()}/upload");
setDbToSelectedValue("#db_gen");)
)

#################################################
$(document).ready -> $("#deleteUploadedButton").click -> ($("#deleteUpload").find("#uploaded").val(true);)
#################################################
$(document).ready ->( good_files_uploader();
$("#db_for_import").change -> ($("#deleteUpload").attr("action","databases/#{$('#db_for_import').val()}/telemetries/delete");
$("#good_upload").fileupload('option','url',"/databases/#{$("#db_for_import").val()}/telemetries/upload");
setDataList("#db_for_import","#processed","telemetries/processed","time");
setDbToSelectedValue("#db_for_import");))
######################################################################


