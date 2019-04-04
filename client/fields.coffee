Template.color_edit.events
    'blur .edit_color': (e,t)->
        val = t.$('.edit_color').val()
        parent = Template.parentData()
        doc = Docs.findOne parent._id
        user = Meteor.users.findOne parent._id
        if doc
            Docs.update parent._id,
                $set:"#{@key}":val
        else if user
            Meteor.users.update parent._id,
                $set:"#{@key}":val



Template.link_edit.events
    'blur .edit_url': (e,t)->
        val = t.$('.edit_url').val()
        parent = Template.parentData()
        doc = Docs.findOne parent._id
        user = Meteor.users.findOne parent._id
        if doc
            Docs.update parent._id,
                $set:"#{@key}":val
        else if user
            Meteor.users.update parent._id,
                $set:"#{@key}":val


Template.color_icon_edit.events
    'blur .color_icon': (e,t)->
        icon_class = t.$('.color_icon').val()
        parent = Template.parentData()
        doc = Docs.findOne parent._id
        user = Meteor.users.findOne parent._id
        if doc
            Docs.update parent._id,
                $set:"#{@key}":icon_class
        else if user
            Meteor.users.update parent._id,
                $set:"#{@key}":icon_class


Template.icon_edit.events
    'blur .icon_val': (e,t)->
        val = t.$('.icon_val').val()
        parent = Template.parentData()
        doc = Docs.findOne parent._id
        user = Meteor.users.findOne parent._id
        if doc
            Docs.update parent._id,
                $set:"#{@key}":val
        else if user
            Meteor.users.update parent._id,
                $set:"#{@key}":val



Template.html_edit.events
    'blur .froala-container': (e,t)->
        html = t.$('div.froala-reactive-meteorized-override').froalaEditor('html.get', true)
        parent = Template.parentData()
        doc = Docs.findOne parent._id
        user = Meteor.users.findOne parent._id
        if doc
            Docs.update parent._id,
                $set:"#{@key}":html
        else if user
            Meteor.users.update parent._id,
                $set:"#{@key}":html


Template.html_edit.helpers
    getFEContext: ->
        parent = Template.parentData()
        # @current_doc = Docs.findOne Router.current().params.doc_id
        # @current_doc = Docs.findOne @_id
        self = @
        {
            _value: parent["#{@key}"]
            _keepMarkers: true
            _className: 'froala-reactive-meteorized-override'
            toolbarInline: false
            initOnClick: false
            toolbarButtons:
                [
                  'fullscreen'
                  'bold'
                  'italic'
                  'underline'
                  'strikeThrough'
                #   'subscript'
                #   'superscript'
                  '|'
                #   'fontFamily'
                  'fontSize'
                  'color'
                #   'inlineStyle'
                #   'paragraphStyle'
                  '|'
                  'paragraphFormat'
                  'align'
                  'formatOL'
                  'formatUL'
                  'outdent'
                  'indent'
                  'quote'
                #   '-'
                  'insertLink'
                #   'insertImage'
                #   'insertVideo'
                #   'embedly'
                #   'insertFile'
                  'insertTable'
                #   '|'
                  'emoticons'
                #   'specialCharacters'
                #   'insertHR'
                  'selectAll'
                  'clearFormatting'
                  '|'
                #   'print'
                #   'spellChecker'
                #   'help'
                  'html'
                #   '|'
                  'undo'
                  'redo'
                ]
            # toolbarButtonsMD: ['bold', 'italic', 'underline']
            # toolbarButtonsSM: ['bold', 'italic', 'underline']
            toolbarButtonsXS: ['bold', 'italic', 'underline']
            imageInsertButtons: ['imageBack', '|', 'imageByURL']
            tabSpaces: false
            height: 200
        }





