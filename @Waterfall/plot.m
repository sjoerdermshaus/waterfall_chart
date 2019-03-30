function obj = plot(obj)

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

%% Calculate values for (sub)totals
t.blue(t.istotal) = t.height(t.istotal);

istotal_pos = (t.data >= 0) & t.istotal;
t.top(istotal_pos) = t.data(istotal_pos);

istotal_neg = (t.data < 0) & t.istotal;
t.bottom(istotal_neg) = t.data(istotal_neg);

%% Get barWidth and lineShort
if isfield(obj.config, 'barWidth')
    barWidth = obj.config.barWidth;
else
    barWidth = 0.8;
end

if isfield(obj.config, 'lineShort')
    lineShort = obj.config.lineShort;
else
    lineShort = -1;
end

%% Calculate line_x and line_y for (sub)totals
t.line_x = zeros(N, 2);
t.line_y = zeros(N, 2);

idx_total = t.idx(t.istotal);
idx_total = idx_total(2:end);
for ii = 1:length(idx_total)
    t.line_x(idx_total(ii), :) = [(idx_total(ii) - 1) + lineShort * 0.5 * barWidth ...
                                   idx_total(ii)      - lineShort * 0.5 * barWidth];
end

idx_total_pos = idx_total(t.data(idx_total) >= 0);
t.line_y(idx_total_pos, :) = [t.top(idx_total_pos) t.top(idx_total_pos)];

idx_total_neg = idx_total(t.data(idx_total) < 0);
t.line_y(idx_total_neg, :) = [t.bottom(idx_total_neg) t.bottom(idx_total_neg)];

for ii = 1:N
    if ~t.istotal(ii)
        if t.data(ii - 1) >= 0 && t.data(ii) >= 0
            t.bottom(ii) = t.top(ii - 1);
            t.top(ii) = t.bottom(ii) + t.height(ii);
            t.line_y(ii, :) = [t.bottom(ii) t.bottom(ii)];
        elseif t.data(ii - 1) >= 0 && t.data(ii) < 0
            t.bottom(ii) = t.top(ii - 1) + t.data(ii);
            t.top(ii) = t.bottom(ii) + t.height(ii);
            t.line_y(ii, :) = [t.top(ii) t.top(ii)];
        elseif t.data(ii - 1) < 0 && t.data(ii) >= 0
            t.bottom(ii) = t.bottom(ii - 1);
            t.top(ii) = t.bottom(ii) + t.height(ii);
            t.line_y(ii, :) = [t.bottom(ii) t.bottom(ii)];
        else
            t.bottom(ii) = t.bottom(ii - 1) + t.data(ii);
            t.top(ii) = t.bottom(ii) + t.height(ii);
            t.line_y(ii, :) = [t.top(ii) t.top(ii)];
        end
        
        t.line_x(ii, :) = [(ii - 1) + 0.5 * lineShort * barWidth 
                            ii      - 0.5 * lineShort * barWidth];
        
        if t.data(ii) >= 0
            t.green(ii) = t.height(ii);
        else
            t.red(ii) = t.height(ii);
        end
    end
end

% Add the table to the class
obj.t = t;

%% Create the bar chart
bar_data = t{:, {'bottom', 'blue', 'red', 'green'}};

f = figure;
ax = gca;
b = bar(ax, bar_data, 'stacked', 'barWidth', barWidth, 'FaceColor', 'flat', 'EdgeColor', 'none');
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

if isfield(obj.config, 'FaceAlpha')
    FaceAlpha = obj.config.FaceAlpha;
else
    FaceAlpha = 1;
end

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

if  isfield(obj.config, 'addLine')
    addLine = obj.config.addLine;
else
    addLine = false;
end

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
            % set(hline);
        end
    end
end

if isfield(obj.config, 'title')
    title(ax, obj.config.title);
end 

if isfield(obj.config, 'ylim')
    ylim(ax, obj.config.ylim);
end 

obj.f = f;

end

