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

Parse.Cloud.beforeSave(Parse.User, function(request, response) {
    Parse.Cloud.useMasterKey(); 
    var user = request.object;

    if(!user.get("email")){
        response.error("邮箱不能为空！");
    }
    else if(!user.get("username")){
        response.error("用户名不能为空！");
    }

if (user.dirty("email")) {
    var email = user.get("email");
    var pos = email.indexOf("@");
    var domain = email.substr((pos+1));

    var university = Parse.Object.extend("University");
    var query = new Parse.Query(university);
    query.include("aliasPointer");
    query.equalTo("domain", domain);
                console.log("+++Succes@@s");

    query.first({
        success: function(object) {
            console.log("+++Success");
            if (object) {
                            console.log("+++Succe1ss");
                if (!object.get("aliasPointer")) {
                user.set("University", object);
                response.success();      
              }
                else {
                                console.log("+++Success2");

                user.set("University", object.get("aliasPointer")); 
                response.success();     
                }
            }
            else {
                            console.log("+++Succ3ess");

                console.error("Edu domain not found: " + domain);
                if (domain.substr(domain.length - 4) == ".edu") {
                    response.success("版本内测ing...由于近期流量过大，为了防止宇宙被破坏，服务器突然被累死，您所在的学校正在被逐步挖掘中，将于近几日逐步开启校园，请关注您的邮件。"
                        + "您作为首批用户也将得到部分特权，如果您心急，可以分享到我们给您的朋友，人数达标次日将自动开通。");  
                }
                else response.success("这邮箱不对吧。。。");  
            }
            
    },
        error: function(error) {
                console.error("Edu domain not found: " + domain);
             console.error("Error: " + error.code + " " + error.message);
             response.error(error.message);
    }
});
}
else if (user.dirty("portrait")) {
    Parse.Cloud.httpRequest({
    url: user.get("portrait").url()
  }).then(function(response) {
    var image = new Image();
    return image.setData(response.buffer);
  }).then(function(image) {
    var size = Math.min(image.width(), image.height());
    return image.crop({
      left: (image.width() - size) / 2,
      top: (image.height() - size) / 2,
      width: size,
      height: size
    });
  }).then(function(image) {
    // Resize the image to 64x64.
    return image.scale({
      width: 64,
      height: 64
    });
  }).then(function(image) {
    return image.setFormat("JPEG");
  }).then(function(image) {
    return image.data();
  }).then(function(buffer) {
    var base64 = buffer.toString("base64");
    var cropped = new Parse.File("thumbnail.jpg", { base64: base64 });
    return cropped.save();
  }).then(function(cropped) {
    // Attach the image file to the original object.
    user.set("portraitThumbnail", cropped);
    // SHIFT POTRAITS
    if (!user.get("userPortraits")) {
        var portraitsArray = [];
        var portraitThumbnailArray = [];
        var image = user.get("portrait");
        var data = {
                        __type: 'File',
                        name: image.name(),
                        url: image.url()
                    };
        portraitsArray.push(data);
        user.set("userPortraits", portraitsArray);
        var thumbData = {
                        __type: 'File',
                        name: cropped.name(),
                        url: cropped.url()
                    };
        portraitThumbnailArray.push(thumbData);
        user.set("userPortraitsThumbnails", portraitsArray);
    }
    else {
        var portraitsArray = user.get("userPortraits");
        var portraitThumbnailArray = user.get("userPortraitsThumbnails");
        var image = user.get("portrait");
        var data = {
                        __type: 'File',
                        name: image.name(),
                        url: image.url()
                    };
        portraitsArray.push(data);

        var thumbData = {
                        __type: 'File',
                        name: cropped.name(),
                        url: cropped.url()
                    };
        portraitThumbnailArray.push(thumbData);
        // PotraitNumber
        if (portraitsArray.length > 9) {
            portraitsArray.shift();
            portraitThumbnailArray.shift();
        }
        user.set("userPortraits", portraitsArray);
        user.set("userPortraitsThumbnails", portraitThumbnailArray);
    }
  }).then(function(result) {
    response.success();
  }, function(error) {
    response.error(error);
  });
}
else {
    response.success();
}

});