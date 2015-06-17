// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//= require jquery
//= require bootstrap-sprockets
//= require jquery
//= require jquery_ujs
//= require turbolinks
//= require_tree .


$(document).ready(function() {

  var team_picks = $.parseJSON(sessionStorage.team_picks || '[]');
  if (team_picks == [] || team_picks == "") {
    $.ajax({
        type: "GET",
        url: "/dashboard/reload_pick_teams",
        dataType: "json",
        error: function(error){
          console.log(error);
        },
        success: function(team_picks) {
          console.log(JSON.stringify(team_picks));
          sessionStorage.team_picks = JSON.stringify(team_picks);
          location.reload();
        }
    });
  };

  $(document).on("click",".dashboard", function() {
    setTimeout(function(){location.reload();},1000);
  });

  $(".team_data").each(function(row) {
    var that = this
    team_picks.forEach(function(team){
      if ($(that).text() === team) {
        $(that).closest('.dashboard_tr').css('display', 'table-row');
        $(that).css('cursor','pointer');
      }
    });
  });

  $("thead tr th").hover(function() {
    $(this).css('cursor','pointer');
  });

	$(document).on("click","thead tr th", function() {
    if($(this).hasClass('selected')) {
      deselect($(this));
    } else {
      $(this).addClass('selected');
      $('.team_loader').slideFadeToggle();
    }
  });

  function deselect(e) {
    $('.team_loader').slideFadeToggle(function() {
      e.removeClass('selected');
    });
  }

  $.fn.slideFadeToggle = function(easing, callback) {
      return this.animate({ opacity: 'toggle', height: 'toggle' }, 'slow', easing, callback);
    };

  $(document).on("click",".team_loader span", function(e) {
    if (team_picks == undefined || null) team_picks = [];
    $(".team_data").each(function(row) {
      if ($(this).text() === $(".team_loader select").val()) {
        team_picks.push($(".team_loader select").val())
        sessionStorage.team_picks = JSON.stringify(team_picks)
        $(this).closest('.dashboard_tr').css('display', 'table-row');
        $(this).css('cursor','pointer');
      }
    });
  });

  var timeoutId = 0;
  $('tbody .dashboard_tr').mousedown(function() {
    var that = $(this).find('.team_data');
    function myFunction(){
      var new_team_picks = team_picks.filter(function(elem){
        elem !== (that).text()
      });
      sessionStorage.team_picks = JSON.stringify(new_team_picks);
      $(that).closest('.dashboard_tr').css('display', 'none');
    }
    timeoutId = setTimeout(myFunction, 2000);
  }).bind('mouseup mouseleave', function() {
    clearTimeout(timeoutId);
  });

  $(document).on("click",".sign_out", function(e) {
    $.ajax({
        type: "POST",
        url: "dashboard/pick_teams",
        data: {"last_session": sessionStorage.team_picks},
        error: function(error){
        },
        success: function() {
          console.log("session sent to user controller");
        }
      })
    e.preventDefault();
    session_team_picks = [];
    sessionStorage.team_picks = [];
  });

  


});
