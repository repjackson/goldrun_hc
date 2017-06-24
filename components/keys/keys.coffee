if Meteor.isClient
    FlowRouter.route '/keys', action: ->
        BlazeLayout.render 'layout', 
            main: 'keys'
            
            
    FlowRouter.route '/key/edit/:key_id', action: ->
        BlazeLayout.render 'layout', 
            main: 'edit_key'
    
    
    
    
    Template.keys.onCreated ->
        @autorun -> Meteor.subscribe('keys')
    
    Template.edit_key.onCreated ->
        @autorun -> Meteor.subscribe('key', FlowRouter.getParam('key_id'))
    
         
    Template.keys.helpers
        keys: -> 
            Keys.find {}
         
         
         
         
    Template.keys.events
        'click #add_key': ->
            id = Keys.insert {}
            FlowRouter.go "/key/edit/#{id}"
    
    Template.edit_key.helpers
        key: -> 
            key_id = FlowRouter.getParam('key_id')
            # console.log key_id
            Keys.findOne key_id 


    Template.lock_location.events
        'blur #lock_location': (e,t)->
            lock_location = parseFloat $(e.currentTarget).closest('#lock_location').val()
            Keys.update @_id,
                $set: lock_location: lock_location
    
    Template.tag_number.events
        'blur #tag_number': (e,t)->
            tag_number = parseInt $(e.currentTarget).closest('#tag_number').val()
            Keys.update @_id,
                $set: tag_number: tag_number
    
    Template.building_code.events
        'blur #building_code': (e,t)->
            building_code = $(e.currentTarget).closest('#building_code').val()
            Keys.update @_id,
                $set: building_code: building_code
    
    Template.key_exists.events
        'blur #key_exists': (e,t)->
            key_exists = $(e.currentTarget).closest('#key_exists').val()
            Keys.update @_id,
                $set: key_exists: key_exists
    
    Template.notes.events
        'blur #notes': (e,t)->
            notes =  $(e.currentTarget).closest('#notes').val()
            Keys.update @_id,
                $set: notes: notes

    Template.delete_key_button.events
        'click #delete_reading': (e,t)->
            swal {
                title: 'Delete Key?'
                text: 'Cannot be undone.'
                type: 'error'
                animation: false
                showCancelButton: true
                closeOnConfirm: true
                cancelButtonText: 'Cancel'
                confirmButtonText: 'Delete'
                confirmButtonColor: '#da5347'
            }, ->
                Keys.remove FlowRouter.getParam('key_id'), ->
                    FlowRouter.go "/keys"







if Meteor.isServer
    Keys.allow
        insert: (userId, doc) -> Roles.userIsInRole(userId, 'admin')
        update: (userId, doc) -> Roles.userIsInRole(userId, 'admin')
        remove: (userId, doc) -> Roles.userIsInRole(userId, 'admin')
    
    Meteor.publish 'keys', ()->
        
        self = @
        match = {}
        # if not @userId or not Roles.userIsInRole(@userId, ['admin'])
        #     match.published = true
        
        Keys.find match,
            limit: 10
            sort: 
                tag_number: -1
    
    Meteor.publish 'key', (key_id)->
        Keys.find key_id

    
