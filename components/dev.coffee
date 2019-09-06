Router.route '/dev', (->
    @layout 'layout'
    @render 'dev'
    ), name:'dev'


if Meteor.isClient
    Template.dev.onCreated ->
        # @autorun => Meteor.subscribe 'docs', selected_tags.array(), 'event'
        @autorun => Meteor.subscribe 'model_docs', 'model'
        @autorun => Meteor.subscribe 'omega'

    Template.dev.helpers
        model_model: ->
            Docs.findOne
                model:'model'
                slug:'model'

        omega_doc: ->
            Docs.findOne
                model:'omega'

        omegas: ->
            Docs.find
                model:'omega'

        child_docs: ->
            Docs.find
                model:'model'

        selected_child: ->
            Session.get 'selected_child_id'

        selected_child_doc: ->
            Docs.findOne Session.get('selected_child_id')

        child_doc_class: ->
            if @_id is Session.get('selected_child_id') then 'active' else ''



        selected_omega: ->
            Session.get 'selected_child_id'

        selected_omega_doc: ->
            Docs.findOne Session.get('selected_omega_id')

        selected_omega_class: ->
            if @_id is Session.get('selected_omega_id') then 'active' else ''


    Template.dev.events
        'click .lookup_email': ->
            email = $('.enter_email').val()
            console.log email
            Meteor.call 'find_user_by_email', email, (err,res)->
                alert res

        'click .select_omega': ->
            Session.set 'selected_omega_id', @_id

        'click .select_child': ->
            Session.set 'selected_child_id', @_id

        'click .deselect_child': ->
            Session.set 'selected_child_id', null

        'click .make_omega': ->
            Docs.insert
                model:'omega'


        'click .print_omega': ->
            omega_doc =
                Docs.findOne
                    model:'omega'
            console.dir omega_doc


    Template.set_omega_setting.events
        'click .set_setting': ->
            console.log @
            Docs.update Session.get('selected_omega_id'),
                $set: "#{@key}": "#{@value}"





if Meteor.isServer
    Meteor.publish 'omega', ->
        Docs.find
            model:'omega'


    Meteor.methods
        find_user_by_email: (email)->
            console.log email
            result = Accounts.findUserByEmail(email)
            console.log result
            result
