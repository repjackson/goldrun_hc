if Meteor.isClient
    Template.type_edit.onCreated ->
        @autorun -> Meteor.subscribe 'doc', Router.current().params._id, Router.current().params.type
        @autorun -> Meteor.subscribe 'bricks_from_doc_id', Router.current().params.type, Router.current().params._id
        @autorun -> Meteor.subscribe 'model_from_doc_id', Router.current().params.type, Router.current().params._id


    Template.type_view.onCreated ->
        @autorun -> Meteor.subscribe 'model_from_doc_id', Router.current().params.type, Router.current().params._id
        @autorun -> Meteor.subscribe 'bricks_from_doc_id', Router.current().params.type, Router.current().params._id
        @autorun -> Meteor.subscribe 'doc', Router.current().params._id, Router.current().params.type

    Template.type_edit.events
        'click .delete_model': ->
            if confirm 'Confirm delete model'
                Docs.remove @_id
                Router.go '/models'
