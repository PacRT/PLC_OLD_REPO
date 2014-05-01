multiparty  = require("multiparty")

exports.stream_file_upload = (req, res, next) ->
  # Create the formidable form
  form = new multiparty.Form()
  needed_parts = 0 
  succeeded_parts = 0 

  form.on "part", (part) ->
    needed_parts += 1
    if part.filename
      # Handle unzipping
      req.file = part
      next() if needed_parts == succeeded_parts += 1
    else
      # Need to wait for these to get parsed before next
      val = ""
      part.on "data", (data) ->
        val += data
      part.on "end", () ->
        req.body[part.name] = val 
        next() if needed_parts == succeeded_parts += 1

