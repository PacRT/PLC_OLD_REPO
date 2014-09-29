// Generated by CoffeeScript 1.7.1
(function() {
  var FileData, FormData, client, dbentry, filedata, fileupload, fullzscan, reader, redis, request, stream, util, weedMaster, zscan;

  request = require("request");

  stream = require("stream");

  FormData = require("form-data");

  weedMaster = "http://192.168.1.2:9333";

  util = require("util");

  redis = require("redis");

  client = redis.createClient();

  reader = require("./filereader");

  FileData = reader.FileData;

  filedata = new FileData("./miscscripts/doclink.lua", "ascii");

  exports.upload = function(req, res, err) {
    if (req.method === "GET") {
      return request("" + weedMaster + "/dir/assign", function(error, response, body) {
        var weedRes;
        weedRes = JSON.parse(body);
        return res.send(weedRes);
      });
    } else if (req.method === "POST") {
      return request("" + weedMaster + "/dir/assign", function(error, response, body) {
        var uploadEndpoint, weedRes;
        if (!error) {
          weedRes = JSON.parse(body);
          uploadEndpoint = "http://" + weedRes.publicUrl + "/" + weedRes.fid;
          console.log("Upload Endpoint: " + uploadEndpoint);
          console.log("URL: " + req.url + "  and Original URL: " + req.originalUrl);
          return fileupload(req, res, uploadEndpoint, dbentry);
        } else {
          console.log("error: " + error);
          return res.send("{" + error + "}");
        }
      });
    }
  };

  dbentry = function(req) {
    return filedata.getData(function(err, data) {
      if (!err) {
        console.log("Data: " + data);
        return client["eval"](data, 2, "" + req.user.id, "" + req.user.id, "" + (new Date().getTime()), "" + req.docurl, function(error, resp) {
          if (!error) {
            return console.log("Response: " + resp);
          } else {
            return console.log("Error: " + error);
          }
        });
      } else {
        throw new Error("Problem executing the code data");
      }
    });
  };

  fileupload = function(req, res, uploadEndpoint, fn) {
    var poster;
    req.connection.setTimeout(10000);
    poster = request.post(uploadEndpoint, function(err, response, body) {
      var extension, jsonbody, jsonstring;
      if (!err) {
        console.log(err + ":" + response.statusCode + ":" + body);
        jsonbody = JSON.parse(body);
        jsonstring = JSON.stringify(jsonbody);
        console.log("jsonbody:  " + jsonstring);
        console.log("FIle name: " + jsonbody.name);
        extension = jsonbody.name.substring(jsonbody.name.lastIndexOf("."));
        console.log("Extension " + extension);
        if (jsonbody.error !== undefined) {
          console.log("Error ofcourse");
        }
        if (!jsonbody.error) {
          console.log("Ready to call a function here");
          if (fn !== 'undefined') {
            req.docurl = uploadEndpoint + extension;
            return fn(req);
          }
        }
      } else {
        console.log("Error ::: " + err);
      }
    });
    return req.pipe(poster).pipe(res);
  };

  exports.getdocuments = function(req, res, err) {
    return client.zscan("owner:" + req.user.id + ":docs", 0, function(error, resp) {
      var docs, len, num, _i, _ref;
      if (!error) {
        console.log("Resp: " + resp[1].length);
        len = resp[1].length;
        docs = [];
        for (num = _i = 0, _ref = len - 1; 0 <= _ref ? _i <= _ref : _i >= _ref; num = 0 <= _ref ? ++_i : --_i) {
          if (num % 2 === 0) {
            docs.push(resp[1][num]);
          }
        }
        return res.send(docs);
      }
    });
  };

  exports.getdocuments1 = function(req, res, err) {
    return client.zscan("owner:" + req.user.id + ":docs", 0, function(error, resp) {
      var doc, doc1, doc2, docFid, docPort, docUrl, docs, fids, len, num, _i, _ref;
      if (!error) {
        console.log("Resp: " + resp[1].length);
        len = resp[1].length;
        docs = [];
        fids = [];
        for (num = _i = 0, _ref = len - 1; 0 <= _ref ? _i <= _ref : _i >= _ref; num = 0 <= _ref ? ++_i : --_i) {
          if (num % 2 === 0) {
            doc = resp[1][num];
            doc1 = doc.substring(doc.indexOf("://") + 3);
            doc2 = doc1.substring(0, doc1.indexOf("/"));
            docUrl = doc2.substring(0, doc2.indexOf(":"));
            docPort = doc2.substring(doc2.indexOf(":") + 1);
            docFid = doc1.substring(doc1.indexOf("/") + 1);
            fids.push(docFid);
            docs.push("/documents/" + docUrl + "/" + docPort + "/" + docFid);
          }
        }
        req.session.fids = fids;
        return res.send(docs);
      }
    });
  };

  exports.getdocuments2 = function(req, res, err) {
    return fullzscan("owner:" + req.user.id + ":docs", function(result) {
      var doc, doc1, doc2, docFid, docPort, docUrl, docs, fids, len, num, _i, _ref;
      console.log("Result: " + result);
      len = result.length;
      console.log("Result Length: " + len);
      docs = [];
      fids = [];
      for (num = _i = 0, _ref = len - 1; 0 <= _ref ? _i <= _ref : _i >= _ref; num = 0 <= _ref ? ++_i : --_i) {
        if (len > 0) {
          if (num % 2 === 0) {
            doc = result[num];
            doc1 = doc.substring(doc.indexOf("://") + 3);
            doc2 = doc1.substring(0, doc1.indexOf("/"));
            docUrl = doc2.substring(0, doc2.indexOf(":"));
            docPort = doc2.substring(doc2.indexOf(":") + 1);
            docFid = doc1.substring(doc1.indexOf("/") + 1);
            fids.push(docFid);
            docs.push("/documents/" + docUrl + "/" + docPort + "/" + docFid);
          }
        }
      }
      req.session.fids = fids;
      return res.send(docs);
    });
  };

  exports.fileServiceMask = function(req, res, err) {
    var fiid, reqobj, _i, _len, _ref;
    console.log("fileServiceMask() got called");
    console.log("FIDS:::::::::" + req.session.fids);
    _ref = req.session.fids;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      fiid = _ref[_i];
      console.log("FID: " + fiid);
    }
    if (req.session.fids.indexOf(req.params.fid) !== -1) {
      console.log("fileServiceMask(): fid is present in fids");
      reqobj = request("http://" + req.params.vs + ":" + req.params.prt + "/" + req.params.fid, function(error, response, body) {
        if (!error) {
          console.log("fileServiceMask(): Error: " + error);
          return console.log("fileServiceMask(): Response: " + response);
        } else {
          return console.log("fileServiceMask(): Error: " + error);
        }
      });
      return reqobj.pipe(res);
    } else {
      return console.log("fileServiceMask(): fid is present NOT present in fids");
    }
  };

  fullzscan = function(indexname, fn) {
    var result;
    result = [];
    return zscan(indexname, 0, result, fn);
  };

  zscan = function(indexname, start, acc, fn) {
    return client.zscan(indexname, start, function(error, resp) {
      if (!error) {
        console.log("Zscan response[0]: " + resp[0]);
        console.log("Zscan response[1]: " + resp[1]);
        acc = acc.concat(resp[1]);
        console.log("Accumulator: " + acc);
        if (parseInt(resp[0]) !== 0) {
          zscan(indexname, parseInt(resp[0]), acc);
        }
        return fn(acc);
      }
    });
  };

  exports.sioupload = function(socket) {
    socket.on('send-file', function(name, buffer) {
      console.log("Name: " + name);
      return request(weedMaster + "/dir/assign", function(error, response, body) {
        var form, poster, uploadEndpoint, weedRes;
        if (!error) {
          weedRes = JSON.parse(body);
          uploadEndpoint = "http://" + weedRes.publicUrl + "/" + weedRes.fid;
          console.log("Upload Endpoint: " + uploadEndpoint);
          poster = request.post(uploadEndpoint, function(err, response, body) {
            var jsonbody;
            if (!err) {
              console.log("******" + response + "*****");
              jsonbody = JSON.parse(body);
              console.log("jsonbody: " + JSON.stringify(jsonbody));
              if (jsonbody.error !== undefined) {
                return console.log("Error ofcourse");
              }
            } else {
              return console.log("err");
            }
          });
          form = poster.form();
          return form.append("file", buffer);
        } else {
          console.log("error: " + error);
          return res.send("{" + error + "}");
        }
      });
    });
    socket.on('save-file', function(name, buffer) {
      var fs;
      fs = require('fs');

      /*
      stream = fs.createWriteStream(filename)
      stream.once 'open', (fd) ->
        stream.write buffer
        stream.end()
       */
      return fs.writeFileSync(name, buffer, "binary", function(err) {
        console.log(buffer.length);
        if (err) {
          return console.log("Error writing: " + err);
        } else {
          return request(weedMaster + "/dir/assign", function(error, response, body) {
            var form, poster, uploadEndpoint, weedRes;
            if (!error) {
              weedRes = JSON.parse(body);
              uploadEndpoint = "http://" + weedRes.publicUrl + "/" + weedRes.fid;
              console.log("Upload Endpoint: " + uploadEndpoint);
              poster = request.post(uploadEndpoint, function(err, response, body) {
                var jsonbody;
                if (!err) {
                  console.log("******" + response + "*****");
                  jsonbody = JSON.parse(body);
                  console.log("jsonbody: " + JSON.stringify(jsonbody));
                  if (jsonbody.error !== undefined) {
                    return console.log("Error ofcourse");
                  }
                }
              });
              form = poster.form();
              return form.append("file", fs.createReadStream(name));
            }
          });
        }
      });
    });
    return socket.on('test-stream', function(file, buffer) {
      var bufferStream, form;
      console.info("Size: " + file.size);
      form = new FormData();
      form.append("name", file.name);
      form.append("size", file.size);
      form.append("lastModifiedDate", file.lastModifiedDate);
      form.append("type", file.type);
      form.append("buffer", buffer);
      bufferStream = new stream.Transform();
      return request(weedMaster + "/dir/assign", function(error, response, body) {
        var uploadEndpoint, weedRes;
        if (!error) {
          weedRes = JSON.parse(body);
          uploadEndpoint = "http://" + weedRes.publicUrl + "/" + weedRes.fid;
          console.log("Upload Endpoint: " + uploadEndpoint);
          return form.submit(uploadEndpoint, function(err, res) {
            return res.resume();
          });
        }
      });
    });
  };

}).call(this);

//# sourceMappingURL=ops.map
