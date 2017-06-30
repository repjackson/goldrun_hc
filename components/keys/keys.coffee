if Meteor.isClient
    FlowRouter.route '/keys', action: ->
        BlazeLayout.render 'layout', 
            main: 'keys'
            
            
    FlowRouter.route '/key/edit/:doc_id', action: ->
        BlazeLayout.render 'layout', 
            main: 'edit_key'
    
    
    
    
    Template.keys.onCreated ->
        @autorun -> Meteor.subscribe('keys')
    
    # Template.edit_key.onRendered ->
    #     Meteor.setTimeout (->
    #         $('select.dropdown').dropdown()
    #     ), 500

    Template.keys.onRendered ->
        Meteor.setTimeout (->
            $('table').tablesort()
            # $('select.dropdown').dropdown()
        ), 500



    Template.edit_key.onCreated ->
        @autorun -> Meteor.subscribe('doc', FlowRouter.getParam('doc_id'))
        @autorun -> Meteor.subscribe('buildings')
    
         
    Template.keys.helpers
        keys: -> 
            Docs.find {type: 'key'},
                sort: tag_number: 1
         
    Template.edit_key.helpers
        buildings: ->
            Buildings.find()
         
        building_numbers: ->
            # console.log @
            building = Buildings.findOne building_code: @lock_building_code
            # console.log building
            if building then building.building_numbers

    Template.keys.events
        'click #add_key': ->
            id = Docs.insert type: 'key'
            FlowRouter.go "/key/edit/#{id}"
    
    Template.edit_key.helpers
        key: -> 
            doc_id = FlowRouter.getParam('doc_id')
            # console.log doc_id
            Docs.findOne doc_id 


    Template.tag_number.events
        'blur #tag_number': (e,t)->
            tag_number = parseInt $(e.currentTarget).closest('#tag_number').val()
            Docs.update @_id,
                $set: tag_number: tag_number
    
    
    Template.key_exists.helpers
        mark_true_class: -> if @key_exists then 'green' else 'basic'
        mark_false_class: -> if @key_exists then 'basic' else 'red'

    Template.key_exists.events
        'click #mark_true': (e,t)->
            Docs.update @_id,
                $set: key_exists: true
        'click #mark_false': (e,t)->
            Docs.update @_id,
                $set: key_exists: false
    

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
                Docs.remove FlowRouter.getParam('doc_id'), ->
                    FlowRouter.go "/keys"

        'change #select_lock_building_number': (e,t)->
            lock_building_number = e.currentTarget.value
            Docs.update @_id,
                $set: lock_building_number: lock_building_number

        'blur #lock_apartment_number': (e,t)->
            lock_apartment_number = $(e.currentTarget).closest('#lock_apartment_number').val()
            Docs.update @_id,
                $set: lock_apartment_number: lock_apartment_number

        'blur #lock_building_number': (e,t)->
            lock_building_number = $(e.currentTarget).closest('#lock_building_number').val()
            Docs.update @_id,
                $set: lock_building_number: lock_building_number



if Meteor.isServer
    Meteor.publish 'keys', ()->
        
        self = @
        match = {}
        # if not @userId or not Roles.userIsInRole(@userId, ['admin'])
        #     match.published = true
        
        Docs.find match,
            limit: 10
            sort: 
                tag_number: -1
    