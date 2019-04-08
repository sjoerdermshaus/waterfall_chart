function update_config(obj)

% Default settings
obj.config.lineShort          = -1;
obj.config.barWidth           =  0.8;
obj.config.FaceAlpha          =  1;
obj.config.yGap               =  3;
obj.config.addLine            = false;
obj.config.facecolors         = [255 255 255; ...    %    white
                                   0 176 240; ...    %    total
                                 255   0   0; ...    % decrease
                                 146 208  80] / 255; % increase
obj.config.XTickLabelRotation = 0;
obj.config.grid               = 'off';
obj.config.labelFormat        = '%+.0f';
obj.config.labelTotalFormat   = '%.0f';
obj.config.interpreter        = 'tex';

% Overwrite default settings with user settings
f = fieldnames(obj.user_config);
for ii = 1:numel(f)
    obj.config.(f{ii}) = obj.user_config.(f{ii});
end

end

