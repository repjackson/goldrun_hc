Router.route '/requests', (->
    @render 'requests'
    ), name:'requests'
Router.route '/request/:doc_id/view', (->
    @render 'request_view'
    ), name:'request_view'
Router.route '/request/:doc_id/edit', (->
    @render 'request_edit'
    ), name:'request_edit'


if Meteor.isClient
    Template.requests.onCreated ->
        @autorun => Meteor.subscribe 'docs', selected_tags.array(), 'request'
        @autorun => Meteor.subscribe 'model_docs', 'request_stats'

    Template.request_view.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
    Template.request_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
    Template.requests.helpers
        requests_doc: ->
            Docs.findOne
                model:'request_stats'
        requests: ->
            Docs.find
                model:'request'


    Template.request_card_template.events
        'click .grab': ->
            console.log @



    Template.requests.events
        'click .add_request': ->
            new_id = Docs.insert
                model:'request'
            Router.go "/request/#{new_id}/edit"

    Template.request_history.onCreated ->
        @autorun => Meteor.subscribe 'children', 'log_event', Router.current().params.doc_id
    Template.request_history.helpers
        request_events: ->
            Docs.find
                model:'log_event'
                parent_id:Router.current().params.doc_id




    Template.request_time.onCreated ->
        # @autorun => Meteor.subscribe 'children', 'log_event', Router.current().params.doc_id
    Template.request_time.events
        'click .mark_complete': ->
            if confirm 'mark complete?'
                Docs.update Router.current().params.doc_id,
                    $set:
                        complete:true
                        complete_timestamp: Date.now()
            Docs.insert
                model:'log_event'
                log_type:'complete'
                parent_id:Router.current().params.doc_id
                text: "#{Meteor.user().username} marked requestrk order complete."


if Meteor.isServer
    Meteor.methods
        calc_request_stats: ->
            request_stat_doc = Docs.findOne(model:'request_stats')
            unless request_stat_doc
                new_id = Docs.insert
                    model:'request_stats'
                request_stat_doc = Docs.findOne(model:'request_stats')
            console.log request_stat_doc
            total_count = Docs.find(model:'request').count()
            complete_count = Docs.find(model:'request', complete:true).count()
            incomplete_count = Docs.find(model:'request', complete:$ne:true).count()
            Docs.update request_stat_doc._id,
                $set:
                    total_count:total_count
                    complete_count:complete_count
                    incomplete_count:incomplete_count
