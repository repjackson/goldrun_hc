Template.goldrun.onCreated ->
    @autorun => Meteor.subscribe 'health_club_members', Session.get('username_query')
    # @autorun => Meteor.subscribe 'type', 'field'
    # @autorun => Meteor.subscribe 'model_docs', 'log_event'
    @autorun => Meteor.subscribe 'users'


Template.goldrun.onRendered ->
    # @autorun =>
    #     if @subscriptionsReady()
    #         Meteor.setTimeout ->
    #             $('.dropdown').dropdown()
    #         , 3000

    Meteor.setTimeout ->
        $('.item').popup()
    , 3000
    Meteor.setTimeout ->
        $('.accordion').accordion()
    , 3000


Template.goldrun.helpers
    selected_person: ->
        Meteor.users.findOne Session.get('selected_user_id')

    checkedin_members: ->
        Meteor.users.find
            healthclub_checkedin:true

    checkedout_members: ->
        username_query = Session.get('username_query')
        Meteor.users.find({
            username: {$regex:"#{username_query}", $options: 'i'}
            healthclub_checkedin:$ne:true
            roles:$in:['resident','owner']
            },{ limit:10 }).fetch()

    checking_in: -> Session.get('checking_in')
    is_query: -> Session.get('username_query')

    events: ->
        Docs.find {
           model:'log_event'
        }, sort:_timestamp:-1


Template.checkin_button.events
    'click .checkin': (e,t)->
        $(e.currentTarget).closest('.button').transition('fade up')
        Meteor.setTimeout =>
            # Docs.insert
            #     model:'log_event'
            #     object_id:@_id
            #     body: "#{@username} checked in."
            checkin_document = Docs.insert
                model:'healthclub_checkin'
                object_id:@_id
                resident_username:@username
                body: "#{@username} checked in."
            Session.set 'username_query',null
            Session.set 'checkin_document',checkin_document
            # Session.set 'checking_in',false
            $('.username_search').val('')
            Session.set 'displaying_profile',@_id
        , 750

    'click .checkout': (e,t)->
        $(e.currentTarget).closest('.card').transition('fade up')
        Meteor.setTimeout =>
            Meteor.users.update @_id,
                $set:healthclub_checkedin:false
            Docs.insert
                model:'log_event'
                parent_id:@_id
                object_id:@_id
                body: "#{@username} checked out."
            $('body').toast({
                message: "#{@username} checked out."
                class: 'info'
            })
            Session.set 'username_query',null
            $('.username_search').val('')
        , 1000


Template.goldrun.events
    'click .sign_waiver': (e,t)->
        # console.log @
        receipt_id = Docs.insert
            model:'rules_and_regulations_acknowledgement'
            resident_residence:@_id
            is_resident:true
        Router.go "/sign_waiver/#{receipt_id}"

    'click .username_search': (e,t)->
        Session.set 'checking_in',true

    'keyup .username_search': (e,t)->
        username_query = $('.username_search').val()
        if e.which is 8
            if username_query.length is 0
                Session.set 'username_query',null
                Session.set 'checking_in',false
            else
                Session.set 'username_query',username_query
        else
            Session.set 'username_query',username_query

    'click .clear_results': ->
        Session.set 'username_query',null
        Session.set 'checking_in',false
        $('.username_search').val('')



Template.add_resident.onCreated ->
    Session.set 'permission', false

Template.add_resident.events
    'keyup #last_name': (e,t)->
        first_name = $('#first_name').val()
        last_name = $('#last_name').val()
        $('#username').val("#{first_name.toLowerCase()}_#{last_name.toLowerCase()}")
        Session.set 'permission',true

    'click .create_and_checkin': ->
        first_name = $('#first_name').val()
        last_name = $('#last_name').val()
        username = "#{first_name.toLowerCase()}_#{last_name.toLowerCase()}"
        Meteor.call 'add_user', username, (err,res)=>
            if err
                alert err
            else
                Meteor.users.update res,
                    $set:
                        first_name:first_name
                        last_name:last_name
                        roles:['resident']
                        healthclub_checkedin:true
                Docs.insert
                    model:'log_event'
                    object_id:res
                    body: "#{username} was created."
                Docs.insert
                    model:'log_event'
                    object_id:res
                    body: "#{username} checked in."
                Session.set 'username_query',null
                $('.username_search').val('')

                Router.go "/user/#{username}/edit"


