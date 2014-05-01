
/*
 * GET home page.
 */

exports.index = function(req, res){
  res.render('index', { title: 'Express' });
};

exports.ngupload = function(req, res) {
    res.render('upload-ng', { user: req.user });
}

