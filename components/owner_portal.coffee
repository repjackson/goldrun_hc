if Meteor.isClient
    Router.route '/owner_portal', -> @render 'owner_portal'

    Template.owner_portal.onCreated ->
        @autorun -> Meteor.subscribe 'model_docs', 'work_order'
    Template.my_unit_work_orders.helpers
        my_unit_work_orders: ->
            Docs.find {model:'work_order'},
                sort: _timestamp: -1
                limit:10
    Template.all_work_orders.helpers
        all_work_orders: ->
            Docs.find {model:'work_order'},
                sort: _timestamp: -1
                limit:10
    Template.my_building_work_orders.helpers
        my_building_work_orders: ->
            Docs.find {model:'work_order'},
                sort: _timestamp: -1
                limit:10
    Template.owner_portal.events
        'click .add_work_order': (e,t)->
            new_id = Docs.insert
                model:'work_order'
            Router.go "/work_order/#{new_id}/edit"



# if Meteor.isServer
    # Meteor.publish 'published_residents', ->
    #     Meteor.users.find
    #         roles:$in:['resident']
    #         profile_published:true
    #
    # Meteor.publish 'most_viewed_models', ->
    #     Docs.find {model:'model'},
    #         sort:views:-1
    #         limit:10
    #
    # Meteor.publish 'karma_leaderboard', ->
    #     Meteor.users.find {},
    #         sort:points:-1
    #         limit:10
