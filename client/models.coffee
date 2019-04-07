if Meteor.isClient
    Router.route '/models', -> @render 'models'


    Router.route '/model/edit/:doc_id', -> @render 'edit_model'


    # Template.model.onRendered ->
    #     Meteor.setTimeout (->
    #         $('.shape').shape()
    #     ), 500


    Template.models.onCreated ->
        @autorun -> Meteor.subscribe 'docs', selected_tags.array(), 'model'

    Template.models.onRendered ->
        # Meteor.setTimeout (->
        #     $('table').tablesort()
        #     # $('select.dropdown').dropdown()
        # ), 500



    Template.edit_model.onCreated ->
        @autorun -> Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun -> Meteor.subscribe 'docs', [], 'building'


    Template.models.helpers
        models: -> Docs.find { type: 'model' }

    Template.edit_model.helpers
        buildings: ->
            Docs.find type: 'building'

        building_numbers: ->
            # console.log @
            building = Docs.findOne
                building_code: @lock_building_code
                type: 'building'
            # console.log building
            if building then building.building_numbers


    Template.models.events
        'click #add_model': ->
            # alert 'hi'
            id = Docs.insert type:'model'
            Router.go "/model/edit/#{id}"

    Template.model.events
        'click .flip_shape': (e,t)->
            $(e.currentTarget).closest('.shape').shape('flip over');
            # console.log $(e.currentTarget).closest('.shape').shape('flip up')
            # $('.shape').shape('flip up')


    Template.edit_model.helpers
        model: ->
            doc_id = Router.current().params.doc_id
            # console.log doc_id
            Docs.findOne doc_id



    Template.edit_model.events
        'click #delete_model': (e,t)->
            swal {
                title: 'Delete model?'
                text: 'Cannot be undone.'
                type: 'error'
                animation: false
                showCancelButton: true
                closeOnConfirm: true
                cancelButtonText: 'Cancel'
                confirmButtonText: 'Delete'
                confirmButtonColor: '#da5347'
            }, ->
                Docs.remove Router.current().params.doc_id, ->
                    Router.go "/models"

        'blur #description': (e,t)->
            description = $(e.currentTarget).closest('#description').val()
            Docs.update @_id,
                $set: description: description

        'blur #complete_date': (e,t)->
            complete_date = $(e.currentTarget).closest('#complete_date').val()
            Docs.update @_id,
                $set: complete_date: complete_date

        'blur #location': (e,t)->
            location = $(e.currentTarget).closest('#location').val()
            Docs.update @_id,
                $set: location: location
