Router.configure
    layoutTemplate: 'layout'
    notFoundTemplate: 'not_found'
    loadingTemplate: 'splash'
    trackPageView: true


Router.route '/chat', -> @render 'view_chats'
Router.route '/inbox', -> @render 'inbox'
Router.route '/register', -> @render 'register'
Router.route('enroll', {
    path: '/enroll-account/:token'
    template: 'reset_password'
    onBeforeAction: ()=>
        Meteor.logout()
        Session.set('_resetPasswordToken', this.params.token)
        @subscribe('enrolledUser', this.params.token).wait()
})
Router.route '/m/:model_slug', (->
    @layout 'layout'
    @render 'delta'
    ), name:'delta'

Router.route '/m/:model_slug/:doc_id/edit', -> @render 'model_edit'
Router.route '/m/:model_slug/:doc_id/view', -> @render 'model_view'


Router.route '/models', -> @render 'models'
Router.route '/model/edit/:doc_id', -> @render 'edit_model'



# Router.route '/user/:username', -> @render 'user'
Router.route '/edit/:doc_id', -> @render 'edit'
Router.route '/view/:doc_id', -> @render 'view'
Router.route '*', -> @render 'not_found'

# Router.route '/user/:username/m/:type', -> @render 'profile_layout', 'user_section'
Router.route '/add_resident', (->
    @layout 'layout'
    @render 'add_resident'
    ), name:'add_resident'
Router.route '/user/:username/m/:type', (->
    @layout 'profile_layout'
    @render 'user_section'
    ), name:'user_section'
Router.route '/user/:username/about', (->
    @layout 'profile_layout'
    @render 'user_about'
    ), name:'user_about'
Router.route '/user/:username/view', (->
    @layout 'profile_layout'
    @render 'user_about'
    ), name:'profile_view'
Router.route '/user/:username', (->
    @layout 'profile_layout'
    @render 'user_about'
    ), name:'user_home'
Router.route '/user/:username/stripe', (->
    @layout 'profile_layout'
    @render 'user_stripe'
    ), name:'user_stripe'
Router.route '/user/:username/blog', (->
    @layout 'profile_layout'
    @render 'user_blog'
    ), name:'user_blog'
Router.route '/user/:username/events', (->
    @layout 'profile_layout'
    @render 'user_events'
    ), name:'user_events'
Router.route '/user/:username/tags', (->
    @layout 'profile_layout'
    @render 'user_tags'
    ), name:'user_tags'
Router.route '/user/:username/tasks', (->
    @layout 'profile_layout'
    @render 'user_tasks'
    ), name:'user_tasks'
Router.route '/user/:username/connections', (->
    @layout 'profile_layout'
    @render 'user_connections'
    ), name:'user_connections'
Router.route '/user/:username/messages', (->
    @layout 'profile_layout'
    @render 'user_messages'
    ), name:'user_messages'
Router.route '/user/:username/notifications', (->
    @layout 'profile_layout'
    @render 'user_notifications'
    ), name:'user_notifications'
Router.route '/user/:username/chat', (->
    @layout 'profile_layout'
    @render 'user_chat'
    ), name:'user_chat'
Router.route '/user/:username/gallery', (->
    @layout 'profile_layout'
    @render 'user_gallery'
    ), name:'user_gallery'
Router.route '/user/:username/contact', (->
    @layout 'profile_layout'
    @render 'user_contact'
    ), name:'user_contact'
# Router.route '/user/:username/campaigns', (->
#     @layout 'profile_layout'
#     @render 'user_campaigns'
#     ), name:'user_campaigns'
Router.route '/checkin', -> @render 'goldrun'
Router.route '/user/:username/edit', -> @render 'user_edit'
Router.route '/p/:slug', -> @render 'page'
Router.route '/settings', -> @render 'settings'
# Router.route '/users', -> @render 'people'

Router.route '/login', -> @render 'login'

Router.route '/', (->
    @layout 'layout'
    @render 'home'
    ), name:'home'
