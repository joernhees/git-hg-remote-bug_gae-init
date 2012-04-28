window.service_call = (method, url, params, data, callback, progress) ->
  progress = progress || callback || data || params
  callback = callback || data || params
  data = data || params
  if progress == callback
    progress = undefined
  if arguments.length == 4
    data = undefined
  if arguments.length ==  3
    params = undefined
    data = undefined
  params = params || {}
  for k, v of params
    delete params[k] if not v?
  $.ajax
    type: method
    url: url + '?' + $.param(params)
    contentType: 'application/json'
    accepts: 'application/json'
    dataType: 'json'
    data: if data then JSON.stringify(data) else undefined
    progress: progress
    success: (response) ->
      if response.status == 'success'
        more = undefined
        if response.more_cursor
          params.cursor = response.more_cursor
          more = (callback) -> service_call(method, url, params, callback)
        callback undefined, response.result, more
      else
        callback response
    error: (jqXHR, textStatus, errorThrown) ->
      error =
        error_code: 'ajax_error'
        text_status: textStatus
        error_thrown: errorThrown
        jqXHR: jqXHR
      try
        error = $.parseJSON(jqXHR.responseText) if jqXHR.responseText
      catch e
        error = error
      LOG 'service call error', error
      callback error
