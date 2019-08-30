if Meteor.isClient
    Template.grid.onCreated ->
        # @autorun => Meteor.subscribe 'role_models', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'role_models', Router.current().params.doc_id
        # @autorun => Meteor.subscribe 'model_docs', 'marketplace'
        # @autorun => Meteor.subscribe 'model_docs', 'post'
        # @autorun => Meteor.subscribe 'model_fields_from_child_id', Router.current().params.doc_id
        Session.set 'model_filter',null

    Template.grid.events
        'click .set_model': ->
            Session.set 'loading', true
            Meteor.call 'set_facets', @slug, ->
                Session.set 'loading', false



        'keyup .model_filter': (e,t)->
            model_filter = $('.model_filter').val()
            if e.which is 8
                if model_filter.length is 0
                    Session.set 'model_filter',null
                else
                    Session.set 'model_filter',model_filter
            else
                Session.set 'model_filter',model_filter


        'mouseenter .home_segment': (e,t)->
            t.$(e.currentTarget).closest('.home_segment').addClass('raised')
        'mouseleave .home_segment': (e,t)->
            t.$(e.currentTarget).closest('.home_segment').removeClass('raised')

    Template.grid.helpers
        role_models: ->
            model_filter = Session.get('model_filter')
            if 'dev' in Meteor.user().roles
                if model_filter
                    Docs.find {
                        model:'model'
                        title: {$regex:"#{model_filter}", $options: 'i'}
                    }, sort:title:1
                else
                    Docs.find {
                        model:'model'
                    }, sort:title:1
            else
                if model_filter
                    Docs.find {
                        title: {$regex:"#{model_filter}", $options: 'i'}
                        model:'model'
                        view_roles:$in:Meteor.user().roles
                    }, sort:title:1
                else
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
                model:'post'
            }, sort:_timestamp:1



if Meteor.isServer
    Meteor.publish 'role_models', ()->
        if 'dev' in Meteor.user().roles
            Docs.find
                model:'model'
        else
            Docs.find
                model:'model'
                view_roles:$in:Meteor.user().roles
