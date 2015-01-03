window.onresize = function() {  
  dim = new Array();
  dim[0] = window.innerWidth;
  dim[1] = window.innerHeight;
  Shiny.onInputChange('dim', dim);
} 