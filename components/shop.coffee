if Meteor.isClient
    Template.shop_card.onCreated ->

    Template.shop.onRendered ->
        Meteor.setTimeout ->
            $('.accordion').accordion()
        , 1000

    Template.shop.onCreated ->
        # @autorun -> Meteor.subscribe 'shop'
        @autorun -> Meteor.subscribe 'docs', selected_tags.array(), 'shop'
    Template.shop.helpers
        products: ->
            Docs.find
                model:'shop'

    Template.shop.events
        'click .add_item': ->
            new_id = Docs.insert
                model:'shop'
            Router.go "/shop/#{new_id}/edit"


    Template.shop_edit.events
        'click .delete_shop_item': ->
            if confirm 'delete shop item?'
                Docs.remove @_id
                Router.go "/m/shop"


    Template.add_to_tab.onCreated ->
        @autorun => Meteor.subscribe 'model_docs', 'transaction'
    Template.add_to_tab.events
        'click .add_to_tab': ->
            Meteor.call 'create_transaction', @

        'click .remove_tab_item': ->
            Docs.remove @_id

    Template.add_to_tab.helpers
        current_tab_additions: ->
            # console.log @
            Docs.find
                model:'transaction'
                product_id:@_id







    Template.shop_card.onRendered ->
        Meteor.setTimeout ->
            $('.button').popup()
        , 3000

    Template.shop_card.events
        'click .add_to_cart': ->
            if Meteor.user()
                console.log @
                Docs.insert
                    model:'cart_item'
                    product_id:@_id
                $('body').toast({
                    title: "#{@title} added to cart."
                    # message: 'Please see desk staff for key.'
                    class : 'green'
                    # position:'top center'
                    # className:
                    #     toast: 'ui massive message'
                    displayTime: 5000
                    transition:
                      showMethod   : 'zoom',
                      showDuration : 250,
                      hideMethod   : 'fade',
                      hideDuration : 250
                    })
            else
                Router.go '/login'



    Template.shop_view_layout.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
    Template.shop_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
    Template.shop_view_layout.events
        'click .add_to_cart': ->
            console.log @
            Docs.insert
                model:'cart_item'
                product_id:@_id
            $('body').toast({
                title: "#{@title} added to cart."
                # message: 'Please see desk staff for key.'
                class : 'green'
                # position:'top center'
                # className:
                #     toast: 'ui massive message'
                displayTime: 5000
                transition:
                  showMethod   : 'zoom',
                  showDuration : 250,
                  hideMethod   : 'fade',
                  hideDuration : 250
                })



    Template.product_transactions.onRendered ->
        Template.children_view.onRendered ->
            Meteor.setTimeout ->
                $('.accordion').accordion()
            , 1000

    Template.product_transactions.onCreated ->
        @autorun => Meteor.subscribe 'product_transactions', Router.current().params.doc_id
    Template.product_transactions.events
        'click .add_transaction': ->
            console.log @
            Docs.insert
                model:'transaction'
                product_id: @_id
                transaction_type:'purchase'
            Meteor.call 'calculate_product_inventory_amount', @_id
    Template.product_transactions.helpers
        product_transactions: ->
            Docs.find
                model:'transaction'
                product_id: Router.current().params.doc_id


    Template.shop_stats.onCreated ->
        @autorun => Meteor.subscribe 'shop_stats', Router.current().params.doc_id
    Template.shop_stats.events
        'click .advise_price': ->
            Meteor.call 'advise_price', @_id

        'click .calculate_transaction_count': ->
            console.log @
            Meteor.call 'calculate_product_inventory_amount', @_id
    Template.shop_stats.helpers
        product_transactions: ->
            Docs.find
                model:'transaction'
                product_id: Router.current().params.doc_id



if Meteor.isServer
    Meteor.methods
        advise_price: (product_id)->
            product = Docs.findOne product_id
            advise_notes = 'not enough info'
            Meteor.call 'calculate_product_inventory_amount', product_id
            console.log 'transaction_count', product.transaction_count
            product = Docs.findOne product_id
            if product.transaction_count is 0
                advise_notes = 'no transactions found, not enough info to calculate new price'
                advise_notes = 'no transactions found, not enough info to calculate new price'
            else
                advise_notes = "found #{product.transaction_count} transactions, will calculate average"
                product_transactions =
                    Docs.find(
                        model:'transaction'
                        product_id:product_id
                        ).fetch()
                sales_total = 0
                for transaction in product_transactions
                    if transaction.paid_amount
                        console.log 'transaction sale price', transaction.paid_amount
                        sales_total += transaction.paid_amount

                average_sale_price = sales_total/product.transaction_count
            Docs.update product_id,
                $set:
                    advise_notes:advise_notes
                    sales_total:sales_total
                    average_sale_price:average_sale_price

        create_transaction: (product)->
            console.log product
            Docs.insert
                model:'transaction'
                product_id:product._id
                delivered:false

        calculate_product_inventory_amount: (product_id)->
            product = Docs.findOne product_id
            transaction_count =
                Docs.find(
                    model:'transaction'
                    product_id:product_id
                    ).count()
            console.log 'transaction_count',transaction_count
            console.log 'product_inventory',product.inventory
            if transaction_count>product.inventory
                Docs.update product_id,
                    $set:sold_out:true
            else
                Docs.update product_id,
                    $set:sold_out:false
            Docs.update product_id,
                $set:
                    transaction_count:transaction_count
                    inventory_available:product.inventory-transaction_count



    Meteor.publish 'product_transactions', (product_id)->
        Docs.find
            model:'transaction'
            product_id:product_id


    Meteor.publish 'shop', ->
        Docs.find
            model:'shop'
            active:true
