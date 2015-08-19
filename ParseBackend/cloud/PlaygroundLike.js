Parse.Cloud.define("PlaygroundGetLikeHistory",function(request,response){
    var userPointer = {
        __type: "Pointer",
        className: "_User",
        objectId: request.params.userId
    };
    query = new Parse.Query("PlaygroundLike");
    query.equalTo("liker",userPointer);
    //query.include("likedFeed") dont need to get likedfeed's detail
    query.find().then(function(results){
        var IDs = [];
        console.log("00*00");
        console.log(results);
        for(var i=0;i<results.length;i++){
            console.log(i+"/"+results.length);
            console.log(results[i]);
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
            return;
        }
        var PlaygroundLike = Parse.Object.extend("PlaygroundLike");
        var like = new PlaygroundLike();
        like.set("liker",userPointer);
        like.set("likedFeed",feedPointer);
        like.save(null, {
            useMasterKey: true
        }).then(
        function(result) {response.success();}, 
        function(error) {response.error(error);}
        );
    });
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
    
    var like;
    
    var promise;
    
        query = new Parse.Query("PlaygroundLike");
        query.equalTo("likedFeed",feedPointer);
        query.equalTo("liker",userPointer);
        console.log("log3");
        promise = query.first();
        return promise.then(function(result){
        if(!result){
            response.success();//special logic maybe?
            //response.error("user has not liked the feed");
        }
        like = result;
        var feedQuery = new Parse.Query("PlaygroundFeed");
        return feedQuery.get(feedId);
    }).then(function(feed){
        var likes  = feed.get("recentLikeUsers");
        if(!likes){
            likes = [];
        }
        var likeCount  = feed.get("likeCount");
        var isRecentEight = false;

        for (var i = 0 ; i < likes.length; i++) {
            if (likes[i].id == userId) {
                isRecentEight = true;
                console.log("log6.5: i="+i);
                likes.splice(i,1);
                break;
            }
        }
        console.log("log7");
        if (isRecentEight && likeCount > 8) {
            likeQuery = new Parse.Query("PlaygroundLike");
            likeQuery.equalTo("likedFeed", feedId);
            likeQuery.skip(7);
            likeQuery.descending("createdAt");
            promise = promise.then(function(){
                return likeQuery.first();
            })
            promise = promise.then(function(oldLike){
                if (oldLike) {
                    likes.push(oldLike);
                    feed.increment("likeCount",-1);
                    feed.set("recentLikeUsers", likes);
                    return feed.save(null, {useMasterKey: true});
                }
            });
            return promise;
        }
        else {
            console.log("log8");
            feed.increment("likeCount",-1);
            feed.set("recentLikeUsers",likes);
            return feed.save(null, { useMasterKey: true });}
        
        }).then(function(feed) {
                console.log("log9");
                console.log(like);
                return like.destroy();
    }).then(
        function(result) {console.log("log9");response.success();}, 
        function(error) {response.error("remove like failed: "+error);}
    );
});