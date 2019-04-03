if Meteor.isClient
    Router.route '/users', action: ->
        BlazeLayout.render 'layout', 
            main: 'users'
            
            
    Template.people.onCreated ->
        @autorun -> Meteor.subscribe('users')
   

    Template.users.helpers
        users: -> Meteor.users.find()
                
    Template.users.events
        # 'click #add_user': ->
        #     id = Docs.insert type:'person'
        #     Router.go "/person/edit/#{id}"
    