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
  except: ['register', 'forgot_password','reset_password','delta','doc_view','verify-email','download_rules_pdf']
});


Router.route "/add_guest/:new_guest_id", -> @render 'add_guest'

Router.route '/units', -> @render 'units'
Router.route '/add_karma', -> @render 'add_karma'
Router.route '/credit', -> @render 'credit'
Router.route '/alpha', -> @render 'alpha'
Router.route '/omega', -> @render 'omega'
Router.route '/transactions', -> @render 'transactions'
Router.route '/my_transactions', -> @render 'my_transactions'
Router.route '/chat', -> @render 'view_chats'
Router.route '/inbox', -> @render 'inbox'
Router.route '/register', -> @render 'register'
Router.route '/cart', -> @render 'cart'
Router.route '/tab', -> @render 'tab'
Router.route '/admin', -> @render 'admin'
Router.route '/dashboard', -> @render 'dashboard'
Router.route '/buildings', -> @render 'buildings'
Router.route '/games', -> @render 'games'
Router.route '/deliveries', -> @render 'deliveries'

Router.route '/unit/:unit_id', -> @render 'unit'
Router.route '/building/:building_code', -> @render 'building'

Router.route '/shop/:product_id/daily_calendar/:month/:day/:year/', -> @render 'product_day'
Router.route '/game/:game_slug', -> @render 'game'

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
                alert 'email verified'
                @next()
                # Router.go "/user/#{Meteor.user().username}"
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
Router.route '/omega_doc_edit/:doc_id', -> @render 'omega_doc_edit'
Router.route '/edit/:doc_id', -> @render 'edit'
Router.route '/view/:doc_id', -> @render 'view'
Router.route '*', -> @render 'not_found'

# Router.route '/user/:username/m/:type', -> @render 'profile_layout', 'user_section'
Router.route '/add_resident', (->
    @layout 'layout'
    @render 'add_resident'
    ), name:'add_resident'
Router.route '/forgot_password', -> @render 'forgot_password'

Router.route '/reddit', -> @render 'reddit'
Router.route '/staff', -> @render 'staff'
Router.route '/groups', -> @render 'groups'
Router.route '/meals', -> @render 'meals'
Router.route '/events', -> @render 'cal'
Router.route '/frontdesk', -> @render 'frontdesk'
Router.route '/user/:username/edit', -> @render 'user_edit'
Router.route '/p/:slug', -> @render 'page'
Router.route '/settings', -> @render 'settings'
Router.route '/sign_rules/:doc_id/:username', -> @render 'rules_signing'
Router.route '/sign_guidelines/:doc_id/:username', -> @render 'guidelines_signing'
# Router.route '/users', -> @render 'people'
Router.route '/sign_waiver/:receipt_id', -> @render 'sign_waiver'
# Router.route "/meal/:meal_id", -> @render 'meal_doc'

Router.route "/meal/:doc_id/view", (->
    @render 'meal_view'
    ), name:'meal_view'

Router.route '/reset_password/:token', (->
    @render 'reset_password'
    ), name:'reset_password'

Router.route '/download_rules_pdf/:username', (->
    @render 'download_rules_pdf'
    ), name: 'download_rules_pdf'


Router.route "/meal/:doc_id/edit", (->
    @render 'meal_edit'
    ), name:'meal_edit'


Router.route "/shop", (->
    @render 'shop'
    ), name:'shop'
Router.route "/shop/:doc_id/view", (->
    @layout 'shop_view_layout'
    @render 'shop_info'
    ), name:'shop_view_info'
Router.route "/shop/:doc_id/info", (->
    @layout 'shop_view_layout'
    @render 'shop_info'
    ), name:'shop_info'
Router.route "/shop/:doc_id/rentals", (->
    @layout 'shop_view_layout'
    @render 'shop_rentals'
    ), name:'shop_rentals'
Router.route "/shop/:doc_id/earnings", (->
    @layout 'shop_view_layout'
    @render 'shop_earnings'
    ), name:'shop_earnings'
Router.route "/shop/:doc_id/chat", (->
    @layout 'shop_view_layout'
    @render 'shop_chat'
    ), name:'shop_chat'
Router.route "/shop/:doc_id/projections", (->
    @layout 'shop_view_layout'
    @render 'shop_projections'
    ), name:'shop_projections'
Router.route "/shop/:doc_id/ownership", (->
    @layout 'shop_view_layout'
    @render 'product_ownership'
    ), name:'product_ownership'
Router.route "/shop/:doc_id/ads", (->
    @layout 'shop_view_layout'
    @render 'product_ads'
    ), name:'product_ads'
Router.route "/shop/:doc_id/tasks", (->
    @layout 'shop_view_layout'
    @render 'shop_tasks'
    ), name:'shop_tasks'
Router.route "/shop/:doc_id/stats", (->
    @layout 'shop_view_layout'
    @render 'shop_stats'
    ), name:'shop_stats'
Router.route "/shop/:doc_id/edit", (->
    @render 'shop_edit'
    ), name:'shop_edit'



Router.route '/login', -> @render 'login'

# Router.route '/', -> @redirect '/m/model'
# Router.route '/', -> @redirect "/user/#{Meteor.user().username}"
Router.route '/home', -> @render 'home'
Router.route '/', (->
    @layout 'layout'
    @render 'front'
    ), name:'front'


Router.route '/healthclub', (->
    @layout 'mlayout'
    @render 'kiosk_container'
    ), name:'healthclub'


Router.route '/healthclub_session/:doc_id', (->
    @layout 'mlayout'
    @render 'healthclub_session'
    ), name:'healthclub_session'


Router.route '/user/:username', (->
    @layout 'user_layout'
    @render 'user_about'
    ), name:'user_about'


Router.route '/user/:username/karma', (->
    @layout 'user_layout'
    @render 'user_karma'
    ), name:'user_karma'

Router.route '/user/:username/healthclub', (->
    @layout 'user_layout'
    @render 'user_healthclub'
    ), name:'user_healthclub'

Router.route '/user/:username/tags', (->
    @layout 'user_layout'
    @render 'user_tags'
    ), name:'user_tags'
Router.route '/user/:username/residency', (->
    @layout 'user_layout'
    @render 'user_residency'
    ), name:'user_residency'
Router.route '/user/:username/transactions', (->
    @layout 'user_layout'
    @render 'user_transactions'
    ), name:'user_transactions'
Router.route '/user/:username/documents', (->
    @layout 'user_layout'
    @render 'user_documents'
    ), name:'user_documents'
Router.route '/user/:username/contact', (->
    @layout 'user_layout'
    @render 'user_contact'
    ), name:'user_contact'
Router.route '/user/:username/products', (->
    @layout 'user_layout'
    @render 'user_products'
    ), name:'user_products'
Router.route '/user/:username/comparison', (->
    @layout 'user_layout'
    @render 'user_comparison'
    ), name:'user_comparison'
