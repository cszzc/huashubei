clc;
clear;

% 读取温湿指数数据
filename = '各城市年均温及年降水量和相对湿度.xlsx';
data = readtable(filename);

% 检查数据的前几行，以确认数据读取正确
disp('读取的前几行数据：');
disp(data(1:5, :));

% 提取温湿指数，从第二行开始提取
humitureIndex = data{1:end, 5};  

% 将数据转化为列向量
humitureIndex = humitureIndex(:);

% 定义温湿指数的初步分类阈值
thresholds = [14, 16.9, 25.4, 27.5];

% 按照温湿指数将城市初步分档
initialCategory = zeros(length(humitureIndex), 1);
initialCategory(humitureIndex < thresholds(1)) = 1;                 % <14, 类别1
initialCategory(humitureIndex >= thresholds(1) & humitureIndex <= thresholds(2)) = 2; % 14-16.9, 类别2
initialCategory(humitureIndex >= thresholds(2) & humitureIndex <= thresholds(3)) = 3; % 17-25.4, 类别3
initialCategory(humitureIndex >= thresholds(3) & humitureIndex <= thresholds(4)) = 4; % 25.5-27.5, 类别4
initialCategory(humitureIndex > thresholds(4)) = 5;                % >27.5, 类别5

% 将初步分类结果用于KMeans++的初始化
% KMeans++初始聚类中心的选择考虑到初步分类的均值
K = 5;
initialCentroids = zeros(K, 1);
for i = 1:K
    initialCentroids(i) = mean(humitureIndex(initialCategory == i));
end

% 使用KMeans++进一步聚类
[idx, C] = kmeans(humitureIndex, K, 'Start', initialCentroids, 'Distance', 'sqEuclidean', 'Replicates', 1);

% 计算每个簇的均值
clusterMeans = C;

% 根据均值对簇进行排序（从最差到最好）
[~, sortedIdx] = sort(clusterMeans, 'ascend');  % 从最差到最好排序

% 创建一个映射，将原始簇编号映射到从1到K的类别中
mapping = containers.Map(sortedIdx, 1:K);

% 调整聚类结果，使得1表示最差，5表示最好
adjustedIdx = arrayfun(@(x) mapping(x), idx);

% 执行最终的映射
% 将类别2和4都映射为3
mappedCategory(adjustedIdx == 2) = 3;
mappedCategory(adjustedIdx == 4) = 3;

% 将类别3的城市映射为5
mappedCategory(adjustedIdx == 3) = 5;

% 将类别1和5都映射为1
mappedCategory(adjustedIdx == 1) = 1;
mappedCategory(adjustedIdx == 5) = 1;

% 提取城市名称（假设在第一列），从第二行开始提取
cities = data{1:end, 1};

% 确保城市和分类结果的长度一致
if length(cities) ~= length(mappedCategory)
    error('城市数据和分类结果的长度不匹配。');
end

% 将分类结果保存到新的 Excel 文件
resultTable = table(cities, mappedCategory, 'VariableNames', {'城市', '温湿分类'});

% 将结果导出到Excel
writetable(resultTable, '各城市年均温及年降水量和相对湿度_分类结果.xlsx');

% 输出提示信息
fprintf('分类结果已成功保存到文件“各城市年均温及年降水量和相对湿度_分类结果.xlsx”。\n');

% 绘制分类散点图
figure;
gscatter(1:length(humitureIndex), humitureIndex, mappedCategory);
xlabel('城市编号');
ylabel('温湿指数');
title('KMeans++聚类后的温湿指数分类结果');
legend('1-不舒适', '3-较舒适', '5-非常舒适');
grid on;
