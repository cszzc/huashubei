%第一问遍历算法

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
    
    % 处理无效项：移除无效评分及其对应城市
    scores(invalidScoresIdx) = [];  
    cities(invalidScoresIdx) = [];
end

% 找到所有城市中评分的最高分
BS = max(scores);

% 统计获得最高评分（BS）的景点数量
numBestSpots = sum(scores == BS);

% 初始化用于统计每个城市中获得最高评分景点的数量
uniqueCities = unique(cities);
numCities = length(uniqueCities);
cityScoreCounts = zeros(numCities, 1);

% 统计每个城市的最高评分景点数量
for i = 1:numCities
    % 找到当前城市的所有评分
    currentCityScores = scores(strcmp(cities, uniqueCities{i}));
    
    % 统计该城市中获得最高评分的景点数量
    cityScoreCounts(i) = sum(currentCityScores == BS);
end

% 按城市中最高评分景点的数量降序排序
[~, sortedIdx] = sort(cityScoreCounts, 'descend');
topCities = uniqueCities(sortedIdx);

% 输出结果
fprintf('全国最高评分（BS）：%.2f\n', BS);
fprintf('获得最高评分的景点数量：%d\n', numBestSpots);
fprintf('获得最高评分景点最多的前10个城市：\n');

for i = 1:min(10, length(topCities))
    fprintf('城市 %s: 最高评分景点数量 = %d\n', topCities{i}, cityScoreCounts(sortedIdx(i)));
end
