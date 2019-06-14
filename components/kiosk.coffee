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

    Template.shop_view.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
    Template.shop_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id


    Template.product_transactions.onCreated ->
        @autorun => Meteor.subscribe 'product_transactions', Router.current().params.doc_id

    Template.product_transactions.helpers
        product_transactions: ->
            Docs.find
                model:'transaction'
                product_id: Router.current().params.doc_id



if Meteor.isServer
    Meteor.publish 'kiosk_document', ()->
        Docs.find
            model:'kiosk'
