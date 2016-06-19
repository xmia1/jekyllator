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
//
//= require jquery
//= require jquery_ujs
//= require turbolinks
//= require_tree .

var lastExecuted = null;
var last = +new Date();
var threshold = 3000;
function debounce(func, wait, immediate){
  var timeout;
  var now;
  return function(){
      now = +new Date();
      if (now < last+threshold){
        console.log("Within threshold");
        var later = function(){
          last = now;
          var time = new Date()
          timeout = null;
          func.apply(undefined);
        }
        //last = now;
        clearTimeout(timeout);
        timeout = setTimeout(later, wait);

      } else {
        console.log("Over threshold");
        clearTimeout(timeout);
        last = now;
        func.apply(undefined)
      }

      if(immediate){
        func.apply(undefined)
      }

    }

}

function parse() {
  console.log("Parse invoked.")
  $.post('/parse', { content: $("#content").val()},
  function(returnedData){
      $("#content_preview").html(returnedData.content.replace(/\r?\n/g,'<br/>'))
       //console.log(returnedData);
     });
}

$(document).on("page:change",function(){

  // filling title on load
  $("#title_preview").html($("#title").val())
  // fillling body on load
  $.post('/parse', { content: $("#content").val()},
  function(returnedData){
      $("#content_preview").html(returnedData.content.replace(/\r?\n/g,'<br/>'))
       //console.log(returnedData);
     });

  $("#title").keyup(function(){
    //console.log($("#title").val())
    $("#title_preview").html($("#title").val())
  })

  $("#content").keyup(debounce(parse, 250, false))


  /*$("#content").keyup(function(){
    console.log($("#title").val())
    $.post('/parse', { content: $("#content").val()},
    function(returnedData){
        $("#content_preview").html(returnedData.content.replace(/\r?\n/g,'<br/>'))
         console.log(returnedData);
       });

  });*/
});