Template.image_edit.events
    "change input[name='upload_image']": (e) ->
        files = e.currentTarget.files
        # console.log files
        parent = Template.parentData()
        Cloudinary.upload files[0],
            # folder:"secret" # optional parameters described in http://cloudinary.com/documentation/upload_images#remote_upload
            # type:"private" # optional: makes the image accessible only via a signed url. The signed url is available publicly for 1 hour.
            (err,res) => #optional callback, you can catch with the Cloudinary collection as well
                # console.log "Upload Error: #{err}"
                # console.dir res
                if err
                    console.error 'Error uploading', err
                else
                    doc = Docs.findOne parent._id
                    user = Meteor.users.findOne parent._id
                    if doc
                        Docs.update parent._id,
                            $set:"#{@key}":res.public_id
                    else if user
                        Meteor.users.update parent._id,
                            $set:"#{@key}":res.public_id


    'blur .cloudinary_id': (e,t)->
        cloudinary_id = t.$('.cloudinary_id').val()
        parent = Template.parentData()
        Docs.update parent._id,
            $set:"#{@key}":cloudinary_id


    'click #remove_photo': ->
        parent = Template.parentData()

        if confirm 'Remove Photo?'
            Docs.update parent._id,
                $unset:"#{@key}":1





Template.array_edit.events
    'keyup .new_element': (e,t)->
        if e.which is 13
            element_val = t.$('.new_element').val().trim()
            parent = Template.parentData()
            doc = Docs.findOne parent._id
            user = Meteor.users.findOne parent._id
            if doc
                Docs.update parent._id,
                    $addToSet:"#{@key}":element_val
            else if user
                Meteor.users.update parent._id,
                    $addToSet:"#{@key}":element_val
            t.$('.new_element').val('')

    'click .remove_element': (e,t)->
        element = @valueOf()
        parent = Template.parentData()

        doc = Docs.findOne parent._id
        user = Meteor.users.findOne parent._id
        if doc
            Docs.update parent._id,
                $pull:"#{@key}":element
        else if user
            Meteor.users.update parent._id,
                $pull:"#{@key}":element

        t.$('.new_element').focus()
        t.$('.new_element').val(element)


# Template.textarea.onCreated ->
#     @editing = new ReactiveVar false

# Template.textarea.helpers
#     is_editing: -> Template.instance().editing.get()


Template.textarea_edit.events
    # 'click .toggle_edit': (e,t)->
    #     t.editing.set !t.editing.get()

    'blur .edit_textarea': (e,t)->
        textarea_val = t.$('.edit_textarea').val()
        parent = Template.parentData()

        doc = Docs.findOne parent._id
        user = Meteor.users.findOne parent._id
        if doc
            Docs.update parent._id,
                $set:"#{@key}":textarea_val
        else if user
            Meteor.users.update parent._id,
                $set:"#{@key}":textarea_val



Template.text_edit.events
    'blur .edit_text': (e,t)->
        val = t.$('.edit_text').val()
        parent = Template.parentData()
        doc = Docs.findOne parent._id
        user = Meteor.users.findOne parent._id
        if doc
            Docs.update parent._id,
                $set:"#{@key}":val
        else if user
            Meteor.users.update parent._id,
                $set:"#{@key}":val


Template.boolean_edit.helpers
    boolean_toggle_class: ->
        parent = Template.parentData()
        # console.log parent
        # console.log @
        if parent["#{@key}"] then 'teal' else ''


Template.boolean_edit.events
    'click .toggle_boolean': (e,t)->
        parent = Template.parentData()

        doc = Docs.findOne parent._id
        user = Meteor.users.findOne parent._id
        if doc
            Docs.update parent._id,
                $set:"#{@key}":!parent["#{@key}"]
        else if user
            Meteor.users.update parent._id,
                $set:"#{@key}":!parent["#{@key}"]



Template.number_edit.events
    'blur .edit_number': (e,t)->
        parent = Template.parentData()
        val = t.$('.edit_number').val()
        doc = Docs.findOne parent._id
        user = Meteor.users.findOne parent._id
        if doc
            Docs.update parent._id,
                $set:"#{@key}":val
        else if user
            Meteor.users.update parent._id,
                $set:"#{@key}":val




Template.date_edit.events
    'blur .edit_date': (e,t)->
        parent = Template.parentData()
        val = t.$('.edit_date').val()

        doc = Docs.findOne parent._id
        user = Meteor.users.findOne parent._id
        if doc
            Docs.update parent._id,
                $set:"#{@key}":val
        else if user
            Meteor.users.update parent._id,
                $set:"#{@key}":val





