Meteor.methods
    fum: (delta_id)->
        # console.log 'running fum', delta_id
        delta = Docs.findOne delta_id
        # console.log delta
        model = Docs.findOne
            model:'model'
            slug:delta.model_filter
        console.log model
        fields =
            Docs.find
                model:'field'
                parent_id:model._id
        console.log 'fields', fields.fetch()
        for field in fields.fetch()
            console.log 'adding field to delta', field.key
            Docs.update delta_id,
                $addToSet:
                    facets: {
                        key:field.key
                        filters:[]
                        res:[]
                    }
        # console.log 'delta', delta
        built_query = { model:delta.model_filter }


        for facet in delta.facets
            # console.log 'this facet', facet.key
            if facet.filters.length > 0
                built_query["#{facet.key}"] = $all: facet.filters

        total = Docs.find(built_query).count()
        console.log 'built query', built_query

        # response
        for facet in delta.facets
            values = []
            local_return = []

            # agg_res = Meteor.call 'agg', built_query, facet.key, model.collection
            agg_res = Meteor.call 'agg', built_query, facet.key

            if agg_res
                Docs.update { _id:delta._id, 'facets.key':facet.key},
                    { $set: 'facets.$.res': agg_res }

        modifier =
            {
                fields:_id:1
                limit:20
                sort:_timestamp:-1
            }

        # results_cursor =
        #     Docs.find( built_query, modifier )

        if model and model.collection and model.collection is 'users'
            results_cursor = Meteor.users.find(built_query, modifier)
            # else
            #     results_cursor = global["#{model.collection}"].find(built_query, modifier)
        else
            results_cursor = Docs.find built_query, modifier


        # if total is 1
        #     result_ids = results_cursor.fetch()
        # else
        #     result_ids = []
        result_ids = results_cursor.fetch()

        console.log 'result ids', result_ids
        console.log 'delta', delta
        # console.log Meteor.userId()

        Docs.update {_id:delta._id},
            {$set:
                total: total
                result_ids:result_ids
            }, ->
        return true


        # delta = Docs.findOne delta_id
        # console.log 'delta', delta

    agg: (query, key, collection)->
        limit=42
        console.log 'agg query', query
        console.log 'agg key', key
        console.log 'agg collection', collection
        options = { explain:false }
        pipe =  [
            { $match: query }
            { $project: "#{key}": 1 }
            { $unwind: "$#{key}" }
            { $group: _id: "$#{key}", count: $sum: 1 }
            { $sort: count: -1, _id: 1 }
            { $limit: limit }
            { $project: _id: 0, name: '$_id', count: 1 }
        ]
        if pipe
            if collection and collection is 'users'
                agg = Meteor.users.rawCollection().aggregate(pipe,options)
            else
                agg = global['Docs'].rawCollection().aggregate(pipe,options)
            # else
            res = {}
            # console.log 'res', res
            if agg
                agg.toArray()
        else
            return null
