# Router.route '/work', -> @render 'work'
Router.route '/work/', -> @render 'work'
Router.route '/work/:doc_id/view', -> @render 'work_view'
Router.route '/work/:doc_id/edit', -> @render 'work_edit'


if Meteor.isClient
    Template.work.onCreated ->
        @autorun => Meteor.subscribe 'docs', selected_tags.array(), 'work'
        @autorun -> Meteor.subscribe 'model_docs', 'work'
        @autorun => Meteor.subscribe 'model_docs', 'work_stats'


    Template.work.onRendered ->
        Meteor.setTimeout ->
            $('.accordion').accordion()
        , 1000




    Template.work_view.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
    Template.work_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
    Template.work.helpers
        work: ->
            Docs.find
                model:'work'
        work_stats_doc: ->
            Docs.findOne
                model:'work_stats'

    Template.work_view.events
        'click .mark_complete': ->
            if confirm 'mark complete?'
                # console.log @
                Docs.update @_id,
                    $set:complete:true
                Docs.insert
                    model:'log_event'
                    parent_id: @_id
                    text: "#{Meteor.user().username} marked work complete."
                    log_type:'work complete'



    Template.work.events
        'click .add_work': ->
            new_id = Docs.insert
                model:'work'
            Router.go "/work/#{new_id}/edit"

        'click .recalc_work': ->
            Meteor.call 'recalc_work', ->



    Template.my_unit_work.helpers
        my_unit_work: ->
            Docs.find {model:'work'},
                sort: _timestamp: -1
                limit:10

    Template.all_work.helpers
        all_work: ->
            Docs.find {model:'work'},
                sort: _timestamp: -1
                limit:10

    Template.my_building_work.helpers
        my_building_work: ->
            Docs.find {model:'work'},
                sort: _timestamp: -1
                limit:10


    Template.my_assignments.onCreated ->
        @autorun => Meteor.subscribe 'my_assignments'
    Template.my_assignments.helpers
        my_assigments: ->
            Docs.find {
                model:'work'
                assigned_to_username: Meteor.user().username
                },
                sort: _timestamp: -1
                limit:5


    Template.most_missed_people.onCreated ->
        @autorun => Meteor.subscribe 'most_unanswered'
    Template.most_missed_people.helpers
        unanswering_people: ->
            Meteor.users.find {},
                sort: unanswered:-1
                limit:5


    Template.most_unanswering_people.onCreated ->
        @autorun => Meteor.subscribe 'most_unanswering_people'
    Template.most_unanswering_people.helpers
        unanswering_people: ->
            Meteor.users.find {},
                sort: unanswered:-1
                limit:5
    Template.most_unanswering_people.events
        'click .recalc_unanswered': ->
            Meteor.call 'recalc_unanswered', ->






    Template.highest_bounty.onCreated ->
        @autorun => Meteor.subscribe 'highest_bounty'
    Template.highest_bounty.helpers
        work_with_bounty: ->
            Docs.find {
                model:'work'
                bounty:true
                },
                sort: bounty_amount: -1
                limit:10


    Template.work_activity_full.onCreated ->
        @autorun => Meteor.subscribe 'work_activity_full', Router.current().params.doc_id
    Template.work_activity_full.helpers
        work_activity: ->
            Docs.find {
                model:'log_event'
                parent_id: Router.current().params.doc_id
                },
                sort: _timestamp: -1
                limit:10



    Template.latest_work.onCreated ->
        @autorun => Meteor.subscribe 'latest_work'
    Template.latest_work.helpers
        latest_work: ->
            Docs.find {
                model:'work'
            },
                sort: _timestamp: -1
                limit:5



if Meteor.isServer
    Meteor.publish 'my_assignments', ->
        Docs.find {
            model:'work'
            assigned_to_username: Meteor.user().username
        }

    Meteor.publish 'work_activity_full', (work_id)->
        Docs.find {
            model:'log_event'
            parent_id:work_id
        }

    Meteor.methods
        recalc_unanswered: ->
            unanswered_count = Docs.find(
                model:'work'
                response_requested:true
                responded:false
            ).count()
        recalc_work: ->
            work_stat_doc = Docs.findOne(model:'work_stats')
            unless work_stat_doc
                new_id = Docs.insert
                    model:'work_stats'
                work_stat_doc = Docs.findOne(model:'work_stats')
            console.log work_stat_doc
            total_count = Docs.find(model:'work').count()
            complete_count = Docs.find(model:'work', complete:true).count()
            incomplete_count = Docs.find(model:'work', complete:$ne:true).count()
            total_updates_count = Docs.find(model:'work_update').count()
            Docs.update work_stat_doc._id,
                $set:
                    total_count:total_count
                    complete_count:complete_count
                    incomplete_count:incomplete_count
                    total_updates_count:total_updates_count
