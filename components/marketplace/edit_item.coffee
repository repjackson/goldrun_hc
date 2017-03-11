FlowRouter.route '/item/edit/:item_id', action: (params) ->
    BlazeLayout.render 'layout',
        main: 'edit_item'

FlowRouter.route '/item/view/:item_id', action: (params) ->
    BlazeLayout.render 'layout',
        main: 'view_item'


if Meteor.isClient
    Template.edit_item.onCreated ->
        @autorun -> Meteor.subscribe 'item', FlowRouter.getParam('item_id')
    
    
    Template.edit_item.helpers
        item: ->
            Items.findOne FlowRouter.getParam('item_id')
        
        getFEContext: ->
            @current_doc = Items.findOne FlowRouter.getParam('item_id')
            self = @
            {
                _value: self.current_doc.description
                _keepMarkers: true
                _className: 'froala-reactive-meteorized-override'
                toolbarInline: false
                initOnClick: false
                imageInsertButtons: ['imageBack', '|', 'imageByURL']
                tabSpaces: false
                height: 300
                '_onsave.before': (e, editor) ->
                    # Get edited HTML from Froala-Editor
                    newHTML = editor.html.get(true)
                    # Do something to update the edited value provided by the Froala-Editor plugin, if it has changed:
                    if !_.isEqual(newHTML, self.current_doc.description)
                        # console.log 'onSave HTML is :' + newHTML
                        Items.update { _id: self.current_doc._id }, $set: description: newHTML
                    false
                    # Stop Froala Editor from POSTing to the Save URL
            }
    
            
    
    
    
    Template.edit_item.events
        'click #save': ->
            FlowRouter.go "/item/view/#{@_id}"
    
    
        'blur #title': ->
            title = $('#title').val()
            Items.update FlowRouter.getParam('item_id'),
                $set: title: title
                
        'change #price': (e) ->
            price = $('#price').val()
            int = parseInt price
            Items.update FlowRouter.getParam('item_id'),
                $set: price: int
            
            
        'blur #body': ->
            body = $('#body').val()
            Items.update FlowRouter.getParam('item_id'),
                $set: body: body
            
            
                
        "change input[type='file']": (e) ->
            item_id = FlowRouter.getParam('item_id')
            files = e.currentTarget.files
    
    
            Cloudinary.upload files[0],
                # folder:"secret" # optional parameters described in http://cloudinary.com/documentation/upload_images#remote_upload
                # type:"private" # optional: makes the image accessible only via a signed url. The signed url is available publicly for 1 hour.
                (err,res) -> #optional callback, you can catch with the Cloudinary collection as well
                    # console.log "Upload Error: #{err}"
                    # console.dir res
                    if err
                        console.error 'Error uploading', err
                    else
                        Items.update item_id, $set: image_id: res.public_id
                    return
    
        'keydown #input_image_id': (e,t)->
            if e.which is 13
                item_id = FlowRouter.getParam('item_id')
                image_id = $('#input_image_id').val().toLowerCase().trim()
                if image_id.length > 0
                    Items.update item_id,
                        $set: image_id: image_id
                    $('#input_image_id').val('')
    
    
    
        'click #remove_photo': ->
            swal {
                title: 'Remove Photo?'
                type: 'warning'
                animation: false
                showCancelButton: true
                closeOnConfirm: true
                cancelButtonText: 'No'
                confirmButtonText: 'Remove'
                confirmButtonColor: '#da5347'
            }, =>
                Meteor.call "c.delete_by_public_id", @image_id, (err,res) ->
                    if not err
                        # Do Stuff with res
                        # console.log res
                        Items.update FlowRouter.getParam('item_id'), 
                            $unset: image_id: 1
    
                    else
                        throw new Meteor.Error "it failed miserably"
    
        #         console.log Cloudinary
        # 		Cloudinary.delete "37hr", (err,res) ->
        # 		    if err 
        # 		        console.log "Upload Error: #{err}"
        # 		    else
        #     			console.log "Upload Result: #{res}"
        #                 # Items.update FlowRouter.getParam('item_id'), 
        #                 #     $unset: image_id: 1
    

        'click #delete': ->
            swal {
                title: 'Delete?'
                # text: 'Confirm delete?'
                type: 'error'
                animation: false
                showCancelButton: true
                closeOnConfirm: true
                cancelButtonText: 'Cancel'
                confirmButtonText: 'Delete'
                confirmButtonColor: '#da5347'
            }, ->
                module = Items.findOne FlowRouter.getParam('item_id')
                Items.remove module._id, ->
                    FlowRouter.go "/modules"
    
    
        'blur .froala-container': (e,t)->
            html = t.$('div.froala-reactive-meteorized-override').froalaEditor('html.get', true)
            
            # snippet = $('#snippet').val()
            # if snippet.length is 0
            #     snippet = $(html).text().substr(0, 300).concat('...')
            item_id = FlowRouter.getParam('item_id')
    
            Items.update item_id,
                $set: 
                    description: html
    
    
        'keydown #add_tag': (e,t)->
            if e.which is 13
                item_id = FlowRouter.getParam('item_id')
                tag = $('#add_tag').val().toLowerCase().trim()
                if tag.length > 0
                    Items.update item_id,
                        $addToSet: tags: tag
                    $('#add_tag').val('')
    
        'click .doc_tag': (e,t)->
            tag = @valueOf()
            Items.update FlowRouter.getParam('item_id'),
                $pull: tags: tag
            $('#add_tag').val(tag)


        'click #publish': ->
            Items.update FlowRouter.getParam('item_id'),
                $set: published: true
    
        'click #unpublish': ->
            Items.update FlowRouter.getParam('item_id'),
                $set: published: false
