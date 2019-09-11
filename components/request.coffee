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
    Template.request_view.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
    Template.request_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id


    Template.request_card_template.events
        'click .grab': ->
            if confirm 'grab this?'
                Docs.update @_id,
                    $set:
                        grabber_id:Meteor.userId()
                        grab_timestamp: Date.now()
                Docs.insert
                    model:'log_event'
                    log_type: 'grab'
                    text: "#{Meteor.user().name()} grabbed this."
                    parent_id: @_id

        'click .join_waitlist': ->
            if confirm 'join waitlist?'
                Docs.update @_id,
                    $addToSet:
                        waitlist: {
                            user_id: Meteor.userId()
                            add_timestamp: Date.now()
                            position: @waitlist.length
                        }

                Docs.insert
                    model:'log_event'
                    log_type: 'join_waitlist'
                    text: "#{Meteor.user().name()} joined waitlist at ."
                    parent_id: @_id

        'click .release': ->
            if confirm 'release this?'
                Docs.update @_id,
                    $set:
                        grabber_id:null
                        release_timestamp: Date.now()
                Docs.insert
                    model:'log_event'
                    log_type: 'release'
                    text: "#{Meteor.user().name()} released this."
                    parent_id: @_id


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
