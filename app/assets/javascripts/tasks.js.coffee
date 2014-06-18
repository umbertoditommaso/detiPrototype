# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/



changeTaskSettings = (selector,setting) -> (input = $(selector).siblings("form").children("fieldset").children("input[name='task[settings][#{setting}]']");
selected = $(selector).val();
input.val(selected);
)



#########################################################################################
task_start = (task) -> ( $.post "tasks/#{task.id}/start.json",
(data) -> ($("span.ui-dialog-title").html("#{task.exec} #{data.pid}");
progressbar = $("#task_progress").progressbar({value: false});
id_interval = setInterval((() -> update_status(task,id_interval)), 5000));)
###################################################################################
update_status = (task,interval) -> ($.getJSON("/tasks/#{task.id}/status",(data) -> ($("#task_status").html((data.output.replace(/\n/g, "<br />")));
running = data.running;
if (!running) then (clearInterval(interval);
$("#task_progress").progressbar( "destroy" );
$.post("/tasks/#{task.id}/finalize.js",(data) ->(eval(data);));
alert ("task completeted");
return true;))))
#######################################################################à

task_scheduled = (task) -> ($("span.ui-dialog-title").html("#{task.exec}");
$("#task_status").html("task scheduled");)

#########################################################################
new_tasks_dialog = (task) -> ($("#task_status").html("");
task_dialog= $("#task_dialog").dialog({height:200,
maxHeight:800,
modal:true});
if (task.finalized != null) then task_start(task) else task_scheduled(task))

############################################################################################
$(document).ready -> $(".init_task").on("ajax:success",(e, data, status, xhr) ->
   	new_tasks_dialog(data)).on("ajax:error",(e, xhr, status, error) -> alert "error")
#########################################################################