if Meteor.isClient
    Template.home.onCreated ->
        @autorun -> Meteor.subscribe 'home_stats'
        @autorun -> Meteor.subscribe 'model_docs', 'ad'
        @autorun -> Meteor.subscribe 'model_docs', 'vote'
    Template.home.onRendered ->
        if Meteor.isProduction
            unless Meteor.userId() and 'ytjpFxiwnWaJELZEd' is Meteor.userId()
                Meteor.call 'log_home_view', ->





    Template.work_small.onCreated ->
        # @autorun -> Meteor.subscribe 'completed_work'
    Template.work_small.helpers
        work: ->
            Docs.find {
                model:'work'
                complete:true
            },
                sort: _timestamp: -1
                # limit:7



    Template.shop_small.onCreated ->
        # @autorun -> Meteor.subscribe 'model_docs', 'shop'
        @autorun -> Meteor.subscribe 'shop_docs', selected_shop_tags.array()
    Template.shop_small.helpers
        products: ->
            Docs.find {
                model:'shop'
            },
                sort: _timestamp: -1
                limit:5



    Template.stats_small.onCreated ->
        # @autorun -> Meteor.subscribe 'completed_work'
    Template.stats_small.events
        'click .calc_home_stats': ->
            Meteor.call 'calc_home_stats'
    Template.stats_small.helpers
        work: ->
            Docs.find {
                model:'work'
                complete:true
            },
                sort: _timestamp: -1
                limit:10


    Template.work_order_small.onCreated ->
        # @autorun -> Meteor.subscribe 'model_docs', 'work_order', 10
        @autorun => Meteor.subscribe 'docs', selected_tags.array(), 'work_order'
    Template.work_order_small.helpers
        work_order: ->
            Docs.find {
                model:'work_order'
            },
                sort: _timestamp: -1
                # limit:7


    Template.home.helpers
        hsd: ->
            Docs.findOne
                model:'home_stats'
        current_ad: ->
            Docs.findOne
                model:'ad'

        movie_options: ->
            Docs.findOne
                model:'movie_option'

        polls: ->
            Docs.find
                model:'vote'


    Template.home.events
        'click .submit_work_order': ->
            new_work_order_id = Docs.insert
                model:'work_order'
            Router.go "/work_order/#{new_work_order_id}/edit"

        'click .toggle_lights': ->
            # $('.global_container').transition('pulse')
            Session.set('dark_mode', !Session.get('dark_mode'))

        'click .toggle_display': ->
            # $('.global_container').transition('shake')
            Session.set('display_mode', !Session.get('display_mode'))

        'click .create_hsd': ->
            Docs.insert
                model:'home_stats'

        'click .happy': ->
            hsd = Docs.findOne
                model:'home_stats'
            Docs.update hsd._id,
                $inc: happy_votes: 1

        'click .unhappy': ->
            hsd = Docs.findOne
                model:'home_stats'
            Docs.update hsd._id,
                $inc: unhappy_votes: 1


    Template.service_slider.onRendered ->
        # Meteor.setTimeout (->
        #     $('#service_slider').layerSlider
        #         autoStart: true
        #     ), 3000
    Template.service_slider.onCreated ->
        @autorun -> Meteor.subscribe('model_docs', 'service')
    Template.service_slider.helpers
        slides: ->
            Docs.find
                model: 'service'



    Template.event_slider.onRendered ->
        # Meteor.setTimeout (->
        #     $('#event_slider').layerSlider
        #         autoStart: true
        #     ), 3000
    Template.event_slider.onCreated ->
        @autorun -> Meteor.subscribe('model_docs', 'event')
    Template.event_slider.helpers
        slides: ->
            Docs.find
                model: 'event'





if Meteor.isServer
    Meteor.methods
        calc_home_stats: ->
            hsd = Docs.findOne(model:'home_stats')
            current_hc_members =
                Docs.find(
                    model:'healthclub_session'
                    active:true
                ).count()
            console.log current_hc_members
            total_hc_sessions =
                Docs.find(
                    model:'healthclub_session'
                ).count()
            console.log total_hc_sessions

            registered_owners =
                Meteor.users.find(
                    roles:$in:['owner']
                ).count()
            console.log registered_owners

            registered_residents =
                Meteor.users.find(
                    roles:$in:['resident']
                ).count()
            console.log registered_residents

            Docs.update hsd._id,
                $set:
                    registered_owners:registered_owners
                    registered_residents:registered_residents
                    total_hc_sessions:total_hc_sessions
                    current_hc_members:current_hc_members



        log_home_view: ->
            hsd = Docs.findOne(model:'home_stats')
            console.log 'logging home view'
            Docs.update hsd._id,
                $inc:home_views:1





    Meteor.publish 'completed_work', ->
        Docs.find {
            model:'work'
            complete:true
        },
            sort: _timestamp: -1
            limit:10


    Meteor.publish 'home_stats', ->
        Docs.find model:'home_stats'
