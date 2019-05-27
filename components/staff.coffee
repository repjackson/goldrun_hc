if Meteor.isClient
    Template.shift_change_requests.onCreated ->
        @autorun => Meteor.subscribe 'model_docs', 'shift_change_request'

    Template.staff.onCreated ->
        # @autorun => Meteor.subscribe 'health_club_members', Session.get('username_query')
        @autorun => Meteor.subscribe 'users'


    Template.staff.helpers
        checkedin_members: ->
            Meteor.users.find
                healthclub_checkedin:true

    Template.shift_change_requests.helpers
        requests: ->
            Docs.find {model:'shift_change_request'},
                sort: date: -1


    Template.shift_change_requests.events
        'click .add_shift_change_request': (e,t)->
            Docs.insert
                model:'shift_change_request'

    Template.request_row.events
        'click .declare_unavailable': (e,t)->
            Docs.update @_id,
                $addToSet:unavailable:Meteor.user().username
        'click .take_shift': (e,t)->
            Docs.update @_id,
                $set:assigned_staff:Meteor.user().username


    Template.task_widget.onCreated ->
        @autorun => Meteor.subscribe 'model_docs', 'task'
    Template.task_widget.helpers
        tasks: ->
            Docs.find {model:'task'},
                sort: date: -1



    Template.unit_key_widget.onCreated ->
    Template.unit_key_widget.events
        'click .lookup_key': (e,t)->
            building_number = parseInt t.$('.building_number').val()
            unit_number = parseInt t.$('.unit_number').val()
            console.log building_number
            console.log unit_number
            Meteor.call 'lookup_key',building_number, unit_number, (err,res)->
                alert "key tag number", res.tag_number

    Template.unit_key_widget.helpers
        tasks: ->
            Docs.find {model:'task'},
                sort: date: -1






if Meteor.isServer
    Meteor.methods
        lookup_key: (building_number, unit_number)->
            console.log 'looking for key', building_number, unit_number
            found_key = Docs.findOne
                model:'key'
                building_number:building_number
                unit_number:unit_number
