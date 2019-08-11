var express = require('express');
var router = express.Router();

/* GET home page. */
router.get('/', function(req, res, next) {
  res.render('index', { title: 'UIWebView' });
});

router.get('/wk', function(req, res, next) {
  res.render('wk', { title: 'WKWebView' });
});

router.get('/bridge1', function(req, res, next) {
  res.render('bridge1', { title: 'WKWebView' });
});

router.get('/smtbridge1', function(req, res, next) {
  res.render('smtbridge1', { title: 'SMTBridge 1' });
});

module.exports = router;
