classdef Waterfall < handle
    %WATERFALLCHART Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        labels
        data
        idx_total
        t
        f
        config
    end
    
    methods
        function obj = Waterfall(labels, data, idx_total, config)
            obj.labels = labels;
            obj.data = data;
            obj.idx_total = idx_total;
            obj.config = config;
        end
        
        plot(obj)
    end
end

