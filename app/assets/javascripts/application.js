// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, or any plugin's
// vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file. JavaScript code in this file should be added after the last require_* statement.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery3
//= require turbolinks
//= require popper
//= require bootstrap-sprockets
//= require trix
//= require flatpickr
//= require bootstrap-msg-0.4.0
//= require_tree .

$(function () {
  var actionPopover = $('#actions-button').popover('show');

  $('#actions-button').click(function() {
    actionPopover.popover('hide')
  })

  setTimeout(function() {
    actionPopover.popover('hide')
  }, 3000)

})