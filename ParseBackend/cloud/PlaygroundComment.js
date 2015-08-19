// Parse.Cloud.define("PlaygroundPostComment", function(request, response) {
//     console.log("post comment:"+request.params.feedId);
//     var feedId = request.params.feedId;
//     var userId = request.params.userId;
//     var message = request.params.message;
//     var feedPointer = {
//         __type: "Pointer",
//         className: "PlaygroundFeed",
//         objectId: feedId
//     };
//     var userPointer = {
//         __type: "Pointer",
//         className: "_User",
//         objectId: userId
//     };
//     var PlaygroundComment = Parse.Object.extend("PlaygroundComment");
//     var comment = new PlaygroundComment();
//     comment.set("commentOwner", userPointer);
//     comment.set("playgroundFeed", feedPointer);
//     comment.set("message", message);
//     //target owner not implemented
//     comment.save(null, {
//         useMasterKey: true
//     }).then(
//         function(result) {
//             response.success();
//         },
//         function(error) {
//             response.error(error);
//         }
//     );
// });
Parse.Cloud.afterSave("PlaygroundComment", function(request) {
    console.log(request.object);
    var fid = request.object.get("playgroundFeedId");
    console.log("fid: " + fid);
    query = new Parse.Query("PlaygroundFeed");
    console.log("query: " + query);
    query.get(fid).then(function(feed) {
        var comments = feed.get("recentComments");
        if (!comments) {
            comments = [];
        }
        comments.unshift(request.object);
        if (comments.length > 8) {
            comments.pop();
        }
        feed.set("recentComments", comments);
        feed.increment("commentCount");
        console.log("before it saves");
        return feed.save(null, {
            useMasterKey: true
        });
    }).then(function() {
        console.log("success");
    }, function(error) {
        console.log(error);
    });
});
Parse.Cloud.define("PlaygroundRemoveComment", function(request, response) {
    var cid = request.params.commentId;
    var comment;
    var promise;
    query = new Parse.Query("PlaygroundComment");
    promise=query.get(cid);
    return promise.then(function(cmt) {
        if (!cmt) {
            response.success("does not exist"); //regard this as success
        }
        if (!cmt.get("playgroundFeedId")) {
            response.success();
        } else if (request.user.id.valueOf() != cmt.get("commentOwner").id.valueOf()) {
            response.error("cannot delete comment by other user");
        }
        comment = cmt;
        var fid = cmt.get("playgroundFeedId");
        var feedQuery = new Parse.Query("PlaygroundFeed");
        return feedQuery.get(fid);
    }).then(function(feed) {
        var feedPointer = {
            __type: "Pointer",
            className: "PlaygroundFeed",
            objectId: feed.id
        };
        var comments = feed.get("recentComments");
        if (!comments) {
            comments = [];
        }
        var likeCount = feed.get("commentCount");
        var isRecentEight = false;

        for (var i = 0; i < comments.length; i++) {
            if (comments[i].id.valueOf() == cid.valueOf()) {
                isRecentEight = true;
                console.log("log6.5: i=" + i);
                comments.splice(i, 1);
                break;
            }
        }
        console.log("log7");
        if (isRecentEight && likeCount > 8) {
            likeQuery = new Parse.Query("PlaygroundComment");
            likeQuery.equalTo("playgroundFeed", feed.id);
            likeQuery.skip(7);
            likeQuery.descending("createdAt");
            return promise.then(function(){
                return likeQuery.first();
            }).then(function(oldComment){
                    likes.push(oldComment);
                    feed.increment("commentCount", -1);
                    feed.set("recentComments", comments);
                    return feed.save(null, {
                        useMasterKey: true
                    });
            });
        } else {
            console.log("log8");
            feed.increment("commentCount", -1);
            feed.set("recentComments", comments);
            return feed.save(null, {
                useMasterKey: true
            });
        };
    }).then(function(feed){
        return comment.destroy();
    }).then(
    function(result) {
        response.success();
    },
    function(error) {
        response.error("remove like failed: " + error);
    });
});
