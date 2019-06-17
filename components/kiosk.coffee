if Meteor.isClient
    Template.kiosk_settings.onCreated ->
        # @autorun -> Meteor.subscribe 'me'
        @autorun -> Meteor.subscribe 'kiosk_document'

    Template.kiosk_settings.onRendered ->
        # Meteor.setTimeout ->
        #     $('.button').popup()
        # , 3000

    Template.set_kiosk_template.events
        'click .set_kiosk_template': ->
            kiosk_doc = Docs.findOne
                model:'kiosk'
            Docs.update kiosk_doc._id,
                $set:kiosk_view:@value



    Template.kiosk_settings.events
        'click .create_kiosk': (e,t)->
            Docs.insert
                model:'kiosk'

        'click .print_kiosk': (e,t)->
            kiosk = Docs.findOne model:'kiosk'
            console.log kiosk

        'click .delete_kiosk': (e,t)->
            kiosk = Docs.findOne model:'kiosk'
            if kiosk
                if confirm "delete  #{kiosk._id}?"
                    Docs.remove kiosk._id

    Template.kiosk_settings.helpers
        kiosk_doc: ->
            Docs.findOne
                model:'kiosk'
        kiosk_view: ->
            kiosk_doc = Docs.findOne
                model:'kiosk'
            kiosk_doc.kiosk_view


    Template.healthclub_session.onCreated ->
        @autorun => Meteor.subscribe 'doc', Session.get('new_guest_id')
        @autorun => Meteor.subscribe 'checkin_guests',Router.current().params.doc_id
        @autorun -> Meteor.subscribe 'model_docs', 'guest'
        @autorun -> Meteor.subscribe 'resident_from_healthclub_session', Router.current().params.doc_id
        @autorun -> Meteor.subscribe 'healthclub_session', Router.current().params.doc_id

        # @autorun => Meteor.subscribe 'rules_signed_username', @data.username


    Template.healthclub_session.events
        'click .cancel_checkin': ->
            Docs.remove @_id
            Router.go "/healthclub"

        'click .add_guest': ->
            # console.log @
            healthclub_session_document = Docs.findOne Router.current().params.doc_id
            new_guest_id =
                Docs.insert
                    model:'guest'
                    session_id: healthclub_session_document._id
                    resident_id: healthclub_session_document.user_id
                    resident: healthclub_session_document.resident_username
            # Session.set 'displaying_profile', null
            #
            Router.go "/add_guest/#{new_guest_id}"

        'click .sign_rules': ->
            healthclub_session_document = Docs.findOne Router.current().params.doc_id

            new_id = Docs.insert
                model:'rules_and_regs_signing'
                session_id: healthclub_session_document._id
                resident_id: healthclub_session_document.user_id
                resident: healthclub_session_document.resident_username
            Router.go "/sign_rules/#{new_id}/#{healthclub_session_document.resident_username}"
            # Session.set 'displaying_profile',null


        'click .add_recent_guest': ->
            current_session = Docs.findOne
                model:'healthclub_session'
                current:true
            Docs.update current_session._id,
                $addToSet:guest_ids:@_id

        'click .remove_guest': ->
            current_session = Docs.findOne
                model:'healthclub_session'
                current:true
            console.log current_session
            Docs.update current_session._id,
                $pull:guest_ids:@_id

        'click .toggle_adding_guest': ->
            Session.set 'adding_guest', true

        'click .submit_checkin': (e,t)->
            Session.set 'adding_guest', false
            healthclub_session_document = Docs.findOne Router.current().params.doc_id
            # console.log @
            resident = Meteor.users.findOne healthclub_session_document.user_id

            # healthclub_session_document = Docs.findOne
            #     model:'healthclub_session'
            user = Meteor.users.findOne
                username:resident.username
            healthclub_session_document = Docs.findOne Router.current().params.doc_id
            if healthclub_session_document.guest_ids.length > 0
                # now = Date.now()
                current_month = moment().format("MMM")
                Meteor.users.update user._id,
                    $addToSet:
                        total_guests:healthclub_session_document.guest_ids.length
                        "#{current_month}_guests":healthclub_session_document.guest_ids.length
            Docs.update healthclub_session_document._id,
                $set:
                    # session_type:'healthclub_checkin'
                    submitted:true
            Router.go "/healthclub"
            $('body').toast({
                title: "#{resident.first_name} #{resident.last_name} checked in"
                class: 'success'
                transition:
                    showMethod   : 'zoom',
                    showDuration : 250,
                    hideMethod   : 'fade',
                    hideDuration : 250
            })




    Template.healthclub_session.helpers
        rules_signed: ->
            healthclub_session_document = Docs.findOne Router.current().params.doc_id
            # console.log @
            resident = Meteor.users.findOne healthclub_session_document.user_id
            Docs.findOne
                model:'rules_and_regs_signing'
                resident:resident.username
        session_document: ->
            healthclub_session_document = Docs.findOne Router.current().params.doc_id

        adding_guests: -> Session.get 'adding_guest'
        checking_in_doc: ->
            healthclub_session_document = Docs.findOne Router.current().params.doc_id
        checkin_guest_docs: () ->
            healthclub_session_document = Docs.findOne Router.current().params.doc_id
            # console.log @
            Docs.find
                _id:$in:healthclub_session_document.guest_ids

        user: ->
            healthclub_session_document = Docs.findOne Router.current().params.doc_id
            Meteor.users.findOne healthclub_session_document.user_id




if Meteor.isServer
    Meteor.publish 'kiosk_document', ()->
        Docs.find
            model:'kiosk'



    publishComposite 'healthclub_session', (doc_id)->
        {
            find: ->
                Docs.find doc_id
            children: [
                { find: (doc) ->
                    console.log doc
                    Meteor.users.find
                        _id: doc.user_id
                    }
                ]
        }
