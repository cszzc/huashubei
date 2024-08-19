clc;
clear;

% 读取温湿指数数据
filename = '各城市年均温及年降水量和相对湿度_分类结果.xlsx';
data = readtable(filename);

% 检查数据的前几行，以确认数据读取正确
disp('读取的前几行数据：');
disp(data(1:5, :));

% 提取分类数据（假设在第二列）
categories = data{:, 2};

% 检查分类数据是否为空
if isempty(categories)
    error('分类数据为空。请检查数据文件。');
end

% 生成城市编号
numCities = length(categories);
cityNumbers = (1:numCities)';

% 确保城市编号和分类数据的长度一致
if length(cityNumbers) ~= length(categories)
    error('城市编号和分类数据的长度不匹配。');
end

% 绘制散点图
figure;
gscatter(cityNumbers, categories, categories, 'rbm', 'o');
xlabel('城市编号');
ylabel('分类');
title('城市分类散点图');
legend('1-不舒适', '3-较舒适', '5-非常舒适', 'Location', 'Best');
grid on;
