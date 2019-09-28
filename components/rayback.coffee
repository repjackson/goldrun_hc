Router.route '/rayback', (->
    @layout 'rayback-layout'
    @render 'rayback'
    ), name:'rayback'
Router.route '/beer/:doc_id/view', (->
    @layout 'rayback-layout'
    @render 'beer_view'
    ), name:'beer_view'


Router.route '/rayback_admin/', -> @render 'rayback_admin'

if Meteor.isClient
    Template.beer_view.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id

    Template.rayback.onCreated ->
        @autorun => Meteor.subscribe 'model_docs', 'beer'
        @autorun => Meteor.subscribe 'me'
    Template.rayback.onRendered ->
        Meteor.setInterval ->
            $('.section_icon')
              .transition({
                animation : 'pulse',
                reverse   : false,
                duration   : '2s',
                interval  : 5000
              })
        , 10000


    Template.menu_section.onCreated ->
    Template.menu_section.helpers
        beer_row_class: ->
            if @tapped
                'neg'
            else
                ''
        beers: ->
            Docs.find
                model:'beer'
                section: @section

    Template.menu_section.events
        'click .view_beer': ->
            Router.go "/beer/#{@_id}/view"
            # Router.go "/m/beer/#{@_id}/edit"


    Template.rayback.helpers
        drinks: ->
            Docs.find
                model:'drink'
    Template.rayback.events
        'click .rayback_logo': ->
            $('.rayback_logo')
              .transition({
                animation : 'pulse',
                duration: 1000
            })