Template.add_resident.helpers
    permission: -> Session.get 'permission'



Template.sign_waiver.onCreated ->
    @autorun => Meteor.subscribe 'doc', Router.current().params.receipt_id
    @autorun => Meteor.subscribe 'document_from_slug', 'rules_regs'
Template.sign_waiver.helpers
    receipt_doc: -> Docs.findOne Router.current().params.receipt_id
    waiver_doc: ->
        Docs.findOne
            model:'document'
            slug:'rules_regs'




Template.checkin_card.onCreated ->
    @autorun => Meteor.subscribe 'doc', Session.get('new_guest_id')
Template.checkin_card.helpers
    new_guest_doc: -> Docs.findOne Session.get('new_guest_id')
    user: -> Meteor.users.findOne @valueOf()
    checkin_card_class: ->
        unless @rules_signed then 'red_flagged'
        else if @email_verified then 'yellow_flagged'
        else "green_flagged"

    red_flagged: ->
        rule_doc = Docs.findOne(
            model:'rules_and_regs_signing'
            resident:@username)
        if rule_doc
            console.log 'true'
            false
        else
            console.log 'false'
            true
        # unless @rules_signed then true else false

Template.checkin_card.events
    'click .cancel_checkin': (e,t)->
        $(e.currentTarget).closest('.segment').transition('fade right',500)
        Meteor.setTimeout =>
            Session.set 'displaying_profile', null
            checkin_doc = Docs.findOne Session.get 'checkin_document'
            Docs.remove checkin_doc._id
            checkin_doc = Session.set 'checkin_document',null
        , 1000

    'click .complete_checkin': (e,t)->
        $(e.currentTarget).closest('.segment').transition('fade left',500)
        Meteor.setTimeout =>
            Session.set 'displaying_profile', null
            $('body').toast({
                message: "#{@username} checked in."
                class: 'success'})
        , 1000
        Meteor.users.update @_id,
            $set:healthclub_checkedin:true
        Docs.insert
            model:'log_event'
            object_id:@_id
            body: "#{@username} checked in."

    'click .add_guest': ->
        # console.log @
        new_guest_id =
            Docs.insert
                model:'guest'
                resident_id: @_id
        Session.set 'new_guest_id', new_guest_id
        $('.ui.fullscreen.modal').modal({
            closable: false
            onDeny: ->
                # window.alert('Wait not yet!')
                # return false;
                Docs.remove new_guest_id
            onApprove: ->
                # window.alert('Approved!')
          })
          .modal('show')


Template.guest_modal_content.onCreated ->
    @autorun => Meteor.subscribe 'doc', Session.get('new_guest_id')
Template.guest_modal_content.helpers
    new_guest_doc: -> Docs.findOne Session.get('new_guest_id')

Template.guest_modal_content.events
    'click .submit_new_guest': ->
        console.log @

    'click .cancel_new_guest': ->
        Docs.remove Session.get('new_guest_id')
        $('body').toast({
            message: "Adding guest canceled."
            class: 'info'
        })


Template.checkin_card.onCreated ->
    @autorun => Meteor.subscribe 'user_from_id', @data


Template.checkin_guest.onCreated ->
    @autorun => Meteor.subscribe 'guests'
Template.checkin_guest.helpers
    checking_in_guest: -> Session.get 'checking_in_guest'
    guests: ->
        Meteor.users.find
            roles:$in:['guest']

Template.checkin_guest.events
    'click .checkin_guest': ->
        Session.set('checking_in_guest', !Session.get('checking_in_guest'))
