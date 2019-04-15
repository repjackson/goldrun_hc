if Meteor.isClient
    Template.type_edit.onCreated ->
        @autorun -> Meteor.subscribe 'doc', Router.current().params.doc_id, Router.current().params.model_slug
        @autorun -> Meteor.subscribe 'bricks_from_doc_id', Router.current().params.model_slug, Router.current().params.doc_id
        @autorun -> Meteor.subscribe 'model_from_doc_id', Router.current().params.model_slug, Router.current().params.doc_id


    Template.model_view.onCreated ->
        @autorun -> Meteor.subscribe 'model_from_doc_id', Router.current().params.model_slug, Router.current().params.doc_id
        @autorun -> Meteor.subscribe 'bricks_from_doc_id', Router.current().params.model_slug, Router.current().params.doc_id
        @autorun -> Meteor.subscribe 'doc', Router.current().params.doc_id, Router.current().params.model_slug

    Template.type_edit.events
        'click .delete_model': ->
            if confirm 'Confirm delete model'
                Docs.remove @_id
                Router.go '/models'
