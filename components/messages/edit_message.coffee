FlowRouter.route '/messages/edit/:message_id', action: (params) ->
    BlazeLayout.render 'layout',
        main: 'edit_message'


if Meteor.isClient
    Template.edit_message.onCreated ->
        @autorun -> Meteor.subscribe 'usernames'
        @autorun -> Meteor.subscribe 'message', FlowRouter.getParam('message_id')

    
    Template.edit_message.helpers
        settings: -> {
            position: 'bottom'
            limit: 10
            rules: [
                {
                    collection: Meteor.users
                    field: 'username'
                    matchAll: true
                    template: Template.user_result
                }
            ]
        }

        message: ->
            Messages.findOne FlowRouter.getParam('message_id')
    
    Template.edit_message.events
        'click #send_message': ->
            # Meteor.call 'send_message', 
            
            
        'autocompleteselect #add_recipient': (event, template, doc) ->
            # console.log 'selected ', doc
            Messages.update FlowRouter.getParam('message_id'),
                $addToSet: recipients: doc
            $('#add_recipient').val('')

        'click .recipient': ->
            Messages.update FlowRouter.getParam('message_id'),
                $pull: 
                    recipients: @
        
    
        'blur #text': ->
            text = $('#text').val()
            console.log text
            Messages.update FlowRouter.getParam('message_id'),
                $set: text: text
        
            
    
    
        'click #delete_message': ->
            swal {
                title: 'Delete Message?'
                # text: 'Confirm delete?'
                type: 'error'
                animation: false
                showCancelButton: true
                closeOnConfirm: true
                cancelButtonText: 'Cancel'
                confirmButtonText: 'Delete'
                confirmButtonColor: '#da5347'
            }, ->
                message = Messages.findOne FlowRouter.getParam('message_id')
                Messages.remove message._id, ->
                    FlowRouter.go "/messages"

            
            
if Meteor.isServer
    Meteor.publish 'usernames', ->
        Meteor.users.find {},
            fields:
                "profile.name": 1
                
                
    # Meteor.publish 'message', (id)->
    #     Messages.find id