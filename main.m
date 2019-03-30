function main

N = 10;
data0 = 40;
mu = -40;
sigma = 200;
[labels, data, idx_total] = create_random_data(N, data0, mu, sigma);

%% Customize the plot via config
% More options can be added to plot.m
config.title = 'My beautiful waterfall';
config.ylim = [-300 500];
config.XTickLabelRotation = 90;
config.ygap = 0; 

%% Create the plot with default colors
my_waterfall = Waterfall(labels, data, idx_total, config);
plot(my_waterfall);
saveas(my_waterfall.f, 'waterfall_default.png');
close(my_waterfall.f);

%% Create the plot with Google colors
my_waterfall.config.facecolors.blue = [66, 133, 244];
my_waterfall.config.facecolors.red = [234, 67, 53];
my_waterfall.config.facecolors.green = [52,168,83];
my_waterfall.config.XTickLabelRotation = 45;
my_waterfall.config.barWidth = 1;
my_waterfall.config.addLine = true;

plot(my_waterfall);
saveas(my_waterfall.f, 'waterfall_google.png');
close(my_waterfall.f);

end

function [labels, data, idx_total] = create_random_data(N, data0, mu, sigma)

%% Prepare random data
rng(1234);
delta = normrnd(mu, sigma, N, 1);
data = [data0; delta];
data(N + 2) = sum(data);
labels = cell(N + 2, 1);
labels{1} = 'Start';
labels{N + 2} = 'End';
for ii = 2:N + 1
    labels{ii} = sprintf('Delta%.0f', ii - 1);
end

% Add a middle column
r = round(N / 2 + 1);
data = [data(1: r); sum(data(1: r)); data(r + 1: N + 2)];
labels = [labels(1:r); {'Middle column'}; labels(r + 1:N + 2)];
idx_total = [1 r + 1 N + 3];

end