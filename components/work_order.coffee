Router.route '/work_orders', (->
    @render 'work_orders'
    ), name:'work_orders'
Router.route '/work_order/:doc_id/view', (->
    @render 'work_order_view'
    ), name:'work_order_view'
Router.route '/work_order/:doc_id/edit', (->
    @render 'work_order_edit'
    ), name:'work_order_edit'


if Meteor.isClient
    Template.work_orders.onCreated ->
        @autorun => Meteor.subscribe 'docs', selected_tags.array(), 'work_order'

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
