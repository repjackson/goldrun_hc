if Meteor.isClient
    Template.home.onCreated ->
        @autorun -> Meteor.subscribe 'home_stats'
        @autorun -> Meteor.subscribe 'model_docs', 'ad'

    Template.work_small.onCreated ->
        # @autorun -> Meteor.subscribe 'completed_work'

    Template.work_small.helpers
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
                limit:10


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




    Template.home.events
        'click .submit_work_order': ->
            new_work_order_id = Docs.insert
                model:'work_order'
            Router.go "/work_order/#{new_work_order_id}/edit"

        'click .toggle_lights': ->
            $('.global_container').transition('jiggle')
            Session.set('dark_mode', !Session.get('dark_mode'))

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



if Meteor.isServer
    Meteor.methods
        calc_home_stats: ->
            hsd = Docs.findOne(model:'home_stats')
            Meteor.call 'calc_home_stats'



    Meteor.publish 'completed_work', ->
        Docs.find {
            model:'work'
            complete:true
        },
            sort: _timestamp: -1
            limit:10


    Meteor.publish 'home_stats', ->
        Docs.find model:'home_stats'
