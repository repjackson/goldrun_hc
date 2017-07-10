if Meteor.isClient
    FlowRouter.route '/people', action: ->
        BlazeLayout.render 'layout', 
            main: 'people'
            
            
    Template.people.onCreated ->
        @autorun -> Meteor.subscribe('users')
   

    Template.people.helpers
        people: -> Meteor.users.find()
                
    Template.people.events
        'click #add_person': ->
            id = Docs.insert type:'person'
            FlowRouter.go "/person/edit/#{id}"
    