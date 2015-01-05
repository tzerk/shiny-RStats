window.onresize = function() {  
  dim = new Array();
  
  /*
  dim[0] = window.innerWidth;
  dim[1] = window.innerHeight;
  */
  
  dim[0] = document.getElementById("plot_wrapper").offsetWidth;
  dim[1] = document.getElementById("plot_wrapper").offsetHeight;
  Shiny.onInputChange('dim', dim);
}
