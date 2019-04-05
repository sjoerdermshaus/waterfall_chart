classdef Waterfall < handle
    %WATERFALLCHART Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        labels
        data
        idx_total
        t
        f
        user_config
        config
    end
    
    methods
        function obj = Waterfall(labels, data, idx_total, user_config)
            obj.labels = labels;
            obj.data = data;
            obj.idx_total = idx_total;
            obj.user_config = user_config;
            update_config(obj);
        end
        
        plot(obj)
        update_config(obj)
    end
end

