request = require("request")
stream = require("stream")
FormData = require("form-data")
#weedMaster = "http://50.250.218.64:9333"
weedMaster = "http://192.168.1.2:9333"

util = require "util"
redis = require("redis")
client = redis.createClient()

reader = require "./filereader"

FileData = reader.FileData

filedata = new FileData("./miscscripts/doclink.lua", "ascii")

exports.upload = (req, res, err) ->
  if req.method is "GET"
    request "#{weedMaster}/dir/assign", (error, response, body) ->
      weedRes = JSON.parse(body)
      res.send weedRes
  else if req.method is "POST"
    request "#{weedMaster}/dir/assign", (error, response, body) ->
      unless error
        weedRes = JSON.parse(body)
        #param = req.route.params[0]
        #uploadEndpoint = "http://#{weedRes.publicUrl}/#{((if (param is "") then weedRes.fid else param))}"
        uploadEndpoint = "http://#{weedRes.publicUrl}/#{weedRes.fid}"
        console.log "Upload Endpoint: #{uploadEndpoint}"
        console.log "URL: #{req.url}  and Original URL: #{req.originalUrl}"
        fileupload req, res, uploadEndpoint, dbentry
      else
        console.log "error: " + error
        res.send "{" + error + "}"

dbentry = (req) ->
  console.log "Req.file: #{req.file}"
  filedata.getData( (err, data) ->
    unless err
      console.log "Data: #{data}"
      client.eval data, 2, "#{req.user.id}", "#{req.user.id}", "#{new Date().getTime()}", "#{req.docurl}", (error, resp) ->
        unless error
          console.log "Response: #{resp}"
        else
          console.log "Error: #{error}"
    else throw new Error("Problem executing the code data")
  )

fileupload = (req, res, uploadEndpoint, fn) ->
  req.connection.setTimeout 10000
  poster = request.post(uploadEndpoint, (err, response, body) ->
    unless err
      console.log err + ":" + response.statusCode + ":" + body
      jsonbody = JSON.parse(body)
      jsonstring = JSON.stringify(jsonbody)
      console.log "jsonbody:  #{jsonstring}"
      console.log "FIle name: #{jsonbody.name}"
      extension = jsonbody.name.substring(jsonbody.name.lastIndexOf("."))
      console.log "Extension #{extension}"
      console.log "Error ofcourse"  if jsonbody.error isnt `undefined`
      unless jsonbody.error
        console.log "Ready to call a function here"
        unless fn == 'undefined'
          req.docurl = uploadEndpoint + extension
          fn(req)
    else
      console.log "Error ::: #{err}"
      return
  )
  #form = poster.form()
  #form.append("file", req.file)
  req.pipe(poster).pipe res

exports.getdocuments = (req, res, err) ->
  client.zscan "owner:#{req.user.id}:docs", 0, (error, resp) ->
    unless error
      console.log "Resp: #{resp[1].length}"
      len = resp[1].length
      docs = []
      for num in [0..len-1]
        if num%2 == 0
          docs.push(resp[1][num])
      res.send(docs)

exports.getdocuments1 = (req, res, err) ->
  client.zscan "owner:#{req.user.id}:docs", 0, (error, resp) ->
    unless error
      console.log "Resp: #{resp[1].length}"
      len = resp[1].length
      docs = []
      fids = []
      for num in [0..len-1]
        if num%2 == 0
          doc = resp[1][num]
          doc1 = doc.substring(doc.indexOf("://")+3)
          doc2 = doc1.substring(0, doc1.indexOf("/"))
          docUrl = doc2.substring(0, doc2.indexOf(":"))
          docPort = doc2.substring(doc2.indexOf(":")+1)
          docFid = doc1.substring(doc1.indexOf("/")+1)
          fids.push docFid
          docs.push("/documents/#{docUrl}/#{docPort}/#{docFid}")
      req.session.fids = fids
      res.send(docs)

exports.getdocuments2 = (req, res, err) ->
  fullzscan "owner:#{req.user.id}:docs", (result) ->
    console.log "Result: #{result}"
    len = result.length
    console.log "Result Length: #{len}"
    docs = []
    fids = []
    for num in [0..len-1] when len > 0
      if num%2 == 0
        doc = result[num]
        doc1 = doc.substring(doc.indexOf("://")+3)
        doc2 = doc1.substring(0, doc1.indexOf("/"))
        docUrl = doc2.substring(0, doc2.indexOf(":"))
        docPort = doc2.substring(doc2.indexOf(":")+1)
        docFid = doc1.substring(doc1.indexOf("/")+1)
        fids.push docFid
        docs.push("/documents/#{docUrl}/#{docPort}/#{docFid}")
    req.session.fids = fids
    res.send(docs)

