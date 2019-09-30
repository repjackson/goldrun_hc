# Router.route '/tasks', -> @render 'tasks'
Router.route '/group/:doc_id/view', -> @render 'group_view'
Router.route '/group/:doc_id/edit', -> @render 'group_edit'


if Meteor.isClient
    Template.group_view.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id

    Template.group_card_template.onRendered ->
        Meteor.setTimeout ->
            $('.accordion').accordion()
        , 1000

    Template.group_card_template.onCreated ->
        @autorun => Meteor.subscribe 'children', 'group_update', @data._id
    Template.group_card_template.helpers
        updates: ->
            Docs.find
                model:'group_update'
                parent_id: @_id


    Template.group_view.onCreated ->
        @autorun => Meteor.subscribe 'children', 'group_update', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'ballot_groups', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'group_options', Router.current().params.doc_id
    Template.group_view.helpers
        options: ->
            Docs.find
                model:'group_option'
        groups: ->
            Docs.find
                model:'group'
                ballot_id: Router.current().params.doc_id
    Template.group_view.events
        'click .group_yes': ->
            my_group = Docs.findOne
                model:'group'
                _author_id: Meteor.userId()
                ballot_id: Router.current().params.doc_id
            if my_group
                Docs.update my_group._id,
                    $set:value:'yes'
            else
                Docs.insert
                    model:'group'
                    ballot_id: Router.current().params.doc_id
                    value:'yes'
        'click .group_no': ->
            my_group = Docs.findOne
                model:'group'
                _author_id: Meteor.userId()
                ballot_id: Router.current().params.doc_id
            if my_group
                Docs.update my_group._id,
                    $set:value:'no'
            else
                Docs.insert
                    model:'group'
                    ballot_id: Router.current().params.doc_id
                    value:'no'

    Template.group_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'group_options', Router.current().params.doc_id
    Template.group_edit.events
        'click .add_option': ->
            Docs.insert
                model:'group_option'
                ballot_id: Router.current().params.doc_id
    Template.group_edit.helpers
        options: ->
            Docs.find
                model:'group_option'
