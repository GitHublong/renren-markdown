// Generated by IcedCoffeeScript 1.4.0a
var escapeCssText, getCssRules, getTextNodesIn, inlineCss, spanifyAll;

getTextNodesIn = function(node) {
  var getTextNodes, textNodes;
  textNodes = [];
  getTextNodes = function(node) {
    var n, _i, _len, _ref;
    if (node.nodeType === 3) {
      textNodes.push(node);
    } else {
      _ref = node.childNodes;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        n = _ref[_i];
        getTextNodes(n);
      }
    }
    return null;
  };
  getTextNodes(node);
  return textNodes;
};

getCssRules = function(css) {
  var doc;
  doc = JQ('<iframe />').css('display', 'none').appendTo('body')[0].contentDocument;
  JQ(doc).find('head').append("<style>" + css + "</style>");
  return doc.styleSheets[0].cssRules;
};

escapeCssText = function(cssText) {
  return cssText.replace(/"/g, "'");
};

inlineCss = function(el, cssRules) {
  var jel, list, rule, _i, _len, _ref;
  jel = JQ(el);
  for (_i = 0, _len = cssRules.length; _i < _len; _i++) {
    rule = cssRules[_i];
    list = (_ref = jel[0]) != null ? _ref.querySelectorAll(rule.selectorText) : void 0;
    if (list != null) {
      [].slice.call(list).forEach(function(x) {
        return x.style.cssText = (escapeCssText(rule.style.cssText)) + ';' + (escapeCssText(x.style.cssText));
      });
    }
  }
  return jel;
};

spanifyAll = function(el) {
  var jel, spanify;
  jel = JQ(el);
  spanify = function(el) {
    if (el == null) return JQ('<span />');
    return JQ("<span style=\"" + (escapeCssText(el.style.cssText)) + "\">" + el.innerHTML + "</span>");
  };
  jel.find('pre').each(function() {
    var str, text, _i, _len, _ref, _results;
    _ref = getTextNodesIn(this);
    _results = [];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      text = _ref[_i];
      str = text.data.toString().replace(/\&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/\ /g, '&nbsp;').replace(/[\n\r\v]/g, '<br/>');
      _results.push(JQ(text).replaceWith("<span>" + str + "</span>"));
    }
    return _results;
  });
  jel;
  jel.find('td').children().each(function() {
    var _base;
    return (_base = this.style).whiteSpace || (_base.whiteSpace = 'nowrap');
  });
  [['pre, code', 'inline'], ['s, del', 'inline'], ['div, p, blockquote', 'block'], ['h1, h2, h3, h4, h5, h6', 'block'], ['td', 'table-cell'], ['tr', 'table-row'], ['tbody', 'table'], ['table', 'block']].forEach(function(arg) {
    (function(tag, disp) {
      var s, x, _base;
      while (x = jel.find(tag)[0]) {
        s = spanify(x);
        (_base = s[0].style).display || (_base.display = disp);
        JQ(x).replaceWith(s);
      }
    }).apply(null, arg);
  });
  ['a'].forEach(function(tag) {
    return jel.find(tag).each(function() {
      var st;
      st = this.style.cssText;
      this.style.cssText = '';
      return JQ(this).wrap("<span style=\"" + (escapeCssText(st)) + "\"/>");
    });
  });
};