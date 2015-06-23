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

  // function stockTicker(speed){
  //   var groupStart = 63
  //   var groupEnd = groupStart - 12
  //   var poistionAdjust = 0
  //   var poistionAdjust = 225;
  //   var id = setInterval(function(){
  //
  //     for (var i = groupStart; i > groupEnd ; i--) {
  //       $('.stocks_droppping').eq(i).css({
  //         display: 'inline-block',
  //         color: 'red'
  //       });
  //
  //       var newPosition = parseInt($('.stocks_droppping').eq(groupStart).css('left').slice(0,-2))+ 2;
  //
  //       if (newPosition < 2750) {
  //         $('.stocks_droppping').eq(i).css({
  //           left: newPosition,
  //         })
  //       } else {
  //         $('.stocks_droppping').eq(i).css({
  //           left: newPosition - poistionAdjust,
  //         })
  //         $('.stocks_droppping').eq(groupStart).css({
  //             display: 'none',
  //             color: 'black'
  //         });
  //         groupStart -= 1;
  //         groupEnd -= 1;
  //         if (groupEnd == -2) {
  //           groupStart = 63;
  //           groupEnd = groupStart - 6;
  //           clearInterval(id);
  //           setTimeout(function() {
  //             for (var i = 0; i < 63; i++) {
  //               $('.stocks_droppping').eq(i).css({
  //                   display: 'none',
  //                   color: 'black',
  //                   left: '-1000px'
  //               });
  //             }
  //             stockTicker(10);
  //           }, 3000);
  //         }
  //       }
  //     }
  //   },speed);
  // };
 // stockTicker(5);

  var show_all
  $(document).on("click",".see_all_button", function() {
    show_all = show_all ? false : true
    $(".team_data").each(function(row) {
      var that = this
      team_picks.forEach(function(team){
        if (show_all) {
          $(".see_all_button").css("background-color", "yellow");
          $(that).closest('.dashboard_tr').css('display', 'table-row');
        }
        if (!show_all) {
          $(".see_all_button").css("background-color", "white");
          $(that).closest('.dashboard_tr').css('display', 'none');
        }
      });
    });
  });

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
          sessionStorage.team_picks = JSON.stringify(team_picks);
          location.reload();
        }
    });
  };

  $(document).on("click",".dashboard", function() {
    setTimeout(function(){location.reload();},2000);
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

  $.fn.slideFadeToggle = function() {
      return this.animate({ opacity: 'toggle', height: 'toggle' }, 'slow');
    };

  var teamLoaderIsOpen
  $(document).click(function(event) {
    var isInTeamLoader = $(event.target).hasClass("team_loader");
    var isInChildOfLoader = $(event.target).parent().hasClass("team_loader");
    var isInGrandChildOfLoader = $(event.target).parent().parent().hasClass("team_loader");
    var isInTh = $(event.target).hasClass("team_loader_onclick")
    if (isInTeamLoader || isInChildOfLoader || isInGrandChildOfLoader) {
      console.log("Do Nothing")
    } else if (isInTh) {
      console.log ("Open or Close")
      teamLoaderIsOpen = teamLoaderIsOpen ? false : true
      $('.team_loader').slideFadeToggle();
    } else {
      console.log("Close Only")
      if (teamLoaderIsOpen) {
        $('.team_loader').slideFadeToggle();
        teamLoaderIsOpen = false;
      }
    }
  });

  $(document).on("click",".team_loader span", function() {
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
  // -------------------------------------------------------------
  var bidLoaderIsOpen
  $(document).click(function(event) {
    var isInBidLoader = $(event.target).hasClass("bid_loader");
    var isInChildOfLoader = $(event.target).parent().hasClass("bid_loader");
    var isInGrandChildOfLoader = $(event.target).parent().parent().hasClass("bid_loader");
    var isInTh = $(event.target).hasClass("bid_loader_onclick")
    if (isInBidLoader || isInChildOfLoader || isInGrandChildOfLoader) {
      console.log("Do Nothing")
    } else if (isInTh) {
      console.log ("Open or Close")
      bidLoaderIsOpen = bidLoaderIsOpen ? false : true
      $('.bid_loader').slideFadeToggle();
    } else {
      console.log("Close Only")
      if (bidLoaderIsOpen) {
        $('.bid_loader').slideFadeToggle();
        bidLoaderIsOpen = false;
      }
    }
  });

  $(document).on("click",".bid_loader span", function(e) {
    var team_name = ($(".bid_team_select").val());
    var shares = ($('.bid_share_field').val());
    var bid_points_share = ($('.bid_field').val());
      $.ajax({
          type: "POST",
          url: "user_shares/create_bid",
          data: {"team_name": team_name, "bid_shares": shares, "bid_points_share": bid_points_share},
          error: function(error){
            console.log(error);
          },
          success: function(data) {
            console.log("new bid was sent");
            $('.bid_data').each(function(i,td) {
              if ($(td).closest("tr").find(".team_data").html() === data.team.name) {
                team_picks.push(data.team.name);
                sessionStorage.team_picks = JSON.stringify(team_picks);
                $(this).parent().css('display', 'table-row');
                $(this).css('cursor','pointer');
                existing_text = $(this).parent().find('.bid_data').text();
                if (existing_text === "") {
                  $(this).parent().find('.bid_data').text(Number(data.bid.points).toFixed(2));
                } else {
                  $(this).parent().find('.bid_data').text(existing_text + ', '+ Number(data.bid.points).toFixed(2));
                }
              }
            });
          }
        });
      e.preventDefault();
      session_team_picks = [];
      sessionStorage.team_picks = [];
  });
  // -------------------------------------------------------------
  var askLoaderIsOpen
  $(document).click(function(event) {
    var isInAskLoader = $(event.target).hasClass("ask_loader");
    var isInChildOfLoader = $(event.target).parent().hasClass("ask_loader");
    var isInGrandChildOfLoader = $(event.target).parent().parent().hasClass("ask_loader");
    var isInTh = $(event.target).hasClass("ask_loader_onclick")
    if (isInAskLoader || isInChildOfLoader || isInGrandChildOfLoader) {
      console.log("Do Nothing")
    } else if (isInTh) {
      console.log ("Open or Close")
      askLoaderIsOpen = askLoaderIsOpen ? false : true
      $('.ask_loader').slideFadeToggle();
    } else {
      console.log("Close Only")
      if (askLoaderIsOpen) {
        $('.ask_loader').slideFadeToggle();
        askLoaderIsOpen = false;
      }
    }
  });

  $(document).on("click",".ask_loader span", function(e) {
    var team_name = ($(".ask_team_select").val());
    var ask_points_share = ($('.ask_field').val());
    var shares = ($('.ask_share_field').val());
      $.ajax({
          type: "POST",
          url: "user_shares/create_ask",
          data: {"team_name": team_name, "ask_shares": shares, "ask_points_share": ask_points_share},
          error: function(error){
            console.log(error);
          },
          success: function(data) {
            console.log("new ask was sent");

            $('.ask_data').each(function(i,td) {
              if ($(td).closest("tr").find(".team_data").html() === data.team.name) {
                team_picks.push(data.team.name);
                sessionStorage.team_picks = JSON.stringify(team_picks);
                $(this).parent().css('display', 'table-row');
                $(this).css('cursor','pointer');
                existing_text = $(this).parent().find('.ask_data').text();
                if (existing_text === "") {
                  $(this).parent().find('.ask_data').text(Number(data.ask.points).toFixed(2));
                } else {
                  $(this).parent().find('.ask_data').text(existing_text + ' '+ Number(data.ask.points).toFixed(2));
                }
              }
            });
          }
        });
      e.preventDefault();
      session_team_picks = [];
      sessionStorage.team_picks = [];
  });
  // -------------------------------------------------------------
  var timeoutId = 0;
  $('tbody .dashboard_tr').mousedown(function() {
    var that = $(this).find('.team_data');
    function hideTeam(){
      var new_team_picks = team_picks.filter(function(elem){
        return elem !== (that).text();
      });
      team_picks = new_team_picks
      sessionStorage.team_picks = JSON.stringify(team_picks);
      $(that).closest('.dashboard_tr').css('display', 'none');
    }
      timeoutId = setTimeout(hideTeam, 2000);
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
      });
    e.preventDefault();
    session_team_picks = [];
    sessionStorage.team_picks = [];
  });
});
