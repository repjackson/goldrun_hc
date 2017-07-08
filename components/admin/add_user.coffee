FlowRouter.route '/user/add', action: (params) ->
    BlazeLayout.render 'layout',
        nav: 'nav'
        main: 'add_user'
 
 
if Meteor.isClient
    Template.add_user.onCreated ->
        # @autorun ->  Meteor.subscribe 'users'
    
    
    Template.add_user.helpers
        # users: -> Meteor.users.find {}
            
    
    
    Template.add_user.events
        
        