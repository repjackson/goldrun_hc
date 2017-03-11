if Meteor.isClient
    Template.my_posts.onCreated ->
        @autorun -> Meteor.subscribe('my_posts')
    
    
    Template.my_posts.helpers
        my_posts: -> 
            Posts.find {},
                sort:
                    publish_date: -1
                
    
    
    
if Meteor.isServer
    Meteor.publish 'my_posts', ->
        Posts.find
            author_id: @userId

