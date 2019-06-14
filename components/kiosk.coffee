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
        @autorun => Meteor.subscribe 'checkin_guests'
        @autorun -> Meteor.subscribe 'current_session'
        @autorun -> Meteor.subscribe 'healthclub_session', Router.current().params.doc_id

        # @autorun => Meteor.subscribe 'rules_signed_username', @data.username


    Template.healthclub_session.events
        'click .cancel_checkin': ->
            Docs.remove @_id
            Router.go "/healthclub"


    Template.healthclub_session.helpers
        rules_signed: ->
            # console.log @
            Docs.findOne
                model:'rules_and_regs_signing'
                resident:@resident_username
        session_document: ->
            healthclub_session_document = Docs.findOne Session.get 'session_document'

        user: ->
            # console.log @
            Meteor.users.findOne @user_id




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
