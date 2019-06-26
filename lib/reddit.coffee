if Meteor.isClient
    Template.reddit.onCreated ->
        @autorun => Meteor.subscribe 'doc_id', @data._id


    Template.reddit.helpers
        result: ->
            Docs.findOne
                _id: Template.currentData()._id

if Meteor.isServer
    Meteor.methods
        pull_subreddit: (subreddit)->
            response = HTTP.get("http://reddit.com/r/#{subreddit}.json")
            # return response.content

            _.each(response.data.data.children, (item)->
                data = item.data
                len = 200
                reddit_post =
                    reddit_id: data.id
                    url: data.url
                    subreddit: data.domain
                    comment_count: data.num_comments
                    permalink: data.permalink
                    title: data.title
                    # selftext: false
                    # thumbnail: false
                    model:'reddit'

                existing_doc = Docs.findOne reddit_id:data.id
                if existing_doc
                    Meteor.call 'get_reddit_post', existing_doc._id, data.id, (err,res)->
                else
                    new_reddit_post_id = Docs.insert reddit_post
                    Meteor.call 'get_reddit_post', new_reddit_post_id, data.id, (err,res)->
            )

        get_reddit_post: (doc_id, reddit_id)->
            HTTP.get "http://reddit.com/by_id/t3_#{reddit_id}.json", (err,res)->
                if err then console.error err
                else
                    if res.data.data.children[0].data.selftext
                        Docs.update doc_id, {
                            $set: html: res.data.data.children[0].data.selftext
                        }, ->
                        #     Meteor.call 'pull_site', doc_id, url
                    # if res.data.data.children[0].data.url
                    #     url = res.data.data.children[0].data.url
                    #     Docs.update doc_id, {
                    #         $set:
                    #             reddit_url: url
                    #             url: url
                    #     }, ->
                    #         Meteor.call 'pull_site', doc_id, url
                    # Docs.update doc_id,
                    #     $set: reddit_data: res.data.data.children[0].data


        get_listing_comments: (doc_id, subreddit, reddit_id)->
            # HTTP.get "https://www.reddit.com/r/t5_#{subreddit}/comments/t3_#{reddit_id}/irrelevant_string.json", (err,res)->
            HTTP.get "https://www.reddit.com/r/0xProject/comments/t3_#{reddit_id}/irrelevant_string.json", (err,res)->
                if err then console.error err
                else
