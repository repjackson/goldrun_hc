if Meteor.isClient
    FlowRouter.route '/keys', action: ->
        BlazeLayout.render 'layout', 
            main: 'keys'
            
            
    FlowRouter.route '/key/edit/:key_id', action: ->
        BlazeLayout.render 'layout', 
            main: 'edit_key'
    
    
    
    
    Template.keys.onCreated ->
        @autorun -> Meteor.subscribe('keys')
    
    # Template.edit_key.onRendered ->
    #     Meteor.setTimeout (->
    #         $('select.dropdown').dropdown()
    #     ), 500

    Template.edit_key.onCreated ->
        @autorun -> Meteor.subscribe('key', FlowRouter.getParam('key_id'))
        @autorun -> Meteor.subscribe('buildings')
    
         
    Template.keys.helpers
        keys: -> 
            Keys.find {}
         
    Template.edit_key.helpers
        buildings: ->
            Buildings.find()
         
         
    Template.keys.events
        'click #add_key': ->
            id = Keys.insert {}
            FlowRouter.go "/key/edit/#{id}"
    
    Template.edit_key.helpers
        key: -> 
            key_id = FlowRouter.getParam('key_id')
            # console.log key_id
            Keys.findOne key_id 


    Template.tag_number.events
        'blur #tag_number': (e,t)->
            tag_number = parseInt $(e.currentTarget).closest('#tag_number').val()
            Keys.update @_id,
                $set: tag_number: tag_number
    
    
    Template.key_exists.helpers
        mark_true_class: -> if @key_exists then 'green' else 'basic'
        mark_false_class: -> if @key_exists then 'basic' else 'red'

    Template.key_exists.events
        'click #mark_true': (e,t)->
            Keys.update @_id,
                $set: key_exists: true
        'click #mark_false': (e,t)->
            Keys.update @_id,
                $set: key_exists: false
    
    Template.notes.events
        'blur #notes': (e,t)->
            notes =  $(e.currentTarget).closest('#notes').val()
            Keys.update @_id,
                $set: notes: notes

    Template.edit_key.events
        'click #delete_key': (e,t)->
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

        'change #select_lock_building': (e,t)->
            lock_building_code = e.currentTarget.value
            Keys.update @_id,
                $set: lock_building_code: lock_building_code

        'blur #lock_apartment_number': (e,t)->
            lock_apartment_number = $(e.currentTarget).closest('#lock_apartment_number').val()
            Keys.update @_id,
                $set: lock_apartment_number: lock_apartment_number



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

    
