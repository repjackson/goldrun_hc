# Router.route '/tasks', -> @render 'tasks'
Router.route '/work_orders/', -> @render 'work_orders'
Router.route '/work_order/:doc_id/view', -> @render 'work_order_view'
Router.route '/work_order/:doc_id/edit', -> @render 'work_order_edit'


if Meteor.isClient
    Template.work_orders.onCreated ->
        @autorun => Meteor.subscribe 'docs', selected_tags.array(), 'work_order'
        @autorun -> Meteor.subscribe 'model_docs', 'work_order'

    Template.work_order_view.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
    Template.work_order_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
    Template.work_orders.helpers
        work_orders: ->
            Docs.find
                model:'work_order'
    Template.work_orders.events
        'click .add_work_order': ->
            new_id = Docs.insert
                model:'work_order'
            Router.go "/work_order/#{new_id}/edit"




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
