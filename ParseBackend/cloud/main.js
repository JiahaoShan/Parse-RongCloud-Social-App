
// Use Parse.Cloud.define to define as many cloud functions as you want.
// For example:
Parse.Cloud.define("hello", function(request, response) {
  response.success("Hello world!");
});

Parse.Cloud.define("getToken", function(request, response) {
	var HEADERS	  = {};
	var APPSECRET = 'zl5mkXn6NOr';
	var APPKEY = 'c9kqb3rdkhnhj';
	var NONCE = parseInt( Math.random() * 0xffffff );
	var TIMESTAMP = Date.parse( new Date() )/1000;
	var SIGNATURE = APPSECRET + NONCE + TIMESTAMP;
	var crypto = require('crypto')
 	var shasum = crypto.createHash('sha1');
 	shasum.update(SIGNATURE);
 	var hash = shasum.digest('hex');
	HEADERS['Host']	= 'api.cn.ronghub.com';
 	HEADERS['App-Key'] 	 	= APPKEY;
	HEADERS['Nonce'] 		= NONCE;
	HEADERS['Timestamp']	= TIMESTAMP;
	HEADERS['Signature']	= hash;
	HEADERS['Content-Type'] = 'application/x-www-form-urlencoded';	
	Parse.Cloud.httpRequest({
  		method: 'POST',
  		url: 'https://api.cn.ronghub.com/user/getToken.json',
  		headers: HEADERS,
  		body: {
			userId 		: request.params.userId,
			name   		: request.params.name,
			portraitUri : request.params.portraitUri
		}
}).then(function(httpResponse) {
	response.success(httpResponse.text);
}, function(httpResponse) {
  console.error('Request failed with response code ' + httpResponse.status);
  response.error('Request failed with response code ' + httpResponse.status);
});

});