if Meteor.isClient
    Template.front.onCreated ->
        # @autorun => Meteor.subscribe 'role_models', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'role_models', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'model_docs', 'marketplace'
        @autorun => Meteor.subscribe 'model_docs', 'gr_post'
        @autorun => Meteor.subscribe 'model_docs', 'gr_post'
        # @autorun => Meteor.subscribe 'model_fields_from_child_id', Router.current().params.doc_id

    Template.front.events
        'click .set_model': ->
            Session.set 'loading', true
            Meteor.call 'set_facets', @slug, ->
                Session.set 'loading', false

    Template.front.helpers
        role_models: ->
            # console.log Meteor.user().roles
            Docs.find {
                model:'model'
                view_roles:$in:Meteor.user().roles
            }, sort:title:1

        marketplace_items: ->
            # console.log Meteor.user().roles
            Docs.find {
                model:'marketplace'
            }, sort:_timestamp:1

        posts: ->
            # console.log Meteor.user().roles
            Docs.find {
                model:'gr_post'
            }, sort:_timestamp:1


    Template.slideshow.onCreated ->
        @autorun => Meteor.subscribe 'model_docs', 'photo'

    Template.slideshow.helpers
        current_photo: ->
            Docs.findOne
                model:'photo'


if Meteor.isServer
    Meteor.publish 'role_models', ()->
        Docs.find
            model:'model'
            view_roles:$in:Meteor.user().roles
