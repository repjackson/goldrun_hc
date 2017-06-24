@Requests = new Meteor.Collection 'requests'

Requests.before.insert (userId, request)->
    request.timestamp = Date.now()
    request.author_id = Meteor.userId()


Requests.helpers
    author: -> Meteor.users.findOne @author_id
    when: -> moment(@timestamp).fromNow()


if Meteor.isClient
    FlowRouter.route '/requests', action: ->
        BlazeLayout.render 'layout', 
            main: 'requests'
            
            
    FlowRouter.route '/request/edit/:request_id', action: ->
        BlazeLayout.render 'layout', 
            main: 'edit_request'
    
    
    
    Template.requests.onCreated ->
        @autorun -> Meteor.subscribe('requests')

    Template.edit_request.onCreated ->
        @autorun -> Meteor.subscribe('request', FlowRouter.getParam('request_id'))

    
    Template.requests.helpers
        requests: -> Requests.find() 

         
         
         
                
    Template.requests.events
        'click #add_request': ->
            id = Requests.insert {}
            FlowRouter.go "/request/edit/#{id}"
    

    Template.request.events
        'click .approve': ->
            Requests.update @_id,
                $set:
                    approved: true
        
        'click .disapprove': ->
            Requests.update @_id,
                $set:
                    approved: false
            




    Template.edit_request.helpers
        request: -> 
            request_id = FlowRouter.getParam 'request_id'
            Requests.findOne  request_id

    Template.edit_request.events
        'blur #request_date': ->
            request_date = $('#request_date').val()
            console.log request_date
            Requests.update FlowRouter.getParam('request_id'),
                $set:
                    request_date: request_date
    
        'click .shift': ->
            console.log @
    
        'click #delete_request': ->
            swal {
                title: 'Delete request?'
                # text: 'Confirm delete?'
                type: 'error'
                animation: false
                showCancelButton: true
                closeOnConfirm: true
                cancelButtonText: 'Cancel'
                confirmButtonText: 'Delete'
                confirmButtonColor: '#da5347'
            }, =>
                Requests.remove FlowRouter.getParam('request_id'), ->
                    FlowRouter.go "/requests"



if Meteor.isServer
    Requests.allow
        insert: (userId, doc) -> 
            userId
            # Roles.userIsInRole(userId, 'admin')
        update: (userId, doc) -> 
            userId
            # Roles.userIsInRole(userId, 'admin')
        remove: (userId, doc) -> 
            userId
            # Roles.userIsInRole(userId, 'admin')
    
    
    
    Meteor.publish 'requests', ()->
        
        self = @
        match = {}
        
        Requests.find match,
            limit: 10
            sort: 
                timestamp: -1
    
    Meteor.publish 'request', (request_id)->
        Requests.find request_id

    
