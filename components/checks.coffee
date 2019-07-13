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
            # Meteor.call @slug, context_user, (err,res)=>
            #     Meteor.users.update context_user._id,
            #         $set: "#{@slug}":res


if Meteor.isServer
    Meteor.methods
        run_user_checks:(user)->
            # console.log 'running user checks for', user.username
            user_checks_docs = Docs.find(model:'user_check')
            # console.log 'count', user_checks_docs.count()
            for user_check in user_checks_docs.fetch()
                # console.log user
                console.log 'user_check', user_check.slug
                Meteor.call "#{user_check.slug}", user, (err,res)=>
                    # console.log 'check',user_check.slug,'res',res
            #         Meteor.users.update user._id,
            #             $set: "#{user_check.slug}":res
        staff_image_verification: (user)->
            if user.staff_image_verified then true else false
        image_check: (user)->
            if user.kiosk_photo
                Meteor.users.update user._id,
                    $set:staff_image_verification:true

        rules_and_regulations_signed: (user)->
            console.log 'checking rules and regs for ', user.username
            found_rules_signing = Docs.findOne
                model:'rules_and_regs_signing'
                resident:user.username
                signature_saved:true
            console.log 'found rules signing', found_rules_signing
            check_value = if found_rules_signing then true else false
            Meteor.users.update user._id,
                $set:rules_and_regulations_signed:check_value
        member_waiver_signed: (user)->
            console.log 'checking member waiver for ', user.username
            found_member_signing = Docs.findOne
                model:'member_guidelines_signing'
                resident:user.username
            console.log 'found member signing', found_member_signing
            check_value = if found_member_signing then true else false
            Meteor.users.update user._id,
                $set:found_member_signing:check_value

        email_verified: (user)->
            if user.emails and user.emails[0].verified then true else false
        staff_government_id_check: (user)->
            if user.staff_verifier
                Meteor.users.update user._id,
                    $set:staff_government_id_check:true
            else
                Meteor.users.update user._id,
                    $inc:checkins_without_gov_id:1
