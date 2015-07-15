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
//= require_tree.

$(document).ready(function() {
  var team_picks
  if ($('.is_current_user').length == 0 && sessionStorage.team_picks == undefined) {
    sessionStorage.team_picks = JSON.stringify(["empty"]);
  } else if ($('.is_current_user').length > 0 && JSON.parse(sessionStorage.team_picks)[0] === "empty") {
    getTeamPicks();
  }
  showSelectedTeams();
  removeTeam();
  showAllTeams();
  signOut();
  teamLoader();

  if ($('.stock_ticker').length) {stockTicker(5)};

  $('thead tr th').hover(function() {
    $(this).css('cursor','pointer');
  });

  function signOut() {
    $(document).on('click', '.sign_out', function() {
      team_picks = JSON.parse(sessionStorage.team_picks);
      if (team_picks[0] === "empty") team_picks.splice(0,1);
      $.ajax({
        type: "POST",
        url: "dashboard/pick_teams",
        data: {"last_session": team_picks},
        error: function(error){
          console.log(error);
        },
        success: function() {
          console.log("session sent to user controller");
          team_picks = ["empty"];
          sessionStorage.team_picks = JSON.stringify(team_picks);
        }
      });
    });
  }

  function getTeamPicks() {
    alert ("in getTeamPicks")
    $.ajax({
      type: "GET",
      url: "/dashboard/reload_pick_teams",
      dataType: "json",
      error: function(error){
        console.log(error);
      },
      success: function(team_picks_db) {
        if (team_picks_db == [] || team_picks_db == "" || team_picks_db == null) {
          alert(JSON.parse(sessionStorage.team_picks))
          picks = JSON.parse(sessionStorage.team_picks);
          picks.splice(0,1);
          team_picks = [].concat(picks);
          sessionStorage.team_picks = JSON.stringify(team_picks)
        } else {
          picks = JSON.parse(sessionStorage.team_picks);
          picks.splice(0,1);
          team_picks = team_picks_db.concat(picks);
          sessionStorage.team_picks = JSON.stringify(team_picks);
          showSelectedTeams();
        }
      }
    });
  }

  function showSelectedTeams() {
    team_picks = JSON.parse(sessionStorage.team_picks);
    $('.team_data').each(function(row) {
      var that = this
      team_picks.forEach(function(team){
        if ($(that).text() === team) {
          $(that).closest('.dashboard_tr').css('display', 'table-row');
          $(that).css('cursor','pointer');
        }
      });
    });
  }

  function removeTeam() {
    var timeoutId;
    $('tbody .dashboard_tr').mousedown(function() {
      team_picks = JSON.parse(sessionStorage.team_picks);
      var that = $(this).find('.team_data');
      function hideTeam() {
        var new_team_picks = team_picks.filter(function(elem){
          return elem !== (that).text();
        });
        if (team_picks != new_team_picks) {
          team_picks = new_team_picks;
          sessionStorage.team_picks = JSON.stringify(team_picks);
          $(that).closest('.dashboard_tr').css('display', 'none');
        }
      }
      timeoutId = setTimeout(hideTeam, 2000);
    }).bind('mouseup mouseleave', function() {
      clearTimeout(timeoutId);
    });
  }

  function stockTicker(speed) {
    var groupStart = 63
    var groupEnd = groupStart - 12
    var poistionAdjust = 225;
    var newPosition
    for (var i = 0; i <= 63; i++) {
      $('.stocks_droppping').eq(i).css({
        display: 'none',
        color: 'red',
        left: '-500px'
      });
    }
    id = setInterval(function(){
      for (var i = groupStart; i > groupEnd ; i--) {
        $('.stocks_droppping').eq(i).css({
          display: 'inline-block',
          color: 'red'
        });
        newPosition = parseInt($('.stocks_droppping').eq(groupStart).css('left').slice(0,-2))+ 1;
        if (newPosition < 2750) {
          $('.stocks_droppping').eq(i).css({
            left: newPosition,
          });
        } else {
          $('.stocks_droppping').eq(i).css({
            left: newPosition - poistionAdjust,
          });
          $('.stocks_droppping').eq(groupStart).css({
            display: 'none',
            color: 'black'
          });
          groupStart -= 1;
          groupEnd -= 1;
          if (groupEnd == -2) {
            groupStart = 63;
            groupEnd = groupStart - 6;
            clearInterval(id);
            setTimeout(function() {
              for (var i = 0; i < 63; i++) {
                $('.stocks_droppping').eq(i).css({
                  display: 'none',
                  color: 'black',
                  left: '-500px'
                });
              }
              stockTicker(10);
            }, 3000);
          }
        }
      }
    },speed);
  };

  function showAllTeams() {
    var showAll
    $(document).on('click', '.see_all_button', function() {
      showAll = showAll ? false : true
      $('.team_data').each(function(row) {
        var that = this
        if (showAll) {
          $('.see_all_button').css('background-color', 'yellow');
          $(that).closest('.dashboard_tr').css('display', 'table-row');
        }
        if (!showAll) {
          $('.see_all_button').css('background-color', 'white');
          $(that).closest('.dashboard_tr').css('display', 'none');
        }
      });
    });
  }

  $(document).on('click', '.dashboard', function() {
    setTimeout(function(){location.reload();}, 2000);
  });

  $.fn.slideFadeToggle = function() {
    return this.animate({opacity: 'toggle', height: 'toggle'}, 'slow');
  };

  function teamLoader() {
    var teamLoaderIsOpen
    $(document).click(function(event) {
      var isInTeamLoader = $(event.target).hasClass('team_loader');
      var isInChildOfLoader = $(event.target).parent().hasClass('team_loader');
      var isInGrandChildOfLoader = $(event.target).parent().parent().hasClass('team_loader');
      var isInTh = $(event.target).hasClass('team_loader_onclick')
      if (isInTeamLoader || isInChildOfLoader || isInGrandChildOfLoader) {
      } else if (isInTh) {
        console.log("open and close")
        teamLoaderIsOpen = teamLoaderIsOpen ? false : true;
        $('.team_loader').slideFadeToggle();
      } else if (teamLoaderIsOpen) {
        $('.team_loader').slideFadeToggle();
        teamLoaderIsOpen = false;
      }
    });
    $(document).on('click', '.team_loader span.add_team', function() {
      team_picks = JSON.parse(sessionStorage.team_picks);
      $('.team_data').each(function(row) {
        if ($(this).text() === $('.team_loader select').val()) {
          team_picks.push($('.team_loader select').val())
          sessionStorage.team_picks = JSON.stringify(team_picks)
          $(this).closest('.dashboard_tr').css('display', 'table-row');
          $(this).css('cursor','pointer');
        }
      });
    });
  }
  // -------------------------------------------------------------
  var bidLoaderIsOpen
  $(document).click(function(event) {
    var isInBidLoader = $(event.target).hasClass('bid_loader');
    var isInChildOfLoader = $(event.target).parent().hasClass('bid_loader');
    var isInGrandChildOfLoader = $(event.target).parent().parent().hasClass('bid_loader');
    var isInTh = $(event.target).hasClass('bid_rolodex_div')
    if (isInBidLoader || isInChildOfLoader || isInGrandChildOfLoader) {
    } else if (isInTh) {
      bidLoaderIsOpen = bidLoaderIsOpen ? false : true;
      $('.bid_loader').slideFadeToggle();
    } else if (bidLoaderIsOpen) {
      $('.bid_loader').slideFadeToggle();
      bidLoaderIsOpen = false;
    }
  });

  $(document).on('click', '.bid_loader span', function(e) {
    var team_name = ($('.bid_team_select').val());
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
        console.log(team_picks);
        console.log("new bid was sent");
        $('.bid_data').each(function(i,td) {
          if ($(td).closest('tr').find('.team_data').html() === data.team.name) {
            team_picks.push(data.team.name);
            sessionStorage.team_picks = JSON.stringify(team_picks);
            $(this).parent().css('display', 'table-row');
            $(this).css('cursor','pointer');
            existing_text = $(this).parent().find('.bid_data').text();
            if (existing_text === "") {
              $(this).parent().find('.bid_data').text(Number(data.bid.points).toFixed(2));
            } else {
              $(this).parent().find('.bid_data').text(existing_text +', '+ Number(data.bid.points).toFixed(2));
            }
            team_picks = [];
            sessionStorage.team_picks = JSON.stringify(team_picks);
          }
        });
      }
    });
    e.preventDefault();
  });
  // -------------------------------------------------------------
  var askLoaderIsOpen
  $(document).click(function(event) {
    var isInAskLoader = $(event.target).hasClass('ask_loader');
    var isInChildOfLoader = $(event.target).parent().hasClass('ask_loader');
    var isInGrandChildOfLoader = $(event.target).parent().parent().hasClass('ask_loader');
    var isInTh = $(event.target).hasClass('ask_rolodex_div')
    if (isInAskLoader || isInChildOfLoader || isInGrandChildOfLoader) {
    } else if (isInTh) {
      askLoaderIsOpen = askLoaderIsOpen ? false : true
      $('.ask_loader').slideFadeToggle();
      $('.team_name').text($(event.target).text());
      $('.ask_share_field').val($(event.target).data('ask-shares'));
      $('.ask_field').val($(event.target).data('ask-points'));
      var id = $(event.target).data('ask-id');
      $('.ask_loader').attr("data-id", id);
    } else if (askLoaderIsOpen) {
      $('.ask_loader').slideFadeToggle();
      askLoaderIsOpen = false;
    }
  });

  $(document).on("click",".ask_loader span", function(e) {
    var askId = $('.ask_loader').data('id');
    var askPointsShare = $('.ask_field').val();
    var shares = $('.ask_share_field').val();
    console.log("in loader")
    $.ajax({
      type: "POST",
      url: "ask/update_js",
      data: {ask: {"team_id": askId, "shares": shares, "points": askPointsShare}},
      error: function(error){
        console.log(error);
      },
      success: function(data) {
        sessionStorage.team_picks == undefined ? team_picks = [] : team_picks = JSON.parse(sessionStorage.team_picks);
        $('.ask_data').each(function(i,td) {
        if ($(td).closest('tr').find('.team_data').html() === data.team.name) {
          console.log(team_picks);
            team_picks.push(data.team.name);
            sessionStorage.team_picks = JSON.stringify(team_picks);
            $(this).parent().css('display', 'table-row');
            $(this).css('cursor','pointer');
            existing_text = $(this).parent().find('.ask_data').text();
            if (existing_text === "") {
              $(this).parent().find('.ask_data').text(Number(data.ask.points).toFixed(2));
            } else {
              $(this).parent().find('.ask_data').text(existing_text +' '+ Number(data.ask.points).toFixed(2));
            }
            team_picks = [];
            sessionStorage.team_picks = JSON.stringify(team_picks);
          }
        });
      }
    });
    e.preventDefault();
  });
  // -------------------------------------------------------------
  function createBidRolodex() {
    if ($('.bid_rolodex_div').length < 5) {
      var addEmptyBids = 5 - ($('.bid_rolodex_div').length);
       for (var i = 0; i < addEmptyBids; i++) {
         $('<div class="bid_rolodex_div">------</div>').appendTo($('.bid_rolodex'));
       }
    }

    if ($('.bid_rolodex_div').length > 5) {
      var removeBids = ($('.bid_rolodex_div').length) - 5;
      for (var i = 5; i < removeBids+5; i++) {
        $('.bid_rolodex_div').eq(i).css('display', 'none');
      }
    }

    $('.bid_rolodex_div').eq(0).css({'font-size': '50%', 'bottom': '27.5%'});
    $('.bid_rolodex_div').eq(1).css({'font-size': '100%', 'bottom': '23.5%'});
    $('.bid_rolodex_div').eq(2).css({'font-size': '150%', 'bottom': '18%'});
    $('.bid_rolodex_div').eq(3).css({'font-size': '100%', 'bottom': '14%'});
    $('.bid_rolodex_div').eq(4).css({'font-size': '50%', 'bottom': '12%'});

    $('.outter_bid_rolodex button').mousedown(function() {
      function scroll() {
        $('.bid_rolodex_div').eq(0).css('display', 'none');
        $('.bid_rolodex_div').eq(0).appendTo($('.bid_rolodex'));
        $('.bid_rolodex_div').eq(0).animate( {'font-size': '50%', 'bottom': '27.5%'}, 250);
        $('.bid_rolodex_div').eq(1).animate( {'font-size': '100%', 'bottom': '23.5%'}, 250);
        $('.bid_rolodex_div').eq(2).animate( {'font-size': '150%', 'bottom': '18%'}, 250);
        $('.bid_rolodex_div').eq(3).animate( {'font-size': '100%', 'bottom': '14%'}, 250);
        $('.bid_rolodex_div').eq(4).css('display', 'block');
        $('.bid_rolodex_div').eq(4).animate( {'font-size': '50%',  'bottom': '12%'}, 250);
      }
      scroll();
    });
  }
  createBidRolodex();

  function createAskRolodex() {
    if ($('.ask_rolodex_div').length < 5) {
      var addEmptyAsks = 5 - ($('.ask_rolodex_div').length);
       for (var i = 0; i < addEmptyAsks; i++) {
         $('<div class="ask_rolodex_div">------</div>').appendTo($('.ask_rolodex'));
       }
    }
    if ($('.ask_rolodex_div').length > 5) {
      var removeAsks = ($('.ask_rolodex_div').length) - 5;
      for (var i = 5; i <= removeAsks+5; i++) {
        $('.ask_rolodex_div').eq(i).css('display', 'none');
      }
    }

    $('.ask_rolodex_div').eq(0).css({'font-size': '50%', 'bottom': '27.5%'});
    $('.ask_rolodex_div').eq(1).css({'font-size': '100%', 'bottom': '23.5%'});
    $('.ask_rolodex_div').eq(2).css({'font-size': '150%', 'bottom': '18%'});
    $('.ask_rolodex_div').eq(3).css({'font-size': '100%', 'bottom': '14%'});
    $('.ask_rolodex_div').eq(4).css({'font-size': '50%', 'bottom': '12%'});

    $('.outter_ask_rolodex button').mousedown(function() {
      function scroll() {
        $('.ask_rolodex_div').eq(0).css('display', 'none');
        $('.ask_rolodex_div').eq(0).appendTo($('.ask_rolodex'));
        $('.ask_rolodex_div').eq(0).animate( {'font-size': '50%', 'bottom': '27.5%'}, 250);
        $('.ask_rolodex_div').eq(1).animate( {'font-size': '100%', 'bottom': '23.5%'}, 250);
        $('.ask_rolodex_div').eq(2).animate( {'font-size': '150%', 'bottom': '18%'}, 250);
        $('.ask_rolodex_div').eq(3).animate( {'font-size': '100%', 'bottom': '14%'}, 250);
        $('.ask_rolodex_div').eq(4).css('display', 'block');
        $('.ask_rolodex_div').eq(4).animate( {'font-size': '50%', 'bottom': '12%'}, 250);
      }
      scroll();
    });
  }
  createAskRolodex();

  function createTradeRolodex() {
    if ($('.trade_rolodex_div').length < 5 ) {
      var addEmptyTrades = 5 - ($('.trade_rolodex_div').length);
       for (var i = 0; i < addEmptyTrades; i++) {
         $('<div class="trade_rolodex_div">------</div>').appendTo($('.trade_rolodex'));
       }
    }
    if ($('.trade_rolodex_div').length > 5) {
      var removeTrades = ($('.trade_rolodex_div').length) - 5;
      for (var i = 5; i < removeTrades+5; i++) {
        $('.trade_rolodex_div').eq(i).css('display', 'none');
      }
    }
    $('.trade_rolodex_div').eq(0).css({'font-size': '50%'});
    $('.trade_rolodex_div').eq(1).css({'font-size': '100%'});
    $('.trade_rolodex_div').eq(2).css({'font-size': '150%'});
    $('.trade_rolodex_div').eq(3).css({'font-size': '100%'});
    $('.trade_rolodex_div').eq(4).css({'font-size': '50%'});

    $('.outter_trade_rolodex button').mousedown(function() {
      function scroll() {
        $('.trade_rolodex_div').eq(0).css('display', 'none');
        $('.trade_rolodex_div').eq(0).appendTo($('.trade_rolodex'));
        $('.trade_rolodex_div').eq(0).animate( {'font-size': '50%'}, 250);
        $('.trade_rolodex_div').eq(1).animate( {'font-size': '100%'}, 250);
        $('.trade_rolodex_div').eq(2).animate( {'font-size': '150%'}, 250);
        $('.trade_rolodex_div').eq(3).animate( {'font-size': '100%'}, 250);
        $('.trade_rolodex_div').eq(4).animate( {'font-size': '50%'}, 250);
        $('.trade_rolodex_div').eq(4).css('display', 'block');
      }
      scroll();
    });
  }
  createTradeRolodex();
});
