###!
process
!###

process = {}

process.sync = ->
  md = ui.getSource()
  el = markdown.convert md
  process._async = postproc.run el
  ui.setPreview el
  ui.setPreviewCss markdown.cssText

# ensure that each `async` from `postproc.run` is run only once
process._async = (->)
process.async = (cb) ->
  el = ui.getPreview()
  core.inlineCss(el, markdown.cssRules)
  process._async(cb)
  process._async = (->)

process.commit = ->
  el = ui.getPreview()
  core.spanify el
  # TODO: extra steps
  tinymce.call 'setContent', el.innerHTML, (->)
  ui.hide()
