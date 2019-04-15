if Meteor.isClient
    Template.model_edit.onCreated ->
        @autorun -> Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun -> Meteor.subscribe 'fields_from_doc_id', Router.current().params.model_slug, Router.current().params.doc_id
        @autorun -> Meteor.subscribe 'model_from_doc_id', Router.current().params.model_slug, Router.current().params.doc_id


    Template.model_view.onCreated ->
        @autorun -> Meteor.subscribe 'model_from_doc_id', Router.current().params.model_slug, Router.current().params.doc_id
        @autorun -> Meteor.subscribe 'fields_from_doc_id', Router.current().params.model_slug, Router.current().params.doc_id
        @autorun -> Meteor.subscribe 'doc', Router.current().params.doc_id

    Template.model_edit.events
        'click .delete_model': ->
            if confirm 'Confirm delete model'
                Docs.remove @_id
                Router.go '/models'


    Template.model_doc_edit.onCreated ->
        @autorun -> Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun -> Meteor.subscribe 'fields_from_doc_id', Router.current().params.doc_id
        @autorun -> Meteor.subscribe 'model_from_doc_id', Router.current().params.model_slug, Router.current().params.doc_id


    Template.model_doc_view.onCreated ->
        @autorun -> Meteor.subscribe 'model_from_doc_id', Router.current().params.model_slug, Router.current().params.doc_id
        @autorun -> Meteor.subscribe 'fields_from_doc_id', Router.current().params.doc_id
        console.log Router.current().params.doc_id
        @autorun -> Meteor.subscribe 'doc', Router.current().params.doc_id



if Meteor.isServer
    Meteor.publish 'fields_from_doc_id', (doc_id)->
        console.log 'doc_id', doc_id
        doc = Docs.findOne doc_id
        # console.log 'doc', doc
        model =
            Docs.findOne
                model:'model'
                slug:doc.model
        # console.log "MODEL", model

        Docs.find(
                model:'field'
                parent_id:model._id
            )
