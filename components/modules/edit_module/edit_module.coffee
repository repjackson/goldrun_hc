FlowRouter.route '/module/edit/:module_id', action: (params) ->
    BlazeLayout.render 'layout',
        main: 'edit_module'




if Meteor.isClient
    Template.edit_module.onCreated ->
        self = @
        self.autorun ->
            self.subscribe 'module', FlowRouter.getParam('module_id')
    
    
    Template.edit_module.helpers
        module: ->
            Modules.findOne FlowRouter.getParam('module_id')
        
        getFEContext: ->
            @current_doc = Modules.findOne FlowRouter.getParam('module_id')
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
                        Modules.update { _id: self.current_doc._id }, $set: description: newHTML
                    false
                    # Stop Froala Editor from POSTing to the Save URL
            }
    
            
            
    Template.edit_module.events
        'click #save': ->
            FlowRouter.go "/module/view/#{@_id}"
    
    
        'blur #title': ->
            title = $('#title').val()
            Modules.update FlowRouter.getParam('module_id'),
                $set: title: title
                
        'blur #course': ->
            course = $('#course').val()
            Modules.update FlowRouter.getParam('module_id'),
                $set: course: course
                
        'change #module_number': (e) ->
            module_number = $('#module_number').val()
            int = parseInt module_number
            module_id = FlowRouter.getParam('module_id')
            Modules.update FlowRouter.getParam('module_id'),
                $set: module_number: int
            
                
        "change input[type='file']": (e) ->
            module_id = FlowRouter.getParam('module_id')
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
                        Modules.update module_id, $set: image_id: res.public_id
                    return
    
        'keydown #input_image_id': (e,t)->
            if e.which is 13
                module_id = FlowRouter.getParam('module_id')
                image_id = $('#input_image_id').val().toLowerCase().trim()
                if image_id.length > 0
                    Modules.update module_id,
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
                        Modules.update FlowRouter.getParam('module_id'), 
                            $unset: image_id: 1
    
                    else
                        throw new Meteor.Error "it failed miserably"
    
        #         console.log Cloudinary
        # 		Cloudinary.delete "37hr", (err,res) ->
        # 		    if err 
        # 		        console.log "Upload Error: #{err}"
        # 		    else
        #     			console.log "Upload Result: #{res}"
        #                 # Modules.update FlowRouter.getParam('module_id'), 
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
                module = Modules.findOne FlowRouter.getParam('module_id')
                Modules.remove module._id, ->
                    FlowRouter.go "/modules"
    
    
        'blur .froala-container': (e,t)->
            html = t.$('div.froala-reactive-meteorized-override').froalaEditor('html.get', true)
            
            # snippet = $('#snippet').val()
            # if snippet.length is 0
            #     snippet = $(html).text().substr(0, 300).concat('...')
            module_id = FlowRouter.getParam('module_id')
    
            Modules.update module_id,
                $set: 
                    description: html
                    # snippet: snippet
    
    
    
        'click #upload_widget_opener': (e,t)->
            cloudinary.openUploadWidget {
                cloud_name: 'facet'
                upload_preset: 'rodonu5a'
            }, (error, result) ->
                # console.log error, result
                Modules.update FlowRouter.getParam('module_id'),
                    $addToSet: image_array: $each: result
                    
                    
        'click #publish': ->
            Modules.update FlowRouter.getParam('module_id'),
                $set: published: true
    
        'click #unpublish': ->
            Modules.update FlowRouter.getParam('module_id'),
                $set: published: false
