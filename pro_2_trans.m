clc;
clear;

% 读取交通数据
filename = '交通.xlsx';
data = readtable(filename);

% 检查数据的前几行，以确认数据读取正确
disp('读取的前几行数据：');
disp(data(1:5, :));

% 提取城市名称（假设在第一列），从第二行开始提取
cities = data{2:end, 1};

% 提取公交车数量、轨道交通里程数、轨道交通车站数，从第二行开始提取
busCount = data{2:end, 2};           % 假设公交车数量在第2列
railLength = data{2:end, 3};         % 假设轨道交通里程数在第3列
railStations = data{2:end, 4};       % 假设轨道交通车站数在第4列

% 将数据转化为矩阵，形成三维数据点
transportData = [busCount, railLength, railStations];

% 确定聚类数目
K = 5;

% 使用KMeans++进行聚类
[idx, C] = kmeans(transportData, K, 'Distance', 'sqEuclidean', 'Replicates', 50, 'Start', 'plus');

% 计算每个簇的均值
clusterMeans = mean(C, 2);

% 根据均值对簇进行排序（从最不便到最便利）
[~, sortedIdx] = sort(clusterMeans, 'ascend');  % 从最差到最好排序

% 创建一个映射，将原始簇编号映射到从1到K的类别中
mapping = containers.Map(sortedIdx, 1:K);

% 调整聚类结果，使得1表示最不便，5表示最便利
adjustedIdx = arrayfun(@(x) mapping(x), idx);

% 确保城市和聚类结果的长度一致
if length(cities) ~= length(adjustedIdx)
    error('城市数据和聚类结果的长度不匹配。');
end

% 将聚类结果保存到新的 Excel 文件
resultTable = table(cities, adjustedIdx, 'VariableNames', {'城市', '聚类类别'});

% 将结果导出到Excel
writetable(resultTable, '交通_聚类结果.xlsx');

% 输出提示信息
fprintf('聚类结果已成功保存到文件“交通_聚类结果.xlsx”。\n');
