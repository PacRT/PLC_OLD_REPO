request = require("request")
stream = require("stream")
FormData = require("form-data")
weedMaster = "http://50.185.122.11:9333"

util = require "util"

exports.upload = (req, res, err) ->
  if req.method is "GET"
    request weedMaster + "/dir/assign", (error, response, body) ->
      weedRes = JSON.parse(body)
      res.send weedRes
  else if req.method is "POST"
    request weedMaster + "/dir/assign", (error, response, body) ->
      unless error
        weedRes = JSON.parse(body)
        param = req.route.params[0]
        uploadEndpoint = "http://" + weedRes.publicUrl + "/" + ((if (param is "") then weedRes.fid else param))
        console.log "Upload Endpoint: " + uploadEndpoint
        fileupload req, res, uploadEndpoint, dbentry
      else
        console.log "error: " + error
        res.send "{" + error + "}"

dbentry = (req) ->
  console.log "DB Entry function has been called"
  console.log "DB Entry::: username = #{req.user.username}"
  console.log "DB Entry::: id = #{req.user.id}"


fileupload = (req, res, uploadEndpoint, fn) ->
  req.connection.setTimeout 10000
  poster = request.post(uploadEndpoint, (err, response, body) ->
    unless err
      console.log err + ":" + response.statusCode + ":" + body
      jsonbody = JSON.parse(body)
      console.log "jsonbody: " + JSON.stringify(jsonbody)
      console.log "Error ofcourse"  if jsonbody.error isnt `undefined`
      unless jsonbody.error
        console.log "Ready to call a function here"
        unless fn == 'undefined'
          fn(req)
    else
      console.log "Error ::: #{err}"
      return
  )
  #form = poster.form()
  #form.append("file", req.file)
  req.pipe(poster).pipe res

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



    
    

