Parse.Cloud.define("PlaygroundPostComment", function(request, response) {
    var feedId = request.params.feedId;
    var userId = request.params.userId;
    var message = request.params.message;
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
    var PlaygroundComment = Parse.Object.extend("PlaygroundComment");
    var like = new PlaygroundComment();
    like.set("commentOwner", userPointer);
    like.set("playgroundFeed", feedPointer);
    like.set("message", message);
    //target owner not implemented
    like.save(null, {
        useMasterKey: true
    }).then(
        function(result) {
            response.success();
        },
        function(error) {
            response.error(error);
        }
    );
});

Parse.Cloud.beforeSave("PlaygroundComment", function(request, response) {
    query = new Parse.Query("PlaygroundFeed");
    query.get(request.object.get("likedFeed").id, {
        success: function(feed) {
            feed.set();
            if (!feed.get("firstComment")) {
                feed.set("firstComment", request.object);
            } else {
                feed.set("latestComment", request.object);
            }
            feed.increment("commentCount");
            feed.save(null, {
                useMasterKey: true
            }).then(function() {
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

Parse.Cloud.define("PlaygroundRemoveComment", function(request, response) {
    var commentId = request.params.commentId;
    query = new Parse.Query("PlaygroundComment");
    query.get(commentId).then(function(cmt) {
        if (!cmt) {
            response.success("does not exist"); //regard this as success
        }
        return cmt.destroy()
    }).then(
        function(result) {
            response.success();
        },
        function(error) {
            response.error("remove like failed: " + error);
        }
    );
});

Parse.Cloud.beforeDelete("PlaygroundComment", function(request, response) {
    var cid = request.object.get("likedFeed").id;
    var feedQuery = new Parse.Query("PlaygroundFeed");
    feedQuery.get(cid).then(function(feed) {
        //delete first
        var feedPointer={
                            __type: "Pointer",
                            className: "PlaygroundFeed",
                            objectId: feed.id
                        };
        if (feed.get("firstComment").id.valueOf() == cid.valueOf()) {
            if (feed.get("latestComment")) {
                //query for new first
                var query = new Parse.Query("PlaygroundComment");
                query.equalTo("playgroundFeed",feedPointer);
                query.ascending("createdAt");
                query.skip(1); //skip the one;
                query.first().then(function(object) {
                    if (object.id.valueOf() == feed.get("latestComment").id.valueOf()) {
                        //only one left
                        feed.set("firstComment", {
                            __type: "Pointer",
                            className: "PlaygroundComment",
                            objectId: object.id
                        });
                        feed.increment("commentCount", -1);
                        feed.set("latestComment", null);
                    } else {
                        feed.increment("commentCount", -1);
                        feed.set("firstComment", {
                            __type: "Pointer",
                            className: "PlaygroundComment",
                            objectId: object.id
                        });
                    }
                    return feed.save(null, {
                        useMasterKey: true
                    });
                });
            } else {
                //no need to query for new first
                feed.set("firstComment", null);
                feed.increment("commentCount", -1);
                return feed.save(null, {
                    useMasterKey: true
                });
            }
        } else if (feed.get("lastestComment").id.valueOf() == cid.valueOf()) {
            //delete last
            //query for new last
            var query = new Parse.Query("PlaygroundComment");
            query.equalTo("playgroundFeed",feedPointer);
            query.descending("createdAt");
            query.skip(1); //skip the one;
            query.first().then(function(object) {
                if (object.id.valueOf() == feed.get("firstComment").id.valueOf()) {
                    //only one left
                    feed.set("latestComment", null);
                    feed.increment("commentCount", -1);
                } else {
                    feed.increment("commentCount", -1);
                    feed.set("latestComment", {
                        __type: "Pointer",
                        className: "PlaygroundComment",
                        objectId: object.id
                    });
                }
                return feed.save(null, {
                    useMasterKey: true
                });
            });
        } else {
            feed.increment("commentCount", -1);
            return feed.save(null, {
                useMasterKey: true
            });
        }
    }).then(
        function(result) {
            response.success();
        },
        function(error) {
            response.error(error);
        }
    );
});
