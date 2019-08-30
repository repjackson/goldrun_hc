if Meteor.isClient
    Template.events_small.onCreated ->
        @autorun -> Meteor.subscribe 'model_docs', 'event'
    Template.posts_small.onCreated ->
        @autorun -> Meteor.subscribe 'model_docs', 'post'
    Template.marketplace_small.onCreated ->
        @autorun -> Meteor.subscribe 'model_docs', 'market'
    Template.published_resident_small.onCreated ->
        @autorun -> Meteor.subscribe 'published_residents'


    Template.events_small.helpers
        gr_events: ->
            Docs.find {model:'event'},
                sort: timestamp: -1
    Template.posts_small.helpers
        posts: ->
            Docs.find {model:'post'},
                sort: timestamp: -1
    Template.marketplace_small.helpers
        market_items: ->
            Docs.find {model:'shop'},
                sort: timestamp: -1




if Meteor.isServer
    Meteor.publish 'published_residents', ->
        Meteor.users.find
            roles:$in:['resident']
            
