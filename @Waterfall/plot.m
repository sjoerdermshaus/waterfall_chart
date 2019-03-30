function obj = plot(obj)

%% Config
if isfield(obj.config, 'lineShort')
    lineShort = obj.config.lineShort;
else
    lineShort = -1;
end

if isfield(obj.config, 'barWidth')
    barWidth = obj.config.barWidth;
else
    barWidth = 0.8;
end

if isfield(obj.config, 'FaceAlpha')
    FaceAlpha = obj.config.FaceAlpha;
else
    FaceAlpha = 1;
end

if  isfield(obj.config, 'ygap')
    ygap = obj.config.ygap;
else
    ygap = 3;
end

if  isfield(obj.config, 'addLine')
    addLine = obj.config.addLine;
else
    addLine = false;
end

if isfield(obj.config, 'facecolors')
    facecolors = [1 1 1;
                  obj.config.facecolors.blue / 255;
                  obj.config.facecolors.red / 255;
                  obj.config.facecolors.green / 255];
else
    facecolors = [1 1 1; 
                  0 0.4470 0.7410; 
                  0.6350 0.0780 0.1840; 
                  0.4660 0.6740 0.1880];
end

if isfield(obj.config, 'XTickLabelRotation')
    XTickLabelRotation = obj.config.XTickLabelRotation;
else
    XTickLabelRotation = 0;
end

if isfield(obj.config, 'gridValue')
    gridValue = obj.config.gridValue;
else
    gridValue = 'off';
end

%% Create a table with all relevant calculations for a waterfall chart
N           = length(obj.data);
t           = table();
t.idx       = (1:N)';
t.label     = obj.labels;
t.istotal   = ismember(t.idx, obj.idx_total);
t.data      = obj.data;

t.bottom    = zeros(N, 1); % bottom y-value
t.top       = zeros(N, 1); % top y-value
t.height    = abs(t.data); % height of the bar, i.e. top = bottom + height
t.blue      = zeros(N, 1); % height if (sub)totals else 0
t.red       = zeros(N, 1); % height if decrease else 0
t.green     = zeros(N, 1); % height if increase else 0
t.red_total = zeros(N, 1); % height if decrease and istotal else 0

t.line_x    = zeros(N, 2); % x coordinates for lines between bars
t.line_y    = zeros(N, 2); % y coordinates for lines between bars

%% Calculate values
% Values for the stacked bar chart
t.blue(t.istotal)      =      t.height(t.istotal);    % > 0
t.red(~t.istotal)      = -min(t.data(~t.istotal), 0); % > 0
t.green(~t.istotal)    =  max(t.data(~t.istotal), 0); % > 0
t.red_total(t.istotal) = -min(t.data(t.istotal), 0);  % > 0, auxiliary

% Creating a bar chart is all about finding the bottom values!

% Determine top and bottom for (sub)totals
istotal_neg = (t.red_total > 0);
t.bottom(istotal_neg) = t.data(istotal_neg);
t.top(t.istotal)      = t.bottom(t.istotal) + t.height(t.istotal);

% Loop over non-(sub)totals and determine top and bottom
% Add x-lines for all bars
for ii = 2:N
    if ~t.istotal(ii)
        t.bottom(ii) = t.top(ii - 1) - t.red_total(ii - 1) - t.red(ii - 1) - t.red(ii);
        t.top(ii)    = t.bottom(ii) + t.height(ii);
    end
    t.line_x(ii, :) = [(ii - 1) + 0.5 * lineShort * barWidth ...
                        ii      - 0.5 * lineShort * barWidth];
end

% Add y-lines
idx = (t.green > 0) | (t.red_total > 0);
t.line_y( idx, :) = [t.bottom(idx) t.bottom(idx)];
t.line_y(~idx, :) = [t.top(~idx)   t.top(~idx)];

%% Create the bar chart
f = figure;
ax = gca;
bar_data = t{:, {'bottom', 'blue', 'red', 'green'}};
b = bar(ax, bar_data, 'stacked', 'barWidth', barWidth, 'FaceColor', 'flat', 'EdgeColor', 'none');
for ii = 1:4
    b(ii).CData = ones(N, 1) * facecolors(ii, :);
    if ii == 1
        b(ii).FaceAlpha = 0;
    else
        b(ii).FaceAlpha = FaceAlpha;
    end
end

%% Add xticklabels
ax.XTick = 1:N;
ax.XTickLabel = t.label;
ax.XTickLabelRotation = XTickLabelRotation;
grid(ax, gridValue);

%% Add data values as text to waterfall chart
for ii = 1:N % Loop over each bar
    if t.data(ii) >= 0
        ypos = t.top(ii) + ygap;
        vertical_alignment = 'bottom';
    else
        ypos = t.bottom(ii) - ygap;
        vertical_alignment = 'top';
    end
    if ismember(ii, obj.idx_total)
        txt = sprintf('%.0f', t.data(ii));
    else
        txt = sprintf('%+.0f', t.data(ii));
    end
    htext = text(ax, ii, ypos, txt); % Add text label
    set(htext,'VerticalAlignment', vertical_alignment,...  % Adjust properties
              'HorizontalAlignment', 'center')
    
    if addLine == true
        if ii > 1
            line(ax, t.line_x(ii, :), t.line_y(ii, :), 'Color', 'k');
        end
    end
end

%% Add title and adjust ylim
if isfield(obj.config, 'title')
    title(ax, obj.config.title);
end 

if isfield(obj.config, 'ylim')
    ylim(ax, obj.config.ylim);
end 

obj.f = f;
obj.t = t;

end

