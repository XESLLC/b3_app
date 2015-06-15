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








$(document).ready(function() {

  console.log(document.cookie);

  var session_team_picks;
  var team_picks = $.parseJSON(sessionStorage.team_picks || '[]');
  $(".team_data").each(function(row) {
    var that = this
    team_picks.forEach(function(team){

      if ($(that).text() === team) {
        $(that).closest('tr').css('display', 'table-row');
        $(that).css('cursor','pointer');
      }
    });
  });

  $("thead tr th").hover(function() {
    $(this).css('cursor','pointer');
  });

	$(document).on("click","thead tr th", function(e) {
    if($(this).hasClass('selected')) {
      deselect($(this));
    } else {
      $(this).addClass('selected');
      $('.team_loader').slideFadeToggle();
    }
    return false;
  });

  $(document).on("click",".sign_out", function(e) {
    session_team_picks = [];
    sessionStorage.team_picks = [];
  });


  function deselect(e) {
    $('.team_loader').slideFadeToggle(function() {
      e.removeClass('selected');
    });
  }

  $.fn.slideFadeToggle = function(easing, callback) {
      return this.animate({ opacity: 'toggle', height: 'toggle' }, 'slow', easing, callback);
    };

    $(document).on("click",".team_loader div", function(e) {
      console.log("this is cookie", document.cookie.user_id);
      if (session_team_picks == undefined || null) session_team_picks = [];
      $(".team_data").each(function(row) {
        if ($(this).text() === $(".team_loader select").val()) {
          session_team_picks.push($(".team_loader select").val())
          sessionStorage.team_picks = JSON.stringify(session_team_picks)
          $(this).closest('tr').css('display', 'table-row');
          $(this).css('cursor','pointer');
        }
      });

    });
    var timeoutId = 0;
    $('tbody tr').mousedown(function() {
      function myFunction(){
        console.log("Mouse Hold");
        console.log($(this));
      }
      timeoutId = setTimeout(myFunction, 1000);
    }).bind('mouseup mouseleave', function() {
      clearTimeout(timeoutId);
    });



	// 	$.ajax({
  //     type: "GET",
  //     url: "/list_items",
  //     data: {"list_item": { "content": content}},
  //     success: function(data) {
	// 			console.log(data);
	// 			$('tbody').append("<tr><td><input type='text' value= "+ data.content +" class = 'input'data-id="+ data.id +"/></td> <td class ='complete'>" + data.complete + "</td> <td> <button class='toggle-complete' data-id="+ data.id + ">Toggle Completion</button> </td> <td> <button class='delete' data-id="+ data.id + "> Delete </button> </td></tr>");
  //     }
  //   })
	// 	e.preventDefault();
	// });
  //
	// $(document).on("click", ".toggle-complete", function(e) {
	// 	var that = this
	// 	var complete = $.parseJSON($(this).parent().parent().children('.complete').text()) ? false : true;
	// 	console.log(complete);
	// 	console.log($(this).data("id"));
  //
	// 	$.ajax({
  //     type: "PATCH",
  //     url: "/list_items/"+ $(this).data("id"),
  //     data: {"list_item": { "complete": complete}},
  //     success: function(data) {
	// 			console.log(that);
	// 			$(that).parent().parent().children('.complete').text(data.complete);
	// 		}
	// 	})
	// 	e.preventDefault();
	// });
  //
	// $(document).on("click", ".delete", function(e) {
	// 	var that = this
	// 	$.ajax({
	// 		type: "DELETE",
	// 		url: "/list_items/"+ $(this).data("id"),
	// 		data: {"list_item": {}},
	// 		success: function(data) {
	// 			$(that).parent().parent().remove();
	// 			console.log(data);
	// 		}
	// 	})
	// 	e.preventDefault();
	// });
  //
	// $(document).on("focusout", ".input", function(e) {
	// 	var that = this;
	// 	var content = $(this).prop('value');
	// 	console.log(content);
	// 	console.log($(this).data("id"));
  //
	// 	$.ajax({
  //     type: "PATCH",
  //     url: "/list_items/"+ $(this).data("id"),
  //     data: {"list_item": { "content": content}},
  //     success: function(data) {
	// 			console.log(that);
	// 			$(that)['value'] = content;
	// 		}
	// 	})
	// 	e.preventDefault();
	// });

});
