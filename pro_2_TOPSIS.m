%熵权-TOPSIS

clc;
clear;

% 读取数据
filename = '影响因子量化结果.xlsx';
data = readtable(filename);

% 检查数据的前几行，以确认数据读取正确
disp('读取的前几行数据：');
disp(data(1:5, :));

% 提取城市名称（假设在第一列）
cities = data{2:end, 1};

% 提取决策矩阵，从第二列开始提取（假设第一列是城市名称）
decisionMatrix = table2array(data(2:end, 2:end));

% 1. 数据标准化（假设越大越好）
normDecisionMatrix = decisionMatrix ./ sqrt(sum(decisionMatrix.^2));

% 2. 计算熵值和权重
% 计算每列的比例
P = normDecisionMatrix ./ sum(normDecisionMatrix, 1);

% 计算熵值
k = 1 / log(size(normDecisionMatrix, 1)); % 常数
entropy = -k * sum(P .* log(P + eps), 1);

% 计算熵权
dissimilarity = 1 - entropy; % 不确定度
weights = dissimilarity / sum(dissimilarity);

% 3. 加权标准化决策矩阵
weightedDecisionMatrix = normDecisionMatrix .* weights;

% 4. TOPSIS计算
% 确定理想解和负理想解
idealSolution = max(weightedDecisionMatrix);
negativeIdealSolution = min(weightedDecisionMatrix);

% 计算距离
distToIdeal = sqrt(sum((weightedDecisionMatrix - idealSolution).^2, 2));
distToNegativeIdeal = sqrt(sum((weightedDecisionMatrix - negativeIdealSolution).^2, 2));

% 计算接近度
relativeCloseness = distToNegativeIdeal ./ (distToIdeal + distToNegativeIdeal);

% 排序方案
[~, sortedIndices] = sort(relativeCloseness, 'descend');

% 选择前50个最优城市
top50Indices = sortedIndices(1:50);
top50Cities = cities(top50Indices);

% 显示结果
disp('最优的50个城市名称：');
disp(top50Cities);

% 将结果保存到 Excel 文件
resultTable = table(top50Cities, 'VariableNames', {'城市名称'});
writetable(resultTable, '前50个城市.xlsx');
fprintf('最优的50个城市名称已成功保存到文件“前50个城市.xlsx”。\n');