Template.time_edit.events
    'blur .edit_time': (e,t)->
        parent = Template.parentData()
        val = t.$('.edit_time').val()

        doc = Docs.findOne parent._id
        user = Meteor.users.findOne parent._id
        if doc
            Docs.update parent._id,
                $set:"#{@key}":val
        else if user
            Meteor.users.update parent._id,
                $set:"#{@key}":val


Template.youtube_edit.onRendered ->
    Meteor.setTimeout ->
        $('.ui.embed').embed();
    , 1000

Template.youtube_view.onRendered ->
    Meteor.setTimeout ->
        $('.ui.embed').embed();
    , 1000


Template.youtube_edit.events
    'blur .youtube_id': (e,t)->
        parent = Template.parentData()
        val = t.$('.youtube_id').val()
        doc = Docs.findOne parent._id
        user = Meteor.users.findOne parent._id
        if doc
            Docs.update parent._id,
                $set:"#{@key}":val
        else if user
            Meteor.users.update parent._id,
                $set:"#{@key}":val


Template.children_view.onCreated ->
    # @autorun => Meteor.subscribe 'children', @data.ref_schema, Template.parentData(5)._id
    @autorun => Meteor.subscribe 'child_docs', Template.parentData(5)._id
    @autorun => Meteor.subscribe 'schema_from_slug', @data.ref_schema
    @autorun => Meteor.subscribe 'schema_bricks_from_slug', @data.ref_schema

Template.children_view.onRendered ->
    Meteor.setTimeout ->
        $('.accordion').accordion()
    , 1000

Template.html_view.onRendered ->
    Meteor.setTimeout ->
        $('.accordion').accordion()
    , 1000

Template.textarea_view.onRendered ->
    Meteor.setTimeout ->
        $('.accordion').accordion()
    , 1000

Template.children_view.helpers
    children: ->
        field = @
        # if Template.parentData(5)
        # else
        #     parent = Template.parentData()
        Docs.find {
            type: @ref_schema
            parent_id: parent._id
            # view_roles:$in:Meteor.user().roles
        }, sort:rank:1


Template.children_edit.onCreated ->
    console.log @data
    @autorun => Meteor.subscribe 'children', @data.ref_schema, Template.parentData(5)._id
    @autorun => Meteor.subscribe 'child_docs', Template.parentData(5)._id
    @autorun => Meteor.subscribe 'schema_from_slug', @data.ref_schema
    @autorun => Meteor.subscribe 'schema_bricks_from_slug', @data.ref_schema

Template.children_edit.onRendered ->
    Meteor.setTimeout ->
        $('.accordion').accordion()
    , 1000

Template.children_edit.helpers
    children: ->
        field = @
        # if Template.parentData(5)
        # else
        #     parent = Template.parentData()
        Docs.find {
            type: @ref_schema
            parent_id: parent._id
            # view_roles:$in:Meteor.user().roles
        }, sort:rank:1


Template.children_edit.events
    'click .add_child': ->
        # console.log @
        new_id = Docs.insert
            type: @ref_schema
            parent_id: parent._id
            parent_type:Router.current().params.type
        # console.log new_id




Template.single_doc_view.onCreated ->
    # @autorun => Meteor.subscribe 'type', @data.ref_schema

Template.single_doc_view.helpers
    choices: ->
        console.log @ref_schema
        Docs.find
            type:@ref_schema




Template.single_doc_edit.onCreated ->
    @autorun => Meteor.subscribe 'type', @data.ref_schema

Template.single_doc_edit.helpers
    choices: ->
        # console.log @ref_schema
        if @ref_schema
            Docs.find
                type:@ref_schema
                # tribe:Router.current().params.tribe_slug

    choice_class: ->
        selection = @
        current = Template.currentData()
        parent = Template.parentData()
        ref_field = Template.parentData(1)
        target = Template.parentData(2)
        # console.log @
        # console.log parent
        # console.log ref_field
        # console.log target

        if target["#{ref_field.key}"]
            # console.log target["#{ref_field.key}"]
            if @slug is target["#{ref_field.key}"] then 'teal' else ''


