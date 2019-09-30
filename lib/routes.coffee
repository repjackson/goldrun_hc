Router.configure
    layoutTemplate: 'layout'
    notFoundTemplate: 'not_found'
    loadingTemplate: 'splash'
    trackPageView: true

force_loggedin =  ()->
    if !Meteor.userId()
        @render 'login'
    else
        @next()

Router.onBeforeAction(force_loggedin, {
  # only: ['admin']
  # except: ['register', 'forgot_password','reset_password','front','delta','doc_view','verify-email']
  except: ['register'
    'home'
    'beer_view'
    'front'
    'forgot_password'
    'reset_password'
    'products'
    'delta'
    'shop_view'
    'market'
    'rayback'
    'projects'
    'services'
    'products'
    'shop_view'
    'shop_info'
    'rental_earnings'
    'rental_chat'
    'rental_projections'
    'rental_ownership'
    'rental_ads'
    'rental_tasks'
    'rental_stats'
    'service_view'
    'shop'
    'project_view'
    'doc_view'
    'work_order_edit'
    'work_order_view'
    'rental_view'
    'rental_view_info'
    'kiosk_rental_view'
    'shop_earning'
    'rentals'
    'rental_view'
    'rental_view_info'
    'rental_view_stats'
    'rental_view_finance'
    'rental_view_ads'
    'rental_view_availability'
    'rental_view_tasks'
    'rental_view_audience'
    'rental_view_ownership'
    'rental_view_chat'
    'events'
    'kiosk_rental_view'
    'grid'
    'event_edit'
    'event_view'
    'service_view'
    'projects'
    'project_feed'
    'project_finance'
    'project_files'
    'project_chat'
    'project_photos'
    'work_orders'
    'dev'
    'verify-email'
    'download_rules_pdf'
  ]
});

Router.route "/add_guest/:new_guest_id", -> @render 'add_guest'

Router.route '/inbox', -> @render 'inbox'
Router.route '/register', -> @render 'register'
Router.route '/grid', -> @render 'grid'
Router.route '/admin', -> @render 'admin'
Router.route '/timecard', -> @render 'timecard'
Router.route '/stats', -> @render 'stats'
Router.route '/dashboard', -> @render 'dashboard'
Router.route '/manager', -> @render 'manager'
Router.route '/shift_checklist', -> @render 'shift_checklist'

Router.route '/building/:building_code', -> @render 'building'


Router.route('enroll', {
    path: '/enroll-account/:token'
    template: 'reset_password'
    onBeforeAction: ()=>
        Meteor.logout()
        Session.set('_resetPasswordToken', this.params.token)
        @subscribe('enrolledUser', this.params.token).wait()
})


Router.route('verify-email', {
    path:'/verify-email/:token',
    onBeforeAction: ->
        console.log @
        # Session.set('_resetPasswordToken', this.params.token)
        # @subscribe('enrolledUser', this.params.token).wait()
        console.log @params
        Accounts.verifyEmail(@params.token, (err) =>
            if err
                console.log err
                alert err
                @next()
            else
                # alert 'email verified'
                # @next()
                Router.go "/verification_confirmation/"
        )
})


Router.route '/m/:model_slug', (->
    @render 'delta'
    ), name:'delta'
Router.route '/m/:model_slug/:doc_id/edit', -> @render 'model_doc_edit'
Router.route '/m/:model_slug/:doc_id/view', (->
    @render 'model_doc_view'
    ), name:'doc_view'
Router.route '/model/edit/:doc_id', -> @render 'model_edit'

# Router.route '/user/:username', -> @render 'user'
Router.route '/verification_confirmation', -> @render 'verification_confirmation'
Router.route '*', -> @render 'not_found'

# Router.route '/user/:username/m/:type', -> @render 'profile_layout', 'user_section'
Router.route '/add_resident', (->
    @layout 'layout'
    @render 'add_resident'
    ), name:'add_resident'
Router.route '/forgot_password', -> @render 'forgot_password'

Router.route '/staff', -> @render 'staff'
Router.route '/frontdesk', -> @render 'frontdesk'
Router.route '/p/:slug', -> @render 'page'
Router.route '/settings', -> @render 'settings'
Router.route '/sign_rules/:doc_id/:username', -> @render 'rules_signing'
Router.route '/sign_guidelines/:doc_id/:username', -> @render 'guidelines_signing'
Router.route '/sign_waiver/:receipt_id', -> @render 'sign_waiver'
# Router.route "/meal/:meal_id", -> @render 'meal_doc'

Router.route '/reset_password/:token', (->
    @render 'reset_password'
    ), name:'reset_password'

Router.route '/download_rules_pdf/:username', (->
    @render 'download_rules_pdf'
    ), name: 'download_rules_pdf'


Router.route '/login', -> @render 'login'

# Router.route '/', -> @redirect '/m/model'
# Router.route '/', -> @redirect "/user/#{Meteor.user().username}"
# Router.route '/', -> @render 'home'
Router.route '/', (->
    @layout 'layout'
    @render 'home'
    ), name:'home'


# Router.route '/resident_portal', (->
#     @layout 'layout'
#     @render 'resident_portal'
#     ), name:'root'

Router.route '/staff_home', (->
    @layout 'layout'
    @render 'staff_home'
    ), name:'staff_home'


Router.route '/healthclub', (->
    @layout 'mlayout'
    @render 'kiosk_container'
    ), name:'healthclub'


Router.route '/healthclub_session/:doc_id', (->
    @layout 'mlayout'
    @render 'healthclub_session'
    ), name:'healthclub_session'




Router.route '/shop/:product_id/daily_calendar/:month/:day/:year/', -> @render 'product_day'
