function main

rng(1234);

N = 10;
data0 = 100;
delta = normrnd(10, 70, N, 1);
data = [data0; delta];
data(end + 1) = sum(data);
labels = cell(N + 2, 1);
labels{1} = 'Start';
labels{N + 2} = 'End';
for ii = 2:N + 1
    labels{ii} = sprintf('Delta%.0f', ii - 1);
end

config.title = 'My beautiful waterfall';
config.ylim = [0 500];
config.XTickLabelRotation = 90;
config.ygap = 5;

my_waterfall = Waterfall(labels, data, config);
plot(my_waterfall);

disp(my_waterfall.t);

saveas(my_waterfall.f, 'waterfall.png');
close(my_waterfall.f);

end

