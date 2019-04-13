if Meteor.isClient
    Router.route '/models', -> @render 'models'
    Router.route '/model/edit/:doc_id', -> @render 'edit_model'
    Router.route '/m/:model_slug', -> @render 'view_model'


    # Template.model.onRendered ->
    #     Meteor.setTimeout (->
    #         $('.shape').shape()
    #     ), 500


    Template.models.onCreated ->
        @autorun -> Meteor.subscribe 'docs', selected_tags.array(), 'model'

    Template.models.onRendered ->

    Template.view_model.onCreated ->
        @autorun -> Meteor.subscribe 'model', Router.current().params.model_slug
        @autorun -> Meteor.subscribe 'model_fields', Router.current().params.model_slug

    Template.view_model.helpers
        model: ->
            Docs.findOne
                type:'model'
                slug: Router.current().params.model_slug

        fields: ->
            Docs.find
                type:'field'
                # parent_id: Router.current().params.doc_id

    Template.view_model.events
        'click .add_child': ->
            new_id = Docs.insert
                type: Router.current().params.model_slug
            Router.go "/edit/#{new_id}"

    Template.edit_model.onCreated ->
        @autorun -> Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun -> Meteor.subscribe 'child_docs', Router.current().params.doc_id


    Template.models.helpers
        models: -> Docs.find { type: 'model' }

    Template.edit_model.helpers


    Template.models.events
        'click #add_model': ->
            # alert 'hi'
            id = Docs.insert type:'model'
            Router.go "/model/edit/#{id}"



    Template.edit_model.helpers
        model: ->
            doc_id = Router.current().params.doc_id
            # console.log doc_id
            Docs.findOne doc_id

        fields: ->
            Docs.find
                type:'field'
                parent_id: Router.current().params.doc_id

    Template.edit_model.events
        'click #delete_model': (e,t)->
            if confirm 'delete model?'
                Docs.remove Router.current().params.doc_id, ->
                    Router.go "/models"

        'click .add_field': ->
            Docs.insert
                type:'field'
                parent_id: Router.current().params.doc_id

if Meteor.isServer
    Meteor.publish 'model', (slug)->
        Docs.find
            type:'model'
            slug:slug

    Meteor.publish 'model_fields', (slug)->
        model = Docs.findOne
            type:'model'
            slug:slug
        Docs.find
            type:'field'
            parent_id:model._id