if Meteor.isClient
    Template.home.onCreated ->
        @autorun => Meteor.subscribe 'role_models', Router.current().params.doc_id
        # @autorun => Meteor.subscribe 'model_fields_from_child_id', Router.current().params.doc_id

    Template.home.events
        'click .set_model': ->
            Session.set 'loading', true
            Meteor.call 'set_facets', @slug, ->
                Session.set 'loading', false

    Template.home.helpers
        role_models: ->
            Docs.find
                model:'model'
                view_roles:$in:Meteor.user().roles

if Meteor.isServer
    Meteor.publish 'role_models', ()->
        Docs.find
            model:'model'
            view_roles:$in:Meteor.user().roles

    Meteor.publish 'model_from_child_id', (child_id)->
        child = Docs.findOne child_id
        Docs.find
            model:'model'
            slug:child.type


    Meteor.publish 'model_fields_from_child_id', (child_id)->
        child = Docs.findOne child_id
        model = Docs.findOne
            model:'model'
            slug:child.type
        Docs.find
            model:'field'
            parent_id:model._id
