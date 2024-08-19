clc;
clear;

X = xlsread('空气优良率.xlsx');

% 聚类种类
K = 3;
max_iters = 20;

% 初始化质心
centroids = init_centroids(X, K);

% 迭代更新簇分配和簇质心
for i = 1:max_iters
    % 簇分配
    labels = assign_labels(X, centroids);
    % 更新簇质心
    centroids = update_centroids(X, labels, K);
end

% 将聚类结果保存到新的 Excel 文件
xlswrite('聚类结果.xlsx', labels);

% 簇分配函数
function labels = assign_labels(X, centroids)
    [~, labels] = min(pdist2(X, centroids,'squaredeuclidean'), [], 2);
end

% 初始化簇质心函数
function centroids = init_centroids(X, K)
    % 随机选择一个数据点作为第一个质心
    centroids = X(randperm(size(X, 1), 1), :);
    % 选择剩余的质心
    for i = 2:K
        D = pdist2(X, centroids,'squaredeuclidean');
        D = min(D, [], 2);
        D = D / sum(D);
        centroids(i, :) = X(find(rand < cumsum(D), 1), :);
    end
end

% 更新簇质心函数
function centroids = update_centroids(X, labels, K)
    centroids = zeros(K, size(X, 2));
    for i = 1:K
        centroids(i, :) = mean(X(labels == i, :), 1);
    end
end