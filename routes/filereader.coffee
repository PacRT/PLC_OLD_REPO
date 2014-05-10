fs = require "fs"

exports.getdata = (fileloc, fn, encoding) ->
  encoding = 'utf8' if encoding == 'undefined'
  fs.readFile fileloc, encoding, (err, data) ->
    unless err
      fn(data)

FileData = (fileloc, enc) ->
  @fileloc = fileloc
  enc = 'utf8' if enc == 'undefined'
  @enc = enc

FileData.prototype.getData = (fn) ->
  fs.readFile @fileloc, @enc, (err, data) ->
    fn(err, data)

module.exports.FileData = FileData






