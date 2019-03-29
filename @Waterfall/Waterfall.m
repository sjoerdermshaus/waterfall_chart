classdef Waterfall < handle
    %WATERFALLCHART Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        labels
        data
        t
        f
        config
    end
    
    methods
        function obj = Waterfall(labels, data, config)
            obj.labels = labels;
            obj.data = data;
            obj.config = config;
        end
        
        plot(obj)
    end
end