exports.fileServiceMask = (req, res, err) ->
  #console.log "fileServiceMask(): Err: #{err}"
  console.log "fileServiceMask() got called"
  console.log("FIDS:::::::::" + req.session.fids)
  console.log("FID: "+ fiid) for fiid in req.session.fids
  unless req.session.fids.indexOf(req.params.fid) is -1
    console.log "fileServiceMask(): fid is present in fids"
    reqobj = request "http://#{req.params.vs}:#{req.params.prt}/#{req.params.fid}", (error, response, body) ->
      unless error
        console.log "fileServiceMask(): Error: #{error}"
        console.log "fileServiceMask(): Response: #{response}"
        #console.log "fileServiceMask(): Body: #{body}"
        #response.pipe res
      else
        console.log "fileServiceMask(): Error: #{error}"
    #request.get("http://#{req.params.vs}:#{req.params.prt}/#{req.params.fid}").pipe res
    reqobj.pipe res
  else
    console.log "fileServiceMask(): fid is present NOT present in fids"

fullzscan = (indexname, fn) ->
  result = []
  zscan(indexname, 0, result, fn)

zscan = (indexname, start, acc, fn) ->
  client.zscan indexname, start, (error, resp) ->
    unless error
      console.log "Zscan response[0]: #{resp[0]}"
      console.log "Zscan response[1]: #{resp[1]}"
      acc = acc.concat(resp[1])
      console.log "Accumulator: #{acc}"
      zscan(indexname, parseInt(resp[0]), acc) unless parseInt(resp[0]) == 0
      fn(acc)


####### Code below is not used at this moment #######

exports.sioupload = (socket) ->
  socket.on 'send-file', (name, buffer) ->
    console.log "Name: " + name
    #console.log "Buffer: " + buffer

    request weedMaster + "/dir/assign", (error, response, body) ->
      unless error
        weedRes = JSON.parse body
        uploadEndpoint = "http://" + weedRes.publicUrl + "/" + weedRes.fid
        console.log "Upload Endpoint: " + uploadEndpoint

        poster = request.post(uploadEndpoint, (err, response, body) ->
          unless err
            console.log "******" + response + "*****"
            jsonbody = JSON.parse body
            console.log "jsonbody: " + JSON.stringify jsonbody
            console.log "Error ofcourse"  if jsonbody.error isnt `undefined`
          else
            console.log "err"
        )
        form = poster.form()
        form.append("file", buffer)
        
      else
        console.log "error: " + error
        res.send "{" + error + "}"

  socket.on 'save-file', (name, buffer) ->
    fs = require('fs')

    ###
    stream = fs.createWriteStream(filename)
    stream.once 'open', (fd) ->
      stream.write buffer
      stream.end()
    ###
    
    
    fs.writeFileSync name, buffer, "binary", (err) ->
      console.log buffer.length
      if err
          console.log "Error writing: " + err
      else
        request weedMaster + "/dir/assign", (error, response, body) ->
          unless error
            weedRes = JSON.parse body
            uploadEndpoint = "http://" + weedRes.publicUrl + "/" + weedRes.fid
            console.log "Upload Endpoint: " + uploadEndpoint
            ##fs.createReadStream(name).pipe(request.put(uploadEndpoint))
            poster = request.post(uploadEndpoint, (err, response, body) ->
              unless err
                console.log "******" + response + "*****"
                jsonbody = JSON.parse body
                console.log "jsonbody: " + JSON.stringify jsonbody
                console.log "Error ofcourse"  if jsonbody.error isnt `undefined`
                ##fs.unlinkSync(name)
            )
            form = poster.form()
            form.append("file", fs.createReadStream(name))


  socket.on 'test-stream', (file, buffer) ->
    console.info "Size: #{file.size}"
    form = new FormData()
    form.append "name", file.name
    form.append "size", file.size
    form.append "lastModifiedDate", file.lastModifiedDate
    form.append "type", file.type
    form.append "buffer", buffer
    bufferStream = new stream.Transform()
    #bufferStream.push(form)
    request weedMaster + "/dir/assign", (error, response, body) ->
      unless error
        weedRes = JSON.parse body
        uploadEndpoint = "http://" + weedRes.publicUrl + "/" + weedRes.fid
        console.log "Upload Endpoint: " + uploadEndpoint
        ##fs.createReadStream(name).pipe(request.put(uploadEndpoint))
#        poster = request.post uploadEndpoint, (err, response, body) ->
#          unless err
#            console.log "******" + response + "*****"
#            jsonbody = JSON.parse body
#            console.log "jsonbody: " + JSON.stringify jsonbody
#            #form.pipe(poster)
        form.submit uploadEndpoint, (err, res) ->
          res.resume()

#exports.login = (req, res) ->
#  res.render 'login', { title: 'Login to paperless' }



    
    