Template.single_doc_edit.events
    'click .select_choice': ->
        selection = @
        parent = Template.parentData(1)
        ref_field = Template.currentData()

        # console.log parent
        # console.log ref_field
        # console.log @
        # console.log parent["#{@key}"]

        if parent["#{ref_field.key}"] and @slug in parent["#{ref_field.key}"]
            doc = Docs.findOne parent._id
            user = Meteor.users.findOne parent._id
            if doc
                Docs.update parent._id,
                    $unset:"#{ref_field.key}":1
            else if user
                Meteor.users.update parent._id,
                    $unset: "#{ref_field.key}":1
        else
            doc = Docs.findOne parent._id
            user = Meteor.users.findOne parent._id

            if doc
                Docs.update parent._id,
                    $set: "#{ref_field.key}": @slug
            else if user
                Meteor.users.update parent._id,
                    $set: "#{ref_field.key}": @slug


Template.multi_doc_view.onCreated ->
    @autorun => Meteor.subscribe 'type', @data.ref_schema

Template.multi_doc_view.helpers
    choices: ->
        console.log @ref_schema
        Docs.find
            type:@ref_schema


# Template.multi_doc_edit.onRendered ->
#     $('.ui.dropdown').dropdown(
#         clearable:true
#         action: 'activate'
#         onChange: (text,value,$selectedItem)->
#             console.log text
#             console.log value
#             console.log $selectedItem
#         )



Template.multi_doc_edit.onCreated ->
    @autorun => Meteor.subscribe 'type', @data.ref_schema



Template.multi_doc_edit.helpers
    choices: ->
        # console.log @ref_schema
        Docs.find type:@ref_schema

    choice_class: ->
        selection = @
        current = Template.currentData()
        parent = Template.parentData()
        ref_field = Template.parentData(1)
        target = Template.parentData(2)
        # console.log @
        # console.log parent
        # console.log ref_field
        # console.log target

        if target["#{ref_field.key}"]
            # console.log target["#{ref_field.key}"]
            if @slug in target["#{ref_field.key}"] then 'teal' else ''


Template.multi_doc_edit.events
    'click .select_choice': ->
        selection = @
        parent = Template.parentData(1)
        ref_field = Template.currentData()

        # console.log parent
        # console.log ref_field
        # console.log @
        # console.log parent["#{@key}"]

        if parent["#{ref_field.key}"] and @slug in parent["#{ref_field.key}"]
            doc = Docs.findOne parent._id
            user = Meteor.users.findOne parent._id
            if doc
                Docs.update parent._id,
                    $pull:"#{ref_field.key}":@slug
            else if user
                Meteor.users.update parent._id,
                    $pull: "#{ref_field.key}": @slug
        else
            doc = Docs.findOne parent._id
            user = Meteor.users.findOne parent._id

            if doc
                Docs.update parent._id,
                    $addToSet: "#{ref_field.key}": @slug
            else if user
                Meteor.users.update parent._id,
                    $addToSet: "#{ref_field.key}": @slug




Template.code_edit.onRendered ->
    ace.require("ace/ext/language_tools")

    editor = ace.edit('ace')
    editor.session.setMode("ace/mode/html")
    editor.setTheme("ace/theme/twilight")
    editor.setOptions({
        enableBasicAutocompletion: true,
        enableSnippets: true,
        enableLiveAutocompletion: false
    })


Template.single_user_edit.onCreated ->
    @user_results = new ReactiveVar

Template.single_user_edit.helpers
    user_results: ->
        user_results = Template.instance().user_results.get()
        user_results



Template.single_user_edit.events
    'click .clear_results': (e,t)->
        t.user_results.set null

    'keyup #single_user_select_input': (e,t)->
        search_value = $(e.currentTarget).closest('#single_user_select_input').val().trim()
        Meteor.call 'lookup_user', search_value, (err,res)=>
            if err then console.error err
            else
                t.user_results.set res


    'click .select_user': (e,t) ->
        page_doc = Docs.findOne Router.current().params.id

        # console.log @

        val = t.$('.edit_text').val()
        parent = Template.parentData()

        Docs.update parent._id,
            $set:"#{@key}":@_id

        t.user_results.set null
        $('#single_user_select_input').val ''
        # Docs.update page_doc._id,
        #     $set: assignment_timestamp:Date.now()



    'click .pull_user': ->
        parent = Template.currentData(0)
        if confirm "Remove #{@username}?"
            page_doc = Docs.findOne Router.current().params.id
            Meteor.call 'unassign_user', page_doc._id, @



