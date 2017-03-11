FlowRouter.route '/edit_product/:doc_id', action: (params) ->
    BlazeLayout.render 'layout',
        main: 'edit_product'

FlowRouter.route '/view_product/:doc_id', action: (params) ->
    BlazeLayout.render 'layout',
        main: 'view_product'


if Meteor.isClient
    Template.edit_product.onCreated ->
        self = @
        self.autorun ->
            self.subscribe 'doc', FlowRouter.getParam('doc_id')
    
    
    Template.edit_product.helpers
        product: ->
            Docs.findOne FlowRouter.getParam('doc_id')
        
        getFEContext: ->
            @current_doc = Docs.findOne FlowRouter.getParam('doc_id')
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
                        Docs.update { _id: self.current_doc._id }, $set: description: newHTML
                    false
                    # Stop Froala Editor from POSTing to the Save URL
            }
    
            
    
    
    
    Template.edit_product.events
        'click #save': ->
            FlowRouter.go "/view_product/#{@_id}"
    
    
        'blur #title': ->
            title = $('#title').val()
            Docs.update FlowRouter.getParam('doc_id'),
                $set: title: title
                
        'change #price': (e) ->
            price = $('#price').val()
            int = parseInt price
            Docs.update FlowRouter.getParam('doc_id'),
                $set: price: int
            
                
        "change input[type='file']": (e) ->
            doc_id = FlowRouter.getParam('doc_id')
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
                        Docs.update doc_id, $set: image_id: res.public_id
                    return
    
        'keydown #input_image_id': (e,t)->
            if e.which is 13
                doc_id = FlowRouter.getParam('doc_id')
                image_id = $('#input_image_id').val().toLowerCase().trim()
                if image_id.length > 0
                    Docs.update doc_id,
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
                        Docs.update FlowRouter.getParam('doc_id'), 
                            $unset: image_id: 1
    
                    else
                        throw new Meteor.Error "it failed miserably"
    
        #         console.log Cloudinary
        # 		Cloudinary.delete "37hr", (err,res) ->
        # 		    if err 
        # 		        console.log "Upload Error: #{err}"
        # 		    else
        #     			console.log "Upload Result: #{res}"
        #                 # Docs.update FlowRouter.getParam('doc_id'), 
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
                module = Docs.findOne FlowRouter.getParam('doc_id')
                Docs.remove module._id, ->
                    FlowRouter.go "/modules"
    
    
        'blur .froala-container': (e,t)->
            html = t.$('div.froala-reactive-meteorized-override').froalaEditor('html.get', true)
            
            # snippet = $('#snippet').val()
            # if snippet.length is 0
            #     snippet = $(html).text().substr(0, 300).concat('...')
            doc_id = FlowRouter.getParam('doc_id')
    
            Docs.update doc_id,
                $set: 
                    description: html
                    # snippet: snippet
    
    
    

        'click #publish': ->
            Docs.update FlowRouter.getParam('doc_id'),
                $set: published: true
    
        'click #unpublish': ->
            Docs.update FlowRouter.getParam('doc_id'),
                $set: published: false
