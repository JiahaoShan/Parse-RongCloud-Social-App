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
    if (!request.object.dirty("images") || !images || images.length == 0) {
        response.success();
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
 
Parse.Cloud.define("PlaygroundGetLikeHistory",function(request,response){
    var userPointer = {
        __type: "Pointer",
        className: "_User",
        objectId: request.params.userId
    };
    query = new Parse.Query("PlaygroundLike");
    query.equalTo("liker",userPointer);
    query.include("likedFeed");
    query.find().then(function(results){
        var IDs = [];
        console.log("00*00");
        console.log(results);
        for(var i=0;i<results.length;i++){
            console.log(results[i].get("likedFeed").id);
            IDs.push(results[i].get("likedFeed").id);
        }
        response.success(JSON.stringify(IDs));
    },
    function(error){
        response.error("error when getting like info for user: "+ error);
    });
});
 
Parse.Cloud.define("PlaygroundAddLike",function(request,response){
    var feedId = request.params.feedId;
    var userId = request.params.userId;
    var feedPointer = {
        __type: "Pointer",
        className: "PlaygroundFeed",
        objectId: feedId
    };
    var userPointer = {
        __type: "Pointer",
        className: "_User",
        objectId: userId
    };
    query = new Parse.Query("PlaygroundLike");
        console.log("00*00");
        query.equalTo("likedFeed",feedPointer);
        query.equalTo("liker",userPointer);
    query.count().then(function(count){
        console.log("00*00");
        console.log(count);
        if(count>=1){
            response.error("user has already liked the feed");
        }
        var PlaygroundLike = Parse.Object.extend("PlaygroundLike");
        var like = new PlaygroundLike();
        like.set("liker",userPointer);
        like.set("likedFeed",feedPointer);
        return like.save(null, {
            useMasterKey: true
        });
    }).then(
        function(result) {response.success();}, 
        function(error) {response.error(error);}
    );
});
 
Parse.Cloud.beforeSave("PlaygroundLike",function(request,response){
    query = new Parse.Query("PlaygroundFeed");
    query.get(request.object.get("likedFeed").id, {
    success: function(feed) {
      var likes  = feed.get("recentLikeUsers");
    if(!likes){
        likes = [];
    }   
        likes.unshift(request.object.get("liker"));
    if(likes.length>8){
        likes.pop();
    }
    feed.increment("likeCount");
    feed.set("recentLikeUsers",likes);
    feed.save(null, { useMasterKey: true }).then(function() {
    response.success();
  }, function(error) {
    response.error(error);
  });
    },
    error: function(error) {
      response.error(error);
    }
  });
});

Parse.Cloud.define("PlaygroundRemoveLike",function(request,response){
    var feedId = request.params.feedId;
    var userId = request.params.userId;
    var feedPointer = {
        __type: "Pointer",
        className: "PlaygroundFeed",
        objectId: feedId
    };
    var userPointer = {
        __type: "Pointer",
        className: "_User",
        objectId: userId
    };
        query = new Parse.Query("PlaygroundLike");
        query.equalTo("likedFeed",feedPointer);
        query.equalTo("liker",userPointer);
        console.log("log3");
        query.find().then(function(results){
        if(results.length<1){
            response.success();//special logic maybe?
            //response.error("user has not liked the feed");
        }
        var like = results[0];
        console.log("log4");
        console.log(results);
        console.log(like);
        return like.destroy();
    }).then(
        function(result) {response.success();}, 
        function(error) {response.error("remove like failed: "+error);}
    );
});

Parse.Cloud.beforeDelete("PlaygroundLike", function(request,response) {
    console.log("log5");
        feedQuery = new Parse.Query("PlaygroundFeed");
        feedQuery.get(request.object.get("likedFeed").id, {
            success: function(feed) {
                console.log("log6");
                console.log(feed);
                var likes  = feed.get("recentLikeUsers");
                if(!likes){
                    likes = [];
                }
                var likeCount  = feed.get("likeCount");
                var isRecentEight = false;

                for (var i = 0 ; i < likes.length; i++) {
                    if (likes[i].id == request.object.get("liker").id) {
                        isRecentEight = true;
                        console.log("log6.5: i="+i);
                        likes.splice(i,1);
                        break;
                    }
                }
                console.log("log7");
                if (isRecentEight && likeCount > 8) {
                    likeQuery = new Parse.Query("PlaygroundLike");
                    likeQuery.equalTo("likedFeed", request.object.get("likedFeed").id);
                    likeQuery.skip(7);
                    likeQuery.descending("createdAt");
                    likeQuery.first({
                        success: function(oldLike) {
                            if (oldLike) {
                                likes.push(oldLike);
                                feed.increment("likeCount",-1);
                                feed.set("recentLikeUsers", likes);
                                feed.save(null, {useMasterKey: true}).then(function () {
                                    response.success();
                                }, function (error) {
                                    response.error("error when saving modified feed while deleting like, reason: "+error.message);
                                });
                            }
                        },
                            error: function(error) {
                                response.error("error when getting next like while deleting like, reason: "+error.message);
                            }
                        });
                }
                else {
                    console.log("log8");
                    feed.increment("likeCount",-1);
                    feed.set("recentLikeUsers",likes);
                    feed.save(null, { useMasterKey: true }).then(function() {
                        console.log("log9");
                        response.success();
                    }, function(error) {
                        response.error("error when modifying feed while deleting like, reason: "+error.message);
                    });
                };
    },
    error: function(error) {
    response.error("error when getting feed while deleting like, reason: "+error.message);
    }
});
});