if Meteor.isClient
    Template.grid.onCreated ->
        # @autorun => Meteor.subscribe 'role_models', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'docs', selected_tags.array(), 'model'
        # @autorun => Meteor.subscribe 'role_models'
        # @autorun => Meteor.subscribe 'model_docs', 'marketplace'
        # @autorun => Meteor.subscribe 'model_docs', 'post'
        # @autorun => Meteor.subscribe 'model_fields_from_child_id', Router.current().params.doc_id
        Session.set 'model_filter',null

    Template.grid.events
        'click .set_model': ->
            Session.set 'loading', true
            if Meteor.user()
                Docs.update @_id,
                    $inc: views: 1
                    $addToSet:viewer_usernames:Meteor.user().username
            else
                Docs.update @_id,
                    $inc: views: 1

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
            match = {model:'model'}
            if selected_tags.array().length > 0
                match.tags = $in:selected_tags.array()
            model_filter = Session.get('model_filter')
            if model_filter
                match.title = {$regex:"#{model_filter}", $options: 'i'}
            unless Meteor.user() and Meteor.user().roles and 'dev' in Meteor.user().roles
                match.view_roles = $in:Meteor.user().roles
            Docs.find match, sort:views:-1





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
