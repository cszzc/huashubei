%蚁群算法新增约束

% 清空环境变量
clc; clear;

% 设置随机种子
rng(0); % 固定随机种子

% 加载数据
filename_attractions = '山的建议时间和费用.xlsx';
filename_distances = '城市距离矩阵2.xlsx';
filename_travelTimes = '城市时间矩阵2.xlsx';
filename_travelCosts = '城市交通费用矩阵2.xlsx';

% 读取文件内容
attractionData = readtable(filename_attractions);
distanceMatrix = xlsread(filename_distances);
timeMatrix = xlsread(filename_travelTimes);
costMatrix = xlsread(filename_travelCosts);

cityNames = attractionData{:, 1};

% 获取城市数量
numCities = size(distanceMatrix, 1);

% 设置蚁群算法参数
numAnts = 50; % 蚂蚁数量
numIterations = 100; % 迭代次数
alpha = 1; % 信息素重要程度
beta = 2; % 启发式因子重要程度
rho = 0.5; % 信息素挥发率
Q = 1; % 信息素增加常数
maxTime = 88; % 最大允许的游玩时间

% 初始化信息素矩阵
pheromoneMatrix = ones(numCities, numCities);
visibilityMatrix = 1 ./ (distanceMatrix + 1e-10); % 避免除以零

% 设置起点城市
startCity = 189; % 假设从第1个城市开始，您可以根据需要修改这个值

% 主蚁群算法循环
bestPath = [];
bestFitness = -Inf;
for iter = 1:numIterations
    % 蚂蚁走路径
    paths = zeros(numAnts, numCities);
    for k = 1:numAnts
        paths(k, :) = antColonyOptimization(numCities, pheromoneMatrix, visibilityMatrix, alpha, beta, maxTime, attractionData, startCity);
    end
    
    % 计算适应度
    fitness = zeros(numAnts, 1);
    for k = 1:numAnts
        fitness(k) = calculateFitness(paths(k, :), timeMatrix, costMatrix, attractionData, maxTime);
    end
    
    % 更新最佳解
    [currentBestFitness, bestIdx] = max(fitness);
    if currentBestFitness > bestFitness
        bestFitness = currentBestFitness;
        bestPath = paths(bestIdx, :);
    end
    
    % 更新信息素
    pheromoneMatrix = (1 - rho) * pheromoneMatrix;
    for k = 1:numAnts
        path = paths(k, :);
        pathLength = length(path);
        for i = 1:pathLength-1
            cityIdx = path(i);
            nextCityIdx = path(i+1);
            pheromoneMatrix(cityIdx, nextCityIdx) = pheromoneMatrix(cityIdx, nextCityIdx) + Q / fitness(k);
        end
    end
end


% 计算最终的总时间和总费用
[totalTime, totalCost, finalPath] = calculateFinalCostAndTime(bestPath, timeMatrix, costMatrix, attractionData, maxTime, cityNames);

% 获取城市名称
pathNames = cityNames(finalPath);

% 输出结果
fprintf('最优路径: %s\n', strjoin(pathNames, ' -> '));
fprintf('总花费时间: %.2f 小时\n', totalTime);
fprintf('总费用: %.2f 元\n', totalCost);

function path = antColonyOptimization(numCities, pheromoneMatrix, visibilityMatrix, alpha, beta, maxTime, attractionData, startCity)
    path = zeros(1, numCities);
    visited = false(1, numCities);
    currentCity = startCity; % 将起点设置为指定的起点城市
    path(1) = currentCity;
    visited(currentCity) = true;
    for i = 2:numCities
        probabilities = (pheromoneMatrix(currentCity, :) .^ alpha) .* (visibilityMatrix(currentCity, :) .^ beta);
        probabilities(visited) = 0;
        probabilities = probabilities / sum(probabilities);
        nextCity = find(rand < cumsum(probabilities), 1);
        path(i) = nextCity;
        visited(nextCity) = true;
        currentCity = nextCity;
    end
end


function fitness = calculateFitness(path, timeMatrix, costMatrix, attractionData, maxTime)
    totalTime = 0;
    totalCost = 0;
    visitedCities = 0;
    
    for i = 1:length(path)-1
        cityIdx = path(i);
        nextCityIdx = path(i+1);
        
        travelTime = timeMatrix(cityIdx, nextCityIdx);
        playTime = attractionData{cityIdx, 4}; % 第3列为游玩时间
        travelCost = costMatrix(cityIdx, nextCityIdx);
        ticketCost = attractionData{cityIdx, 5}; % 第4列为门票价格
        
        % 计算总时间（包括交通和游玩时间）
        totalTime = totalTime + travelTime + playTime;
        
        % 更新总费用
        totalCost = totalCost + travelCost + ticketCost;
        
        % 检查是否超过最大允许时间
        if totalTime > maxTime
            break; % 如果超过最大时间，立即终止循环
        end
        
        % 如果未超过最大时间，则记录访问城市数量
        visitedCities = visitedCities + 1;
    end
    
    % 适应度计算：访问城市数量 - 费用惩罚
    % 减去总费用的惩罚，以鼓励选择低费用路径
    fitness = visitedCities - totalCost / 100; % 可调整的费用权重
end

function [totalTime, totalCost, finalPath] = calculateFinalCostAndTime(path, timeMatrix, costMatrix, attractionData, maxTime, cityNames)
    totalTime = 0;
    totalCost = 0;
    numCities = length(path);
    finalPath = [];
    
    for i = 1:numCities-1
        cityIdx = path(i);
        nextCityIdx = path(i+1);
        
        % 获取旅行时间、游玩时间、旅行费用和门票费用
        travelTime = timeMatrix(cityIdx, nextCityIdx);
        playTime = attractionData{cityIdx, 4}; % 第3列为游玩时间
        travelCost = costMatrix(cityIdx, nextCityIdx);
        ticketCost = attractionData{cityIdx, 5}; % 第4列为门票价格
        
        % 打印当前城市的游玩时间和通勤时间
        fprintf('从城市 %s 到城市 %s 的旅行时间为: %.2f 小时\n', cityNames{cityIdx}, cityNames{nextCityIdx}, travelTime);
        fprintf('城市 %s 的游玩时间为: %.2f 小时\n', cityNames{cityIdx}, playTime);
        
        % 更新总时间和总费用
        totalTime = totalTime + travelTime + playTime;
        totalCost = totalCost + travelCost + ticketCost;
        
        % 打印累计时间和费用
        fprintf('当前总时间: %.2f 小时\n', totalTime);
        fprintf('当前总费用: %.2f 元\n', totalCost);
        
        % 如果总时间超过最大允许时间，终止循环
        if totalTime > maxTime
            fprintf('超过最大时间限制，终止路径计算。\n');
            break;
        end
        
        % 保存当前城市到最终路径
        finalPath = [finalPath, cityIdx];
    end
    
    % 添加最后一个城市到路径中
    if ~isempty(path)
        finalPath = [finalPath, path(end)];
    end
end
