###
  Requires all datatype classes from the ,/dataTypes dir
###
errors = require('include-all')({
  dirname     :  __dirname + '/dataTypes',
  filter      :  /(.+)\.js$/,
  excludeDirs :  /^\.(git|svn)$/
});

