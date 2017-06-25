if Meteor.isClient
    FlowRouter.route '/readings', action: ->
        BlazeLayout.render 'layout', 
            main: 'readings'
            
            
    FlowRouter.route '/pool_reading/edit/:reading_id', action: ->
        BlazeLayout.render 'layout', 
            main: 'edit_pool_reading'
    
    
    FlowRouter.route '/hot_tub_reading/edit/:reading_id', action: ->
        BlazeLayout.render 'layout', 
            main: 'edit_hot_tub_reading'
    
    
    Template.readings.onRendered ->
        Meteor.setTimeout (->
            $('table').tablesort()
        ), 500    

    Template.readings.onCreated ->
        @autorun -> Meteor.subscribe('readings')
    Template.edit_pool_reading.onCreated ->
        @autorun -> Meteor.subscribe('reading', FlowRouter.getParam('reading_id'))
    Template.edit_hot_tub_reading.onCreated ->
        @autorun -> Meteor.subscribe('reading', FlowRouter.getParam('reading_id'))
    
    Template.indoor_hot_tub_readings.helpers
        indoor_hot_tub_readings: -> 
            Readings.find
                location: 'indoor'
                type: 'hot_tub'
         
    Template.outdoor_hot_tub_readings.helpers
        outdoor_hot_tub_readings: -> 
            Readings.find
                location: 'outdoor'
                type: 'hot_tub'
         
    Template.pool_readings.helpers
        pool_readings: -> 
            Readings.find 
                type: 'pool'
         
         
         
         
                
    Template.readings.events
        'click #add_pool_reading': ->
            id = Readings.insert
                type: 'pool'
            FlowRouter.go "/pool_reading/edit/#{id}"
    
        'click #add_outdoor_hot_tub_reading': ->
            id = Readings.insert
                type: 'hot_tub'
                location: 'outdoor'
            FlowRouter.go "/hot_tub_reading/edit/#{id}"
    
        'click #add_indoor_hot_tub_reading': ->
            id = Readings.insert
                type: 'hot_tub'
                location: 'indoor'
            FlowRouter.go "/hot_tub_reading/edit/#{id}"
    
    
    
    Template.edit_hot_tub_reading.helpers
        reading: -> 
            reading_id = FlowRouter.getParam('reading_id')
            # console.log reading_id
            Readings.findOne reading_id 

    Template.edit_pool_reading.helpers
        reading: -> 
            reading_id = FlowRouter.getParam('reading_id')
            # console.log reading_id
            Readings.findOne reading_id 


    Template.ph.events
        'blur #ph': (e,t)->
            ph = parseFloat $(e.currentTarget).closest('#ph').val()
            Readings.update @_id,
                $set: ph: ph
    
    Template.chlorine.events
        'blur #chlorine': (e,t)->
            chlorine = parseFloat $(e.currentTarget).closest('#chlorine').val()
            Readings.update @_id,
                $set: chlorine: chlorine
    
    Template.temperature.events
        'blur #temperature': (e,t)->
            temperature = parseFloat $(e.currentTarget).closest('#temperature').val()
            Readings.update @_id,
                $set: temperature: temperature
    
    Template.br.events
        'blur #br': (e,t)->
            br = parseFloat $(e.currentTarget).closest('#br').val()
            Readings.update @_id,
                $set: br: br
    
    Template.alkalinity.events
        'blur #alkalinity': (e,t)->
            alkalinity = parseFloat $(e.currentTarget).closest('#alkalinity').val()
            Readings.update @_id,
                $set: alkalinity: alkalinity
    
    Template.notes.events
        'blur #notes': (e,t)->
            notes =  $(e.currentTarget).closest('#notes').val()
            Readings.update @_id,
                $set: notes: notes

    Template.delete_reading_button.events
        'click #delete_reading': (e,t)->
            swal {
                title: 'Delete Reading?'
                # text: 'Confirm delete?'
                type: 'error'
                animation: false
                showCancelButton: true
                closeOnConfirm: true
                cancelButtonText: 'Cancel'
                confirmButtonText: 'Delete'
                confirmButtonColor: '#da5347'
            }, ->
                Readings.remove FlowRouter.getParam('reading_id'), ->
                    FlowRouter.go "/readings"







if Meteor.isServer
    Readings.allow
        insert: (userId, doc) -> doc.author_id is userId
        update: (userId, doc) -> doc.author_id is userId or Roles.userIsInRole(userId, 'admin')
        remove: (userId, doc) -> doc.author_id is userId or Roles.userIsInRole(userId, 'admin')
    
    Meteor.publish 'readings', ()->
        
        self = @
        match = {}
        # if not @userId or not Roles.userIsInRole(@userId, ['admin'])
        #     match.published = true
        
        Readings.find match,
            limit: 10
            sort: 
                timestamp: -1
    
    Meteor.publish 'reading', (reading_id)->
        Readings.find reading_id

    
