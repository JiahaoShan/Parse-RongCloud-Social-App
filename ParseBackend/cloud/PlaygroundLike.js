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
            response.success("user has already liked the feed");//consider this success
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