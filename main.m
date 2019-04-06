function main

%% Create waterfall_default.png
% Generate random data
N     =  10;
data0 = 200;
mu    = -40;
sigma =  60;
[labels, data, idx_total] = create_random_data(N, data0, mu, sigma);

% Customize the plot via config
config.title              = 'Waterfall Chart';
config.ylim               = [data0 - 250 data0 + 50];
config.yGap               = 0; 
config.addLine            = true;
config.grid               = 'off';
config.XTickLabelRotation = 90;
config.interpreter        = 'latex';

% Create the plot with default colors
wf = Waterfall(labels, data, idx_total, config);
plot(wf);
saveas(wf.f, 'waterfall_default.png');
close(wf.f);

%% Create waterfall_google.png
% Generate random data
delta_data0 = -150;
data0       = data0 + delta_data0;
[labels, data, idx_total] = create_random_data(N, data0, mu, sigma);

% Customize the plot via config
config.ylim               = config.ylim + delta_data0;
config.facecolors         = [255 255 255; ...    %          white
                              66 133 244; ...    %    total blue
                             234  67  53; ...    % decrease red
                              52 168  83] / 255; % increase green
config.XTickLabelRotation = 45;
config.FaceAlpha          = 0.80;
config.grid               = 'on'; 

% Create the plot with google colors
wf = Waterfall(labels, data, idx_total, config);
plot(wf);
saveas(wf.f, 'waterfall_google.png');
close(wf.f);

end

function [labels, data, idx_total] = create_random_data(N, data0, mu, sigma)

rng(1234);

% Generate random data
delta         = normrnd(mu, sigma, N, 1);
data          = [data0; delta];
data(N + 2)   = sum(data);
labels        = cell(N + 2, 1);
labels{1}     = 'StartTotal';
labels{N + 2} = 'EndTotal';
for ii = 2:N + 1
    labels{ii} = sprintf('Delta%.0f', ii - 1);
end

% Add a subtotal column
r         = round(N / 2 + 1);
data      = [data(1: r); sum(data(1: r)); data(r + 1: N + 2)];
labels    = [labels(1:r); {'SubTotal'}; labels(r + 1:N + 2)];
idx_total = [1 r + 1 N + 3];

end