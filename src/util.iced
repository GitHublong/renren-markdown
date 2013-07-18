###!
util
!###

util = {}

# array-like => array, else []
util.arrayize = (a) -> if a?.length then [].slice.call(a) else []

# single quotes <=> double quotes
util.squote_to_dquote = (s) -> s.replace /'/g, '"'
util.dquote_to_squote = (s) -> s.replace /"/g, "'"

# safely unescape javascript string representation
util.jsStr = (s) ->
  if !(s = s?.trim()) then return null
  switch
    when m = s.match /^"(.*)"$/
      # double quoted, feed to JSON
      try return JSON.parse s
      catch e then return null
    when m = s.match /^'(.*)'$/
      # single quoted, parse by hand (ignoring irregularities)
      # http://blogs.learnnowonline.com/blog/bid/191997/Escape-Sequences-in-String-Literals-Using-JavaScript
      s = m[1]
      hex_to_char = ($0, $1) -> String.fromCharCode parseInt($1, 16)
      loop
        s2 = s
          .replace(/\\n/, '\n') # \n
          .replace(/\\r/, '\r') # \r
          .replace(/\\t/, '\t') # \t
          .replace(/\\x([0-9A-Fa-f]{2})/, hex_to_char) # \xHH
          .replace(/\\u([0-9A-Fa-f]{4})/, hex_to_char) # \xHHHH
          .replace(/\\([^nrtxu0])/, '$1') # \whatever
        if s2 == s then break
        s = s2
      return s
    else return null

# string <=> base64
util.str_to_b64 = (str) -> window.btoa unescape encodeURIComponent str
util.b64_to_str = (b64) -> decodeURIComponent escape window.atob b64

# add script tag to document
#   script => run
#   function => IIFE
util.injectScript = (doc, x) ->
  el = doc.createElement 'script'
  el.textContent = switch typeof x
    when 'string' then x
    when 'function' then "(#{x.toString()})();"
  doc.head.appendChild el

# inject function into global namespace
util.injectFunction = (doc, name, f) ->
  if f instanceof Function
    util.injectScript doc, ";var #{name} = #{f.toString()};"

# scrolling
util.canScroll = (el) -> !! el?.scrollHeight?

util.scrollRange = (el) ->
  if util.canScroll(el) then return null
  el.scrollHeight - el.clientHeight

util.scrollRatio = (el) ->
  if util.canScroll(el) then return null
  el.scrollTop / util.scrollRange(el)

util.setScrollRatio = (el, ratio) ->
  if util.canScroll(el) then return null
  if !isFinite(ratio) then return null
  ratio = Math.min(Math.max(ratio, 0), 1)
  el.scrollTop = ratio * util.scrollRange(el)

# periodically do check until true, then callback
util.pollUntil = (period, check, cb) ->
  if check instanceof Function && cb instanceof Function
    iid = setInterval (-> if check() then cb clearInterval iid), period # pun intended

# go fullscreen
# http://davidwalsh.name/fullscreen
util.launchFullScreen = (el) ->
  switch
    when el.requestFullScreen then el.requestFullScreen()
    when el.mozRequestFullScreen then el.mozRequestFullScreen()
    when el.webkitRequestFullScreen then el.webkitRequestFullScreen()
    else debugger # FIXME

util.cancelFullScreen = ->
  switch
    when document.cancelFullScreen then window.top.document.cancelFullScreen()
    when document.mozCancelFullScreen then window.top.document.mozCancelFullScreen()
    when document.webkitCancelFullScreen then window.top.document.webkitCancelFullScreen()
