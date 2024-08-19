clc;
clear;

% 读取Excel文件中的数据
filename = '数据筛选结果.xlsx';

% 假设数据在第一张工作表中，包含'城市', '景点名称', '评分'三列
data = readtable(filename);

% 提取城市名称和评分列，从第二行开始提取数据
cities = data{2:end, 1};  % 第一列是城市，从第二行开始提取
scoresRaw = data{2:end, 8};  % 第八列是评分，从第二行开始提取

% 将评分数据转换为数值类型
scores = str2double(scoresRaw);

% 检查并处理无法转换为数值的项
invalidScoresIdx = isnan(scores);

% 输出无法转换的项及其原始内容
if any(invalidScoresIdx)
    fprintf('以下评分项无法转换为数值：\n');
    disp(table(find(invalidScoresIdx), scoresRaw(invalidScoresIdx)));
    warning('请检查上述无法转换的评分项，确保所有评分均为有效的数值格式。');
    
    % 处理无效项：将无效评分设为0
    scores(invalidScoresIdx) = 0;  
end

% 统计每个评分的数量
[uniqueScores, ~, idx] = unique(scores);
scoreCounts = histcounts(idx, 1:numel(uniqueScores)+1);

% 获取前十个评分及其数量
[sortedScores, sortIdx] = sort(uniqueScores, 'descend');
topScores = sortedScores(1:min(10, end));
topCounts = scoreCounts(sortIdx(1:min(10, end)));

% 输出结果
fprintf('前十个评分及其景点数量：\n');
for i = 1:length(topScores)
    fprintf('评分 %.1f: 景点数量 = %d\n', topScores(i), topCounts(i));
end

% 绘制直方图
figure;
bar(topScores, topCounts);
xlabel('评分');
ylabel('景点数量');
title('前十个评分的景点数量');

% 设置横坐标刻度为0.1
xLimits = [floor(min(topScores)), ceil(max(topScores))]; % 确定横坐标的范围
xticks = xLimits(1):0.1:xLimits(2); % 创建0.1的刻度
set(gca, 'XTick', xticks); % 设置横坐标刻度
set(gca, 'XTickLabel', arrayfun(@(x) sprintf('%.2f', x), xticks, 'UniformOutput', false)); % 设置横坐标标签

grid on;

% 将结果保存到新的 Excel 文件
resultTable = table(topScores, topCounts, 'VariableNames', {'评分', '景点数量'});
writetable(resultTable, '前十个评分景点数量.xlsx');

% 输出提示信息
fprintf('前十个评分的景点数量已成功保存到文件“前十个评分景点数量.xlsx”。\n');
