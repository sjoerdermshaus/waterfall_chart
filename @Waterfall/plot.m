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

t.blue(obj.idx_total) = t.abs_delta(obj.idx_total);
idx_pos = t.data(obj.idx_total) >= 0;
t.height(obj.idx_total(idx_pos)) = t.abs_delta(obj.idx_total(idx_pos));
t.bottom(obj.idx_total(~idx_pos)) = t.data(obj.idx_total(~idx_pos));

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

t.line_x = zeros(N, 2);
t.line_y = zeros(N, 2);

idx = obj.idx_total(2:end);
for ii = 1:length(idx)
    t.line_x(idx(ii), :) = [(idx(ii) - 1) + lineShort * 0.5 * barWidth ...
                             idx(ii)      - lineShort * 0.5 * barWidth];
end
idx_pos = t.data(idx) >= 0;
idx_pos = idx(idx_pos);
t.line_y(idx_pos, :) = [t.height(idx_pos) t.height(idx_pos)];
t.line_y(~idx_pos, :) = [t.bottom(~idx_pos) t.bottom(~idx_pos)];


for ii = 1:N
    if ~ismember(ii, obj.idx_total)
        if t.data(ii - 1) >= 0 && t.data(ii) >= 0
            t.bottom(ii) = t.height(ii - 1);
            t.height(ii) = t.bottom(ii) + t.abs_delta(ii);
            t.line_y(ii, :) = [t.bottom(ii) t.bottom(ii)];
        elseif t.data(ii - 1) >= 0 && t.data(ii) < 0
            t.bottom(ii) = t.height(ii - 1) + t.data(ii);
            t.height(ii) = t.bottom(ii) + t.abs_delta(ii);
            t.line_y(ii, :) = [t.height(ii) t.height(ii)];
        elseif t.data(ii - 1) < 0 && t.data(ii) >= 0
            t.bottom(ii) = t.bottom(ii - 1);
            t.height(ii) = t.bottom(ii) + t.abs_delta(ii);
            t.line_y(ii, :) = [t.bottom(ii) t.bottom(ii)];
        else
            t.bottom(ii) = t.bottom(ii - 1) + t.data(ii);
            t.height(ii) = t.bottom(ii) + t.abs_delta(ii);
            t.line_y(ii, :) = [t.height(ii) t.height(ii)];
        end
        
        t.line_x(ii, :) = [(ii - 1) + 0.5 * lineShort * barWidth 
                            ii      - 0.5 * lineShort * barWidth];
        
        if t.data(ii) >= 0
            t.green(ii) = t.abs_delta(ii);
        else
            t.red(ii) = t.abs_delta(ii);
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

if  isfield(obj.config, 'addLine')
    addLine = obj.config.addLine;
else
    addLine = false;
end

for ii = 1:N % Loop over each bar
    if t.data(ii) >= 0
        ypos = t.height(ii) + ygap;
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

