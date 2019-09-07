Router.route '/view_slideshow', (->
    @layout 'mlayout'
    @render 'view_slideshow'
    ), name:'view_slideshow'


Router.route '/slideshow/', -> @render 'slideshow'
Router.route '/slide/:doc_id/view', -> @render 'slide_view'
Router.route '/slide/:doc_id/edit', -> @render 'slide_edit'


if Meteor.isClient
    Template.slideshow.onCreated ->
        @autorun -> Meteor.subscribe 'model_docs', 'slide'


    Template.slideshow.onRendered ->
        Meteor.setTimeout ->
            $('.accordion').accordion()
        , 1000




    Template.slide_view.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
    Template.slide_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
    Template.slideshow.helpers
        slideshow: ->
            Docs.find
                model:'slide'

    Template.slideshow.events
        'click .add_slide': ->
            new_id = Docs.insert
                model:'slide'
            Router.go "/slide/#{new_id}/edit"

        'click .select_slide': ->
            Session.set 'current_slide_id', @_id

        'click .slideshow': ->
            Meteor.call 'slideshow', ->



    Template.slideshow.helpers
        slide_menu_item_class: ->
            if Session.equals('current_slide_id', @_id) then 'active' else ''
        current_slide: ->
            Docs.findOne Session.get('current_slide_id')
        slides: ->
            Docs.find {model:'slide'},
                sort: _timestamp: -1
                limit:10




    Template.slider.onRendered ->
        Meteor.setTimeout (->
            $('#layerslider').layerSlider
                autoStart: true
                # firstLayer: 1
                # skin: 'borderlesslight'
                # skinsPath: '/static/layerslider/skins/'
            ), 5000


    Router.route '/slider', (->
        @layout 'mlayout'
        @render 'slider'
        ), name:'slider'



    Template.slides.onCreated ->
        @autorun -> Meteor.subscribe('facet', selected_tags.array(), 'slide')

    Template.slider.onCreated ->
        @autorun -> Meteor.subscribe('model_docs', 'slide')

    Template.slider.helpers
        slides: ->
            Docs.find
                model: 'slide'

    Template.slides.helpers
        slides: -> Docs.find {model: 'slide'}


    Template.slides.events
        'click #add_slide': ->
            id = Docs.insert
                model: 'slide'
            Router.go "/slide/#{id}"
            Session.set 'editing_id', id



    Template.slide.onCreated ->
        @autorun -> Meteor.subscribe 'doc', Router.current().params.doc_id

    Template.slide.helpers
        slide: -> Docs.findOne Router.current().params.doc_id


    Template.slide.events
        'click #delete': ->
            swal {
                title: 'delete slide?'
                # text: 'Confirm delete?'
                type: 'error'
                animation: false
                showCancelButton: true
                closeOnConfirm: true
                cancelButtonText: 'cancel'
                confirmButtonText: 'delete'
                confirmButtonColor: '#da5347'
            }, ->
                doc = Docs.findOne Router.current().params.doc_id
                Docs.remove doc._id, ->
                    Router.go "/slides"



    # Router.route '/slide/:doc_id', action: (params) ->
    #     BlazeLayout.render 'layout',
    #         main: 'slide'

    Template.slide.onCreated ->
        @autorun -> Meteor.subscribe 'doc', Router.current().params.doc_id

    Template.slide.helpers
        slide: -> Docs.findOne Router.current().params.doc_id


    Template.slide.events
        'click #delete_slide': ->
            swal {
                title: 'delete?'
                # text: 'Confirm delete?'
                type: 'error'
                animation: false
                showCancelButton: true
                closeOnConfirm: true
                cancelButtonText: 'Cancel'
                confirmButtonText: 'Delete'
                confirmButtonColor: '#da5347'
            }, ->
                slide = Docs.findOne Router.current().params.doc_id
                Docs.remove slide._id, ->
                    Router.go "/slides"