# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/



changeTaskSettings = (selector,setting) -> (input = $(selector).siblings("form").children("fieldset").children("input[name='task[settings][#{setting}]']");
selected = $(selector).val();
input.val(selected);
)


#checkStatus = (data,queque,timer) -> alert "success" if !data.running

#finalize= (id,queque) -> $.post("#{id}/finalize.json",startTask(queque.pop(),queque) if queque.length >0)

#startTask = (task,queque)->  $.post "#{task.id}/start.json",{},(data) -> timer = setInterval -> $.getJSON "#{task.id}/status",(data) -> checkStatus(data,queque,timer) ,5000

#$(document).ready -> $("#start_schedule").click -> ( $.getJSON("schedule",(data) -> startTask(data.pop(),data) if data.length > 0))