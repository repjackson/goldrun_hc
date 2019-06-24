if Meteor.isClient
    Template.user_check_steps.onCreated ->
        @autorun => Meteor.subscribe 'model_docs', 'user_check'
    Template.user_check_steps.helpers
        user_check: ->
            Docs.find
                model:'user_check'

        user_check_completed: ->
            context_user = Template.parentData()
            check = Template.currentData()
            context_user["#{check.slug}"]
            # console.log @slug


    Template.user_check_steps.events
        'click .recheck': ->
            # console.log @slug
            context_user = Template.currentData()
            console.log context_user
            # username = Template.parentData().resident_username
            Meteor.call @slug, context_user, (err,res)=>
                Meteor.users.update context_user._id,
                    $set: "#{@slug}":res


if Meteor.isServer
    Meteor.methods
        staff_image_verification: (user)->
            return 'hi'
        image_check: (user)->
            if user.kiosk_photo then true else false
        rules_and_regulations_signed: (user)->
            found_rules_signing = Docs.findOne
                model:'rules_and_regs_signing'
                resident:@username
            if found_rules_signing then true else false
        member_waiver_signed: (user)->
            found_rules_signing = Docs.findOne
                model:'rules_and_regs_signing'
                resident:@username
            if found_rules_signing then true else false
        email_verified: (user)->
            if user.emails[0].verified then true else false
        staff_government_id_check: (user)->
            user.staff_government_id_check
