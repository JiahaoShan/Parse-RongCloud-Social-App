
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

// Parse.Cloud.beforeSave("PlaygroundFeed", function(request, response) {
// 	var images = request.object.get("images");
// 	if (!images || images.length == 0) {
// 		response.success();
// 	//  response.error("you cannot give more than five stars");
// } else {
// 	var index;
// 	var thumbnails
// 	for	(index = 0; index < images.length; index++) {
// 		var url = images[index].url();
// 		Parse.Cloud.httpRequest({ url: url }).then(function(response) {
// 	  // Create an Image from the data.
// 	  var image = new Image();
// 	  return image.setData(response.buffer);
// 	}.then(function(image) {
// 	  // Scale the image to a certain size.
// 	  return image.scale({ width: 64, height: 64 });

// 	}.then(function(image) {
// 	  // Get the bytes of the new image.
// 	  return image.data();

// 	}.then(function(buffer) {
// 	  // Save the bytes to a new file.
// 	  var file = new Parse.File("image.jpg", { base64: data.toString("base64"); });
// 	  return file.save();
// 	}.then(function(file) {
//             var SI = Parse.Object.extend("SI");
//             var si = new SI();
               
//             si.set("file",file);

//             si.save().then(function() {
//                               console.log("saved SI ");

//             }, function(error) {
//                 console.log("faied to save SI ");
//             });
//   });
// }
// response.success();
// }
// });