Template.doc_edit.onCreated ->
    @autorun => Meteor.subscribe 'document_by_slug', @data.key


Template.doc_edit.onRendered ->
    Meteor.setTimeout ->
        $('.accordion').accordion()
    , 1000

Template.doc_edit.helpers
    referenced_document: ->
        Docs.findOne
            type:'document'
            slug:@key




Template.doc_view.onCreated ->
    @autorun => Meteor.subscribe 'document_by_slug', @data.key
Template.doc_view.onRendered ->
    Meteor.setTimeout ->
        $('.accordion').accordion()
    , 1000

Template.doc_view.helpers
    referenced_document: ->
        Docs.findOne
            type:'document'
            slug:@key






Template.single_person_edit.onCreated ->
    @person_results = new ReactiveVar

Template.single_person_edit.helpers
    # selected_person: ->
    #     parent = Template.parentData()
    #     # val = t.$('.edit_date').val()
    #     brick = Template.parentData(4)
    #     parent = Template.parentData(5)

    #     if brick
    #         Docs.update parent._id,
    #             $set:"#{@key}":val
    #     else
    #         Docs.update parent._id,
    #             $set:"#{@key}":val


    person_results: ->
        person_results = Template.instance().person_results.get()
        person_results

Template.single_person_edit.events
    'click .clear_results': (e,t)->
        t.person_results.set null

    'click .clear_selection': (e,t)->
        if confirm "Clear Selection?"
            Docs.update parent._id,
                $unset:"#{@key}":1

    'keyup #single_person_select_input': (e,t)->
        search_value = $(e.currentTarget).closest('#single_person_select_input').val().trim()
        Meteor.call 'lookup_username', search_value, (err,res)=>
            if err then console.error err
            else
                t.person_results.set res


    'click .select_person': (e,t) ->
        page_doc = Docs.findOne Router.current().params.id
        val = t.$('.edit_text').val()
        parent = Template.parentData()

        Docs.update parent._id,
            $set:"#{@key}":@_id
        # else
        #     Docs.update parent._id,
        #         $set:"#{@key}":val

        t.person_results.set null
        $('#single_person_select_input').val ''
        # Docs.update page_doc._id,
        #     $set: assignment_timestamp:Date.now()



    'click .pull_user': ->
        parent = Template.currentData(0)
        if confirm "Remove #{@username}?"
            page_doc = Docs.findOne Router.current().params.id
            Meteor.call 'unassign_user', page_doc._id, @







Template.multi_user_edit.onCreated ->
    @user_results = new ReactiveVar

Template.multi_user_edit.helpers
    user_results: ->
        user_results = Template.instance().user_results.get()
        user_results



Template.multi_user_edit.events
    'click .clear_results': (e,t)->
        t.user_results.set null

    'keyup #multi_user_select_input': (e,t)->
        search_value = $(e.currentTarget).closest('#multi_user_select_input').val().trim()
        Meteor.call 'lookup_user', search_value, (err,res)=>
            if err then console.error err
            else
                t.user_results.set res


    'click .select_user': (e,t) ->
        page_doc = Docs.findOne Router.current().params.id

        # console.log @

        val = t.$('.edit_text').val()
        parent = Template.parentData()

        doc = Docs.findOne parent._id
        user = Meteor.users.findOne parent._id
        if doc
            Docs.update parent._id,
                $addToSet:"#{@key}":@_id
        else if user
            Meteor.users.update parent._id,
                $addToSet:"#{@key}":@_id


        t.user_results.set null
        $('#multi_user_select_input').val ''
        # Docs.update page_doc._id,
        #     $set: assignment_timestamp:Date.now()



    'click .pull_user': ->
        if confirm "Remove #{@username}?"
            page_doc = Docs.findOne Router.current().params.id
            parent = Template.parentData()
            doc = Docs.findOne parent._id
            user = Meteor.users.findOne parent._id
            if doc
                Docs.update parent._id,
                    $pull:"#{@key}":@_id
            else if user
                Meteor.users.update parent._id,
                    $pull:"#{@key}":@_id


            # Meteor.call 'unassign_user', page_doc._id, @
