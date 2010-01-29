$(function(){
  var contents = $('.contents')
      contentsBody = $('ol',contents),
      colophonLink = $('.colophon a');

  function hideContents() {
    if(!contents.data('hovering')) {
      contents.removeClass('active');
      contentsBody.hide();
    }
  }

  contents.hover(function(){
    contents.data('hovering', true);
    contents.addClass('active');
    contentsBody.show();
  }, function(){
    contents.data('hovering', false);
    setTimeout(hideContents,400);
  });

  // Disables contents link
  $('a:first', contents).click(function(){
    contents.mouseover();
    return false;
  });

  colophonLink.mouseenter(hideContents);

});
