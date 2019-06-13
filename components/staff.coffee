if Meteor.isClient
    Template.shift_change_requests.onCreated ->
        @autorun => Meteor.subscribe 'model_docs', 'shift_change_request'

    Template.staff.onCreated ->
        # @autorun => Meteor.subscribe 'health_club_members', Session.get('username_query')
        # @autorun => Meteor.subscribe 'users'
        @autorun => Meteor.subscribe 'sessions'


    Template.staff.helpers
        checkedin_members: ->
            Meteor.users.find
                healthclub_checkedin:true

        sessions: ->
            Docs.find
                model:'healthclub_session'
                # model:$in:['healthclub_checkin','garden_key_checkout','unit_key_checkout']

    Template.hc_session.onCreated ->
        @autorun => Meteor.subscribe 'user_by_username', @data.resident_username

    Template.hc_session.helpers
        icon_class: ->
            switch @session_type
                when 'healthclub_checkin' then 'treadmill'
                when 'garden_key_checkout' then 'basketball'
                when 'unit_key_checkout' then 'key'

        session_resident: ->
            Meteor.users.findOne
                username:@resident_username


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





    Template.unit_key_checkout.events
        'click .unit_key_checkout': (e,t)->
            # $(e.currentTarget).closest('.segment').transition('fade left',100)
            # Meteor.setTimeout =>
            $('body').toast({
                title: "unit key checked out #{@first_name} #{@last_name}."
                # message: 'See desk staff for key.'
                class : 'blue'
                position:'top right'
                # className:
                #     toast: 'ui massive message'
                displayTime: 5000
                transition:
                  showMethod   : 'zoom',
                  showDuration : 250,
                  hideMethod   : 'fade',
                  hideDuration : 250
                })
            # , 100
            Meteor.users.update @_id,
                $set:healthclub_checkedin:true
            Docs.insert
                model:'log_event'
                log_type:'unit_key_checkout'
                active:true
                object_id:@_id
                body: "#{@first_name} #{@last_name} checked out the unit key."
            # document.reload()






if Meteor.isServer
    Meteor.methods
        lookup_key: (building_number, unit_number)->
            console.log 'looking for key', building_number, unit_number
            found_key = Docs.findOne
                model:'key'
                building_number:building_number
                unit_number:unit_number

    Meteor.publish 'sessions', ->
        Docs.find
            model:'healthclub_session'
            # model:$in:['healthclub_checkin','garden_key_checkout','unit_key_checkout']
            active:true
