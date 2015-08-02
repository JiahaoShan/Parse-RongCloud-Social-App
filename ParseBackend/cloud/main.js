// Use Parse.Cloud.define to define as many cloud functions as you want.
// For example:
Parse.Cloud.define("hello", function(request, response) {
    response.success("Hello world!");
});

Parse.Cloud.define("getToken", function(request, response) {
    var HEADERS = {};
    var APPSECRET = 'zl5mkXn6NOr';
    var APPKEY = 'c9kqb3rdkhnhj';
    var NONCE = parseInt(Math.random() * 0xffffff);
    var TIMESTAMP = Date.parse(new Date()) / 1000;
    var SIGNATURE = APPSECRET + NONCE + TIMESTAMP;
    var crypto = require('crypto')
    var shasum = crypto.createHash('sha1');
    shasum.update(SIGNATURE);
    var hash = shasum.digest('hex');
    HEADERS['Host'] = 'api.cn.ronghub.com';
    HEADERS['App-Key'] = APPKEY;
    HEADERS['Nonce'] = NONCE;
    HEADERS['Timestamp'] = TIMESTAMP;
    HEADERS['Signature'] = hash;
    HEADERS['Content-Type'] = 'application/x-www-form-urlencoded';
    Parse.Cloud.httpRequest({
        method: 'POST',
        url: 'https://api.cn.ronghub.com/user/getToken.json',
        headers: HEADERS,
        body: {
            userId: request.params.userId,
            name: request.params.name,
            portraitUri: request.params.portraitUri
        }
    }).then(function(httpResponse) {
        response.success(httpResponse.text);
    }, function(httpResponse) {
        console.error('Request failed with response code ' + httpResponse.status);
        response.error('Request failed with response code ' + httpResponse.status);
    });
});

var Image = require("parse-image");
var _ = require('underscore.js');
Parse.Cloud.beforeSave("PlaygroundFeed", function(request, response) {
    var images = request.object.get("images");
    if (!images || images.length == 0) {
        response.success();
        //  response.error("you cannot give more than five stars");
    } else {
        var index;
        var convertedImages = [];
        var imageCount = images.length;
        var promise = Parse.Promise.as();
        var count = 0;
        _.each(images, function(currImage) {
            // For each item, extend the promise with a function to delete it.
            console.log("Enter each");
            promise = promise.then(function() {
                return Parse.Cloud.httpRequest({
                    url: currImage.url()
                }).then(function(response) {
                    console.log("Enter httpRequest");
                    // Create an Image from the data.
                    var image = new Image();
                    return image.setData(response.buffer);
                }).then(function(image) {
                    // Crop the image to the smaller of width or height.
                    var size = Math.min(image.width(), image.height());
                    console.log("still working here!!!!");
                    return image.crop({
                        left: (image.width() - size) / 2,
                        top: (image.height() - size) / 2,
                        width: size,
                        height: size
                    });

                }).then(function(image) {
                    // Resize the image to 100x100.
                    return image.scale({
                        width: 100,
                        height: 100
                    });

                }).then(function(image) {
                    // Make sure it's a JPEG to save disk space and bandwidth.
                    return image.setFormat("JPEG");
                }).then(function(image) {
                    // Get the image data in a Buffer.
                    console.log("still working here!");
                    return image.data();
                }).then(function(buffer) {
                    // Save the bytes to a new file.
                    var base64 = buffer.toString("base64");
                    var thumb = new Parse.File("thumbnail.jpg", {
                        base64: base64
                    });
                    console.log("still working here");
                    return thumb.save();
                }).then(function(thumb) {
                    var data = {
                        __type: 'File',
                        name: thumb.name(),
                        url: thumb.url()
                    };
                    convertedImages.push(data);
                }).then(function(result) {
                    count++;
                    if (imageCount == count) {
                        console.log("Done!");
                        request.object.set("thumbnails", convertedImages);
                        response.success();
                    }
                    // status.success("Job completed");
                    //response.success();
                }, function(error) {
                    count++;
                    console.log("Done!");
                    request.object.set("thumbnails", convertedImages);
                    response.error();
                    // status.error("Error running Job");
                    //response.error(error);
                })
            });
        })
    }
});
