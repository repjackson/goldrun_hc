if Meteor.isClient
    Template.comments.onCreated ->
        @autorun => Meteor.subscribe 'children', 'comment', Router.current().params.doc_id


    Template.role_editor.onCreated ->
        @autorun => Meteor.subscribe 'type', 'role'

    Template.comments.helpers
        doc_comments: ->
            Docs.find
                model:'comment'

    Template.comments.events
        'keyup .add_comment': (e,t)->
            if e.which is 13
                parent = Docs.findOne Router.current().params.doc_id
                comment = t.$('.add_comment').val()
                console.log comment
                Docs.insert
                    parent_id: parent._id
                    model:'comment'
                    body:comment
                t.$('.add_comment').val('')

        'click .remove_comment': ->
            if confirm 'Confirm remove comment'
                Docs.remove @_id

    Template.user_card.onCreated ->
        @autorun => Meteor.subscribe 'user_from_username', @data
    Template.user_card.helpers
        user: -> Meteor.users.findOne username:@data



    Template.big_user_card.onCreated ->
        @autorun => Meteor.subscribe 'user_from_username', @data
    Template.big_user_card.helpers
        user: -> Meteor.users.findOne username:@valueOf()




    Template.signature.onRendered ->
        canvas = document.querySelector('canvas')
        @signaturePad = new SignaturePad(canvas)
        # Returns signature image as data URL (see https://mdn.io/todataurl for the list of possible parameters)

    Template.signature.events
        'click .thing': ->
            signaturePad.toDataURL()
            # save image as PNG
            signaturePad.toDataURL 'image/jpeg'
            # save image as JPEG
            signaturePad.toDataURL 'image/svg+xml'
            # save image as SVG
            # Draws signature image from data URL.
            # NOTE: This method does not populate internal data structure that represents drawn signature. Thus, after using #fromDataURL, #toData won't work properly.
            signaturePad.fromDataURL 'data:image/png;base64,iVBORw0K...'
            # Returns signature image as an array of point groups
            data = signaturePad.toData()
            # Draws signature image from an array of point groups
            signaturePad.fromData data
        'click .clear': (e,t)->
            # Clears the canvas
            console.log t
            Template.instance().signaturePad.clear()
            # Returns true if canvas is empty, otherwise returns false

            # signaturePad.isEmpty()
            # # Unbinds all event handlers
            # signaturePad.off()
            # # Rebinds all event handlers
            # signaturePad.on()




    Template.user_info.onCreated ->
        # console.log @data
        @autorun => Meteor.subscribe 'user_from_id', @data

    Template.user_info.helpers
        user: ->
            # console.log @
            Meteor.users.findOne @valueOf()


    Template.toggle_edit.events
        'click .toggle_edit': ->
            console.log @
            console.log Template.currentData()
            console.log Template.parentData()
            console.log Template.parentData(1)
            console.log Template.parentData(2)
            console.log Template.parentData(3)
            console.log Template.parentData(4)





    Template.user_list_info.onCreated ->
        @autorun => Meteor.subscribe 'user', @data

    Template.user_list_info.helpers
        user: ->
            console.log @
            Meteor.users.findOne @valueOf()



    Template.follow.helpers
        followers: ->
            Meteor.users.find
                _id: $in: @follower_ids

        following: -> @follower_ids and Meteor.userId() in @follower_ids


    Template.follow.events
        'click .follow': ->
            Docs.update @_id,
                $addToSet:follower_ids:Meteor.userId()

        'click .unfollow': ->
            Docs.update @_id,
                $pull:follower_ids:Meteor.userId()




    Template.user_field.helpers
        key_value: ->
            user = Meteor.users.findOne Router.current().params.doc_id
            user["#{@key}"]

    Template.user_field.events
        'blur .user_field': (e,t)->
            value = t.$('.user_field').val()
            Meteor.users.update Router.current().params.doc_id,
                $set:"#{@key}":value





    Template.user_list_toggle.onCreated ->
        @autorun => Meteor.subscribe 'user_list', Template.parentData(),@key

    Template.user_list_toggle.events
        'click .toggle': (e,t)->
            parent = Template.parentData()
            if parent["#{@key}"] and Meteor.userId() in parent["#{@key}"]
                Docs.update parent._id,
                    $pull:"#{@key}":Meteor.userId()
            else
                Docs.update parent._id,
                    $addToSet:"#{@key}":Meteor.userId()


    Template.user_list_toggle.helpers
        user_list_toggle_class: ->
            if Meteor.user()
                parent = Template.parentData()
                ''
            else
                'disabled'

        in_list: ->
            parent = Template.parentData()
            if parent["#{@key}"] and Meteor.userId() in parent["#{@key}"] then true else false

        list_users: ->
            parent = Template.parentData()
            Meteor.users.find _id:$in:parent["#{@key}"]




    Template.voting.helpers
        upvote_class: -> if @upvoter_ids and Meteor.userId() in @upvoter_ids then 'green' else 'outline'
        downvote_class: -> if @downvoter_ids and Meteor.userId() in @downvoter_ids then 'red' else 'outline'




    Template.voting.events
        'click .upvote': ->
            if @downvoter_ids and Meteor.userId() in @downvoter_ids
                Docs.update @_id,
                    $pull: downvoter_ids:Meteor.userId()
                    $addToSet: upvoter_ids:Meteor.userId()
                    $inc:points:2
            else if @upvoter_ids and Meteor.userId() in @upvoter_ids
                Docs.update @_id,
                    $pull: upvoter_ids:Meteor.userId()
                    $inc:points:-1
            else
                Docs.update @_id,
                    $addToSet: upvoter_ids:Meteor.userId()
                    $inc:points:1
            # Meteor.users.update @_author_id,
            #     $inc:karma:1

        'click .downvote': ->
            if @upvoter_ids and Meteor.userId() in @upvoter_ids
                Docs.update @_id,
                    $pull: upvoter_ids:Meteor.userId()
                    $addToSet: downvoter_ids:Meteor.userId()
                    $inc:points:-2
            else if @downvoter_ids and Meteor.userId() in @downvoter_ids
                Docs.update @_id,
                    $pull: downvoter_ids:Meteor.userId()
                    $inc:points:1
            else
                Docs.update @_id,
                    $addToSet: downvoter_ids:Meteor.userId()
                    $inc:points:-1
            # Meteor.users.update @_author_id,
            #     $inc:karma:-1





    Template.add_button.events
        'click .add': ->
            Docs.insert
                model: @type


    Template.remove_button.events
        'click .remove': ->
            if confirm "Remove #{@type}?"
                Docs.remove @_id


    Template.add_type_button.events
        'click .add': ->
            new_id = Docs.insert model: @type
            Router.go "/edit/#{new_id}"

    Template.view_user_button.events
        'click .view_user': ->
            Router.go "/u/#{username}"


if Meteor.isServer
    Meteor.publish 'children', (type, parent_id)->
        Docs.find
            model:type
            parent_id:parent_id
