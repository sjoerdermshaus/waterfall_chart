function obj = plot(obj)

%% Create a table with all relevant calculations for a waterfall chart
t = table();
t.label = obj.labels;
t.data = obj.data;

N = length(t.data);
t.bottom = zeros(N, 1);
t.height = zeros(N, 1);
t.abs_delta = abs(t.data);
t.blue = zeros(N, 1);
t.red = zeros(N, 1);
t.green = zeros(N, 1);

idx = [1 N];
t.blue(idx) = t.abs_delta(idx);
t.height(idx) = t.data(idx);

for ii = 2:N - 1
    if t.data(ii - 1) >= 0 && t.data(ii) >= 0
        t.bottom(ii) = t.height(ii - 1);
    elseif t.data(ii - 1) >= 0 && t.data(ii) < 0
        t.bottom(ii) = t.height(ii - 1) + t.data(ii);
    elseif t.data(ii - 1) < 0 && t.data(ii) >= 0
        t.bottom(ii) = t.bottom(ii - 1);
    else
        t.bottom(ii) = t.bottom(ii - 1) + t.data(ii);
    end
    t.height(ii) = t.bottom(ii) + t.abs_delta(ii);
    if t.data(ii) >= 0
        t.green(ii) = t.abs_delta(ii);
    else
        t.red(ii) = t.abs_delta(ii);
    end
end

% Add the table to the class
obj.t = t;

%% Create the bar chart
bar_data = t{:, {'bottom', 'blue', 'red', 'green'}};

f = figure;
ax = gca;
b = bar(ax, bar_data, 'stacked', 'FaceColor', 'flat', 'EdgeColor', 'none');
facecolors = [1 1 1; 0 0.4470 0.7410; 0.6350 0.0780 0.1840; 0.4660 0.6740 0.1880];
for ii = 1:4
    b(ii).CData = ones(N, 1) * facecolors(ii, :);
    if ii == 1
        b(ii).FaceAlpha = 0;
    else
        b(ii).FaceAlpha = 1;
    end
end

%% Add xticklabels
ax.XTick = 1:N;
ax.XTickLabel = t.label;
if isfield(obj.config, 'XTickLabelRotation')
    ax.XTickLabelRotation = obj.config.XTickLabelRotation;
end
grid(ax, 'on');

%% Add data values as text to waterfall chart
if  isfield(obj.config, 'ygap')
    ygap = obj.config.ygap;
else
    ygap = 3;
end

for ii = 1:N % Loop over each bar
    if t.data(ii) >= 0
        ypos = t.height(ii) + ygap;
        vertical_alignment = 'bottom';
    else
        ypos = t.bottom(ii) - ygap;
        vertical_alignment = 'top';
    end
    if ismember(ii, [1 N])
        txt = sprintf('%.0f', t.data(ii));
    else
        txt = sprintf('%+.0f', t.data(ii));
    end
    htext = text(ax, ii, ypos, txt); % Add text label
    set(htext,'VerticalAlignment', vertical_alignment,...  % Adjust properties
              'HorizontalAlignment', 'center')
end

if isfield(obj.config, 'title')
    title(ax, obj.config.title);
end 

if isfield(obj.config, 'ylim')
    ylim(ax, obj.config.ylim);
end 

obj.f = f;

end

