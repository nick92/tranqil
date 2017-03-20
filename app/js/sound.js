$(document).ready(function(){
  $('.image').hover(function() {
      $( this ).animate({
        opacity: 0.9
      });
    }, function() {
      $( this ).animate({
        opacity: 0.6
      });
    }
  );
});

function play_forest(e){
   var forest = $('#aforest').get(0);
   var river = $('#ariver').get(0);
   var night = $('#anight').get(0);

   if(!river.paused)
    river.pause();
   if(!night.paused)
    night.pause();

   if (forest.paused)
     forest.play();
   else
     forest.pause();

    $('#tranqil').fadeTo('slow', 0.2, function()
    {
      $(this).css('background-image', 'url("/home/nick/Dropbox/enso/tranqil/Autumn-Forest-Leaves.jpg")');
      $('#for').animate({
        opacity: 1
      });
    }).delay(1000).fadeTo('slow', 1);

}

function play_river(){
  var forest = $('#aforest').get(0);
  var river = $('#ariver').get(0);
  var night = $('#anight').get(0);

  if(!forest.paused)
   forest.pause();
  if(!night.paused)
   night.pause();

  if (river.paused)
    river.play();
  else
    river.pause();

    $('#tranqil').fadeTo('slow', 0.2, function()
    {
      $(this).css('background-image', 'url("/home/nick/Dropbox/enso/tranqil/little-pigeon-river.jpg")');
      $('#riv').animate({
        opacity: 1
      });
    }).delay(1000).fadeTo('slow', 1);

}
function play_night(){
  var forest = $('#aforest').get(0);
  var river = $('#ariver').get(0);
  var night = $('#anight').get(0);

  if(!forest.paused)
   forest.pause();
  if(!river.paused)
   river.pause();

  if (night.paused)
    night.play();
  else
    night.pause();

    $('#tranqil').fadeTo('slow', 0.2, function()
    {
        $(this).css('background-image', 'url("/home/nick/Dropbox/enso/tranqil/night-forest-sky-star-milky-way.jpg")');
        $('#nigh').animate({
          opacity: 1
        });
    }).delay(1000).fadeTo('slow', 1);
}
