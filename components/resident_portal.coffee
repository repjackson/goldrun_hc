if Meteor.isClient
    Router.route '/resident_portal', -> @render 'resident_portal'

    Template.published_resident_small.onCreated ->
        @autorun -> Meteor.subscribe 'published_residents'
    Template.published_resident_small.helpers
        published_residents: ->
            Meteor.users.find {
                roles:$in:['resident']
                profile_published:true
            },
                sort: karma: -1


    Template.most_viewed_posts.onCreated ->
        @autorun -> Meteor.subscribe 'published_residents'
    Template.most_viewed_posts.helpers
        most_viewed_posts: ->
            Docs.find {},
                sort:views:-1
                limit:10

    Template.karma_leaderboard.onCreated ->
        @autorun -> Meteor.subscribe 'karma_leaderboard'
    Template.karma_leaderboard.helpers
        top_karma_users: ->
            Meteor.users.find {},
                sort:points:-1
                limit:10


    Template.most_viewed_models.onCreated ->
        @autorun -> Meteor.subscribe 'most_viewed_models'
    Template.most_viewed_models.helpers
        most_viewed: ->
            Docs.find {model:'model'},
                sort: views:-1
                limit:10



    Template.events_small.onCreated ->
        @autorun -> Meteor.subscribe 'model_docs', 'event'
    Template.events_small.helpers
        gr_events: ->
            Docs.find {model:'event'},
                sort: timestamp: -1




    Template.posts_small.onCreated ->
        @autorun -> Meteor.subscribe 'model_docs', 'post'
    Template.posts_small.helpers
        posts: ->
            Docs.find {model:'post'},
                sort: timestamp: -1



    Template.marketplace_small.onCreated ->
        @autorun -> Meteor.subscribe 'model_docs', 'market'
    Template.marketplace_small.helpers
        market_items: ->
            Docs.find {model:'shop'},
                sort: timestamp: -1




if Meteor.isServer
    Meteor.publish 'published_residents', ->
        Meteor.users.find
            roles:$in:['resident']
            profile_published:true

    Meteor.publish 'most_viewed_models', ->
        Docs.find {model:'model'},
            sort:views:-1
            limit:10

    Meteor.publish 'karma_leaderboard', ->
        Meteor.users.find {},
            sort:points:-1
            limit:10
