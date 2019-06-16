Template.healthclub.onCreated ->
    @autorun => Meteor.subscribe 'health_club_members', Session.get('username_query')
    # @autorun => Meteor.subscribe 'current_session'
    # @autorun => Meteor.subscribe 'model_docs', 'log_event'
    @autorun => Meteor.subscribe 'users'


Template.healthclub.onRendered ->
    # video = document.querySelector('#videoElement')
    # if navigator.mediaDevices.getUserMedia
    #   navigator.mediaDevices.getUserMedia(video: true).then((stream) ->
    #     video.srcObject = stream
    #     return
    #   ).catch (err0r) ->
    #     console.log 'Something went wrong!'
    #     return
    # @autorun =>
    #     if @subscriptionsReady()
    #         Meteor.setTimeout ->
    #             $('.dropdown').dropdown()
    #         , 3000

    # Meteor.setTimeout ->
    #     $('.item').popup()
    # , 3000
    Meteor.setTimeout ->
        $('.accordion').accordion()
    , 3000


Template.healthclub.helpers
    current_session_doc: ()->
        Docs.findOne
            model:'healthclub_session'
            current:true

    selected_person: ->
        Meteor.users.findOne Session.get('selected_user_id')

    checkedin_members: ->
        Meteor.users.find
            healthclub_checkedin:true

    checkedout_members: ->
        username_query = Session.get('username_query')
        Meteor.users.find({
            username: {$regex:"#{username_query}", $options: 'i'}
            # healthclub_checkedin:$ne:true
            roles:$in:['resident','owner']
            },{ limit:10 }).fetch()


    checking_in: -> Session.get('checking_in')
    is_query: -> Session.get('username_query')

    events: ->
        Docs.find {
           model:'log_event'
        }, sort:_timestamp:-1


Template.checkin_button.events
    'click .new_hc_session': (e,t)->
        # $(e.currentTarget).closest('.button').transition('fade up')
        # Meteor.setTimeout =>
        # Docs.insert
        #     model:'log_event'
        #     object_id:@_id
        #     body: "#{@username} checked in."
        session_document = Docs.insert
            model:'healthclub_session'
            active:true
            submitted:false
            approved:false
            user_id:@_id
            guest_ids:[]
            resident_username:@username
            current:true
        Meteor.call 'check_resident_status', @_id
        Session.set 'username_query',null
        # Session.set 'session_document',session_document
        # Session.set 'checking_in',false
        $('.username_search').val('')
        Router.go "/healthclub_session/#{session_document}"
        Session.set 'displaying_profile',@_id
        # , 750

    'click .checkout': (e,t)->
        # $(e.currentTarget).closest('.card').transition('fade up')
        # Meteor.setTimeout =>
        Meteor.call 'checkout_user', @_id, =>
            $('body').toast({
                title: "#{@first_name} #{@last_name} checked out"
                class: 'success'
                transition:
                    showMethod   : 'zoom',
                    showDuration : 250,
                    hideMethod   : 'fade',
                    hideDuration : 250
            })
            Session.set 'username_query',null
            $('.username_search').val('')
            # , 100


Template.healthclub.events
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
            if username_query.length > 1
                # audio = new Audio('wargames.wav');
                # audio.play();
                # console.log 'hi'
                Session.set 'username_query',username_query


    'input .barcode_entry': _.debounce((e, t)->
        barcode_entry = parseInt $('.barcode_entry').val()
        # alert barcode_entry
        Meteor.call 'lookup_user_by_code', barcode_entry, (err,res)->
            console.log res
            Session.set 'displaying_profile',res[0]._id
            # audio = new Audio('cantdo.mp3');
            # audio.play();
    , 250)

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

    'click .create_resident': ->
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
                        # healthclub_checkedin:true
                Docs.insert
                    model: 'log_event'
                    object_id: res
                    body: "#{username} was created"
                # Docs.insert
                #     model:'log_event'
                #     object_id:res
                #     body: "#{username} checked in."
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
    @autorun => Meteor.subscribe 'checkin_guests'
    # @autorun => Meteor.subscribe 'rules_signed_username', @data.username


Template.checkin_card.helpers
    rules_signed: ->
        Docs.findOne
            model:'rules_and_regs_signing'
            resident:@username
    session_document: ->
        healthclub_session_document = Docs.findOne Session.get 'session_document'

    new_guest_doc: -> Docs.findOne Session.get('new_guest_id')
    user: -> Meteor.users.findOne @valueOf()
    checkin_card_class: ->
        unless @rules_signed then 'red_flagged'
        else unless @email_verified then 'yellow_flagged'
        else ""
        # else "green_flagged"

    adding_guests: -> Session.get 'adding_guest'

    red_flagged: ->
        rule_doc = Docs.findOne(
            model:'rules_and_regs_signing'
            resident:@username)
        if rule_doc
            # console.log 'true'
            false
        else
            # console.log 'false'
            true
        # unless @rules_signed then true else false

Template.checkin_card.events
    'click .sign_rules': ->
        new_id = Docs.insert
            model:'rules_and_regs_signing'
            resident: @username
        Router.go "/sign_rules/#{new_id}/#{@username}"
        Session.set 'displaying_profile',null

    'click .cancel_checkin': (e,t)->
        $(e.currentTarget).closest('.segment').transition('fade right',250)
        Meteor.setTimeout =>
            Session.set 'displaying_profile', null
            Session.set 'adding_guest', false
            healthclub_session_document = Docs.findOne Session.get 'session_document'
            Docs.remove healthclub_session_document._id
            checkin_doc = Session.set 'session_document',null
        , 250
        # document.reload()

    'click .healthclub_checkin': (e,t)->
        Session.set 'adding_guest', false
        # Session.set 'displaying_profile', null
        healthclub_session_document = Docs.findOne
            model:'healthclub_session'
        if healthclub_session_document.guest_ids.length > 0
            # now = Date.now()
            current_month = moment().format("MMM")
            Meteor.users.update @_id,
                $addToSet:
                    total_guests:checkin_doc.guest_ids.length
                    "#{current_month}_guests":checkin_doc.guest_ids.length
        Docs.update healthclub_session_document._id,
            $set:
                session_type:'healthclub_checkin'
                submitted:true

    'click .garden_key_checkout': (e,t)->
        healthclub_session_document = Docs.findOne
            model:'healthclub_session'
        Docs.update healthclub_session_document._id,
            $set:
                session_type:'garden_key_checkout'
                submitted:true

    'click .unit_key_checkout': (e,t)->
        healthclub_session_document = Docs.findOne
            model:'healthclub_session'
        Docs.update healthclub_session_document._id,
            $set:
                session_type:'unit_key_checkout'
                submitted:true

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
        Docs.update current_session._id,
            $pull:guest_ids:@_id

    'click .toggle_adding_guest': ->
        Session.set 'adding_guest', true


    'click .add_guest': ->
        console.log @
        new_guest_id =
            Docs.insert
                model:'guest'
                resident_id: @_id
                resident: @username
        Session.set 'displaying_profile', null
        #
        Router.go "/add_guest/#{new_guest_id}"
        #
        # Session.set 'new_guest_id', new_guest_id
        # $('.ui.fullscreen.modal').modal({
        #     closable: false
        #     onDeny: ->
        #         # window.alert('Wait not yet!')
        #         # return false;
        #         Docs.remove new_guest_id
        #     onApprove: ->
        #         # window.alert('Approved!')
        #   })
        #   .modal('show')




Template.checkin_card.onCreated ->
    @autorun => Meteor.subscribe 'user_from_id', @data
