if Meteor.isClient
    FlowRouter.route '/', action: ->
        BlazeLayout.render 'layout', 
            main: 'home'
    
    Template.home.onCreated ->
        @autorun -> Meteor.subscribe('featured_posts')
    
    Template.home.helpers
        featured_posts: -> 
            Docs.find {featured:true},
                sort:
                    publish_date: -1
                limit: 10
                
    Template.home.events
        # 'click #add_post': ->
        #     id = Docs.insert type: 'post'
        #     FlowRouter.go "/post/edit/#{id}"
    