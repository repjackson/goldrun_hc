if Meteor.isClient
    Template.rules_signing.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
    Template.rules_signing.helpers
        signing_doc: -> Docs.findOne Router.current().params.doc_id
        agree_class: -> if @agree then 'green' else 'basic'
    Template.rules_signing.events
        'click .agree':->
            signing_doc = Docs.findOne Router.current().params.doc_id
            if signing_doc.agree
                Docs.update signing_doc._id,
                    $set:agree:false
            else
                Docs.update signing_doc._id,
                    $set:agree:true

        'click .edit_signature':->
            signing_doc = Docs.findOne Router.current().params.doc_id
            Docs.update signing_doc._id,
                $set:signature_saved:false


        'click .submit_rules':->
            signing_doc = Docs.findOne Router.current().params.doc_id
            user = Meteor.users.findOne username:signing_doc.resident
            Meteor.users.update user._id,
                $set:rules_signed:true
            Session.set 'displaying_profile', user._id
            Router.go "/checkin"




    Template.rules_and_regs_check.onCreated ->
        @autorun => Meteor.subscribe 'rules_signed_username', @data.username
    Template.rules_and_regs_check.helpers
        rules_signed: ->
            Docs.findOne
                model:'rules_and_regs_signing'
                resident:@username
    Template.rules_and_regs_check.events
        'click .sign_rules': ->
            new_id = Docs.insert
                model:'rules_and_regs_signing'
                resident: @username

            Router.go "/sign_rules/#{new_id}"
            Session.set 'displaying_profile',null




    Template.add_guest.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.new_guest_id
        @autorun => Meteor.subscribe 'resident', Router.current().params.new_guest_id
    Template.add_guest.helpers
        new_guest_doc: -> Docs.findOne Router.current().params.new_guest_id

    Template.add_guest.events
        'click .submit_new_guest': ->
            console.log @

        'click .cancel_new_guest': ->
            guest_doc = Docs.findOne Router.current().params.new_guest_id
            Docs.remove guest_doc._id
            Session.set 'displaying_profile', guest_doc.resident_id
            Router.go "/checkin"

            $('body').toast({
                title: "Adding guest canceled."
                class: 'info'
                transition:
                    showMethod   : 'zoom',
                    showDuration : 100,
                    hideMethod   : 'fade',
                    hideDuration : 100
            })

        'click .agree':->
            guest_doc = Docs.findOne Router.current().params.new_guest_id
            if guest_doc.agree
                Docs.update guest_doc._id,
                    $set:agree:false
            else
                Docs.update guest_doc._id,
                    $set:agree:true

        'click .edit_signature':->
            signing_doc = Docs.findOne Router.current().params.new_guest_id
            Docs.update signing_doc._id,
                $set:signature_saved:false


        'click .submit_guest':->
            guest_doc = Docs.findOne Router.current().params.new_guest_id
            # console.log guest_doc
            checking_in_doc = Docs.findOne Session.get('checkin_document')

            Docs.update checking_in_doc._id,
                $addToSet: guest_ids: guest_doc._id

            user = Meteor.users.findOne guest_doc.resident_id
            Meteor.users.update user._id,
                $addToSet:guest_ids: guest_doc._id

            Session.set 'displaying_profile', guest_doc.resident_id
            Router.go "/checkin"
