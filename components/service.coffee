Router.route '/services', (->
    @render 'services'
    ), name:'services'
Router.route '/service/:doc_id/view', (->
    @render 'service_view'
    ), name:'service_view'
Router.route '/service/:doc_id/edit', (->
    @render 'service_edit'
    ), name:'service_edit'


if Meteor.isClient
    Template.service_view.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
    Template.service_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id

    Template.service_history.onCreated ->
        @autorun => Meteor.subscribe 'children', 'log_event', Router.current().params.doc_id
    Template.service_history.helpers
        service_events: ->
            Docs.find
                model:'log_event'
                parent_id:Router.current().params.doc_id


    Template.service_subscription.onCreated ->
        # @autorun => Meteor.subscribe 'children', 'log_event', Router.current().params.doc_id
    Template.service_subscription.events
        'click .subscribe': ->
            Docs.insert
                model:'log_event'
                log_type:'subscribe'
                parent_id:Router.current().params.doc_id
                text: "#{Meteor.user().username} subscribed to servicerk order."


    Template.service_time.onCreated ->
        # @autorun => Meteor.subscribe 'children', 'log_event', Router.current().params.doc_id
    Template.service_time.events
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
                text: "#{Meteor.user().username} marked servicerk order complete."


if Meteor.isServer
    Meteor.methods
        calc_service_stats: ->
            service_stat_doc = Docs.findOne(model:'service_stats')
            unless service_stat_doc
                new_id = Docs.insert
                    model:'service_stats'
                service_stat_doc = Docs.findOne(model:'service_stats')
            console.log service_stat_doc
            total_count = Docs.find(model:'service').count()
            complete_count = Docs.find(model:'service', complete:true).count()
            incomplete_count = Docs.find(model:'service', complete:$ne:true).count()
            Docs.update service_stat_doc._id,
                $set:
                    total_count:total_count
                    complete_count:complete_count
                    incomplete_count:incomplete_count