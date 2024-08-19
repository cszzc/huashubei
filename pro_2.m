clc;
clear;

% 读取空气优良率数据
filename = '美食搜索指数.xlsx';
data = readtable(filename);

% 检查数据的前几行，以确认数据读取正确
disp('读取的前几行数据：');
disp(data(1:5, :));

% 提取，从第二行开始提取
airQuality = data{2:end, 2};  

% 将数据转化为列向量
airQuality = airQuality(:);

% 确定聚类数目
K = 5;

% 使用KMeans++进行聚类
[idx, C] = kmeans(airQuality, K, 'Distance', 'sqEuclidean', 'Replicates', 50, 'Start', 'plus');

% 计算每个簇的均值
clusterMeans = C;

% 根据均值对簇进行排序（从最差到最好）
[~, sortedIdx] = sort(clusterMeans, 'ascend');  % 从最差到最好排序

% 创建一个映射，将原始簇编号映射到从1到K的类别中
mapping = containers.Map(sortedIdx, 1:K);

% 调整聚类结果，使得1表示最差，5表示最好
adjustedIdx = arrayfun(@(x) mapping(x), idx);

% 提取城市名称（假设在第一列），从第二行开始提取
cities = data{2:end, 1};

% 确保城市和聚类结果的长度一致
if length(cities) ~= length(adjustedIdx)
    error('城市数据和聚类结果的长度不匹配。');
end

% 将聚类结果保存到新的 Excel 文件
resultTable = table(cities, adjustedIdx, 'VariableNames', {'城市', '聚类类别'});

% 将结果导出到Excel
writetable(resultTable, '美食搜索指数_聚类结果.xlsx');

% 输出提示信息
fprintf('聚类结果已成功保存到文件“美食搜索指数_聚类结果.xlsx”。\n');

% 绘制聚类散点图
figure;
gscatter(1:length(airQuality), airQuality, adjustedIdx);
xlabel('城市编号');
ylabel('美食搜索指数');
title('KMeans++聚类结果');
legend('1-最差', '2', '3', '4', '5-最好');
grid on;
