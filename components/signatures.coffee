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
