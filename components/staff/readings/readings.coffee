if Meteor.isClient
    Template.readings.onRendered ->
        Meteor.setTimeout (->
            $('table').tablesort()
        ), 500

    Template.readings.onCreated ->
        @autorun -> Meteor.subscribe('readings')

    Template.edit_reading.onCreated ->
        @autorun -> Meteor.subscribe('doc', Router.getParam('doc_id'))

    Template.readings.helpers
        readings: ->
            Docs.find
                type: 'reading'
                location: Template.currentData().location

        readings_label: ->
            switch Template.currentData().location
                when 'outdoor_hot_tub' then 'Outdoor Hot Tub'
                when 'indoor_hot_tub' then 'Indoor Hot Tub'
                when 'pool' then 'Pool'


    Template.readings.events
        'click #add_reading': ->
            id = Docs.insert
                type: 'reading'
                location: Template.currentData().location
            Router.go "/reading/edit/#{id}"




    Template.edit_reading.helpers
        reading: ->
            doc_id = Router.getParam('doc_id')
            # console.log doc_id
            Docs.findOne doc_id


    Template.ph.events
        'blur #ph': (e,t)->
            ph = parseFloat $(e.currentTarget).closest('#ph').val()
            Docs.update @_id,
                $set: ph: ph

    Template.chlorine.events
        'blur #chlorine': (e,t)->
            chlorine = parseFloat $(e.currentTarget).closest('#chlorine').val()
            Docs.update @_id,
                $set: chlorine: chlorine

    Template.temperature.events
        'blur #temperature': (e,t)->
            temperature = parseFloat $(e.currentTarget).closest('#temperature').val()
            Docs.update @_id,
                $set: temperature: temperature

    Template.br.events
        'blur #br': (e,t)->
            br = parseFloat $(e.currentTarget).closest('#br').val()
            Docs.update @_id,
                $set: br: br

    Template.alkalinity.events
        'blur #alkalinity': (e,t)->
            alkalinity = parseFloat $(e.currentTarget).closest('#alkalinity').val()
            Docs.update @_id,
                $set: alkalinity: alkalinity


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
                Docs.remove Router.getParam('doc_id'), ->
                    Router.go "/readings"







if Meteor.isServer
    Meteor.publish 'readings', ()->

        self = @
        match = {}
        # if not @userId or not Roles.userIsInRole(@userId, ['admin'])
        #     match.published = true
        type = 'reading'

        Docs.find match,
            limit: 10
            sort:
                timestamp: -1
