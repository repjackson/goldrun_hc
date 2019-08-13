Router.route '/readings',-> @render 'readings'
Router.route '/readings/lower', -> @render 'lower_hot_tub_readings'
Router.route '/readings/upper', -> @render 'upper_hot_tub_readings'
Router.route '/readings/pool', -> @render 'pool_readings'
Router.route '/pool_reading/edit/:doc_id', -> @render 'edit_pool_reading'
Router.route '/lower_hot_tub_reading/edit/:doc_id', -> @render 'edit_hot_tub_reading'
Router.route '/upper_hot_tub_reading/edit/:doc_id', -> @render 'edit_hot_tub_reading'


if Meteor.isClient
    Template.readings.onRendered ->
        Meteor.setTimeout (->
            $('table').tablesort()
        ), 500

    Template.readings.onCreated ->
        @autorun -> Meteor.subscribe('lower_hot_tub_readings')
        @autorun -> Meteor.subscribe('upper_hot_tub_readings')
        @autorun -> Meteor.subscribe('pool_readings')
    Template.lower_hot_tub_readings.onCreated ->
        @autorun -> Meteor.subscribe('lower_hot_tub_readings')
    Template.upper_hot_tub_readings.onCreated ->
        @autorun -> Meteor.subscribe('upper_hot_tub_readings')
    Template.pool_readings.onCreated ->
        @autorun -> Meteor.subscribe('pool_readings')
    Template.edit_pool_reading.onCreated ->
        @autorun -> Meteor.subscribe('doc', Router.current().params.doc_id)
    Template.edit_lower_hot_tub_reading.onCreated ->
        @autorun -> Meteor.subscribe('doc', Router.current().params.doc_id)
    Template.edit_upper_hot_tub_reading.onCreated ->
        @autorun -> Meteor.subscribe('doc', Router.current().params.doc_id)

    Template.lower_hot_tub_readings.helpers
        lower_hot_tub_readings: ->
            Docs.find
                model:'lower_hot_tub_reading'

    Template.upper_hot_tub_readings.helpers
        upper_hot_tub_readings: ->
            Docs.find
                model:'upper_hot_tub_reading'

    Template.pool_readings.helpers
        pool_readings: ->
            Docs.find
                model: 'pool_reading'

    Template.readings.events
        'click #add_pool_reading': ->
            id = Docs.insert
                model: 'pool_reading'
            Router.go "/pool_reading/edit/#{id}"

        'click #add_upper_hot_tub_reading': ->
            id = Docs.insert
                model: 'upper_hot_tub_reading'
            Router.go "/upper_hot_tub_reading/edit/#{id}"

        'click #add_lower_hot_tub_reading': ->
            id = Docs.insert
                model: 'lower_hot_tub_reading'
            Router.go "/lower_hot_tub_reading/edit/#{id}"



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
                model: 'error'
                animation: false
                showCancelButton: true
                closeOnConfirm: true
                cancelButtonText: 'Cancel'
                confirmButtonText: 'Delete'
                confirmButtonColor: '#da5347'
            }, ->
                Docs.remove Router.current().params.doc_id, ->
                    Router.go "/readings"







if Meteor.isServer
    Meteor.publish 'upper_hot_tub_readings', ()->
        self = @
        match = {}
        Docs.find {model:'upper_hot_tub_reading'},
            limit: 10
            sort:
                timestamp: -1

    Meteor.publish 'lower_hot_tub_readings', ()->
        self = @
        match = {}
        Docs.find {model:'lower_hot_tub_reading'},
            limit: 10
            sort:
                timestamp: -1

    Meteor.publish 'pool_readings', ()->
        self = @
        match = {}
        Docs.find {model:'pool_reading'},
            limit: 10
            sort:
                timestamp: -1
