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
            # console.log Meteor.user().roles
            Docs.find {
                model:'model'
                view_roles:$in:Meteor.user().roles
            }, sort:title:1



if Meteor.isServer
    Meteor.publish 'role_models', ()->
        Docs.find
            model:'model'
            view_roles:$in:Meteor.user().roles
