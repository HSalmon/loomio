# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$ ->
  if $("body.discussions").length > 0
    $('a[disabled]').click ->
      event.preventDefault()
  
    $(document.body).keypress ->
      keyCode = event.which || event.keyCode
      keyChar = String.fromCharCode(keyCode)
  
      if check_page_focus_non_textarea()
        switch keyChar
          when "i" then show_group_homepage()
          when "j" then show_previous_discussion()
          when "k" then show_next_discussion()
          
check_page_focus_non_textarea = ->
  non_textarea = true
  if $('input').is(":focus")
    non_textarea = false
  if $('textarea').is(":focus")
    non_textarea = false
  return non_textarea

show_previous_discussion = ->
  $('#previous_button')[0].click()

show_next_discussion = ->
  $('#next_button')[0].click()

show_group_homepage = ->
  $('.group-title h2 a')[0].click()