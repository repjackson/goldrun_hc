if Meteor.isClient
    Template.work_small.onCreated ->
        @autorun -> Meteor.subscribe 'completed_work'
    Template.work_small.helpers
        work: ->
            Docs.find {
                model:'work'
                complete:true
            },
                sort: _timestamp: -1
                limit:10


    Template.work_order_small.onCreated ->
        @autorun -> Meteor.subscribe 'model_docs', 'work_order', 10
    Template.work_order_small.helpers
        work_order: ->
            Docs.find {
                model:'work_order'
            },
                sort: _timestamp: -1
                limit:10


    Template.home.events
        'click .submit_work_order': ->
            new_work_order_id = Docs.insert
                model:'work_order'
            Router.go "/work_order/#{new_work_order_id}/edit"

if Meteor.isServer
    Meteor.publish 'completed_work', ->
        Docs.find {
            model:'work'
            complete:true
        },
            sort: _timestamp: -1
            limit:10
