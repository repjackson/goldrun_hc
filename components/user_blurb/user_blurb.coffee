if Meteor.isClient
    Template.user_blurb.onCreated ->
        @autorun -> 
            Meteor.subscribe('user_blurb', Template.currentData().author_id)
    
    Template.user_blurb.helpers
        person: -> 
            Meteor.users.findOne( _id: Template.currentData().author_id )

if Meteor.isServer
    Meteor.publish 'user_blurb', (id)->
        # console.log id
        Meteor.users.find id,
            fields:
                tags: 1
                profile: 1
                points: 1