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

% 定义温湿指数的分类阈值
thresholds = [14, 16.9, 25.4, 27.5];

% 按照温湿指数将城市分档
initialCategory = zeros(length(humitureIndex), 1);
initialCategory(humitureIndex < thresholds(1)) = 1;                  % <14, 类别1
initialCategory(humitureIndex >= thresholds(1) & humitureIndex <= thresholds(2)) = 2;  % 14-16.9, 类别2
initialCategory(humitureIndex >= thresholds(2) & humitureIndex <= thresholds(3)) = 3;  % 17-25.4, 类别3
initialCategory(humitureIndex >= thresholds(3) & humitureIndex <= thresholds(4)) = 4;  % 25.5-27.5, 类别4
initialCategory(humitureIndex > thresholds(4)) = 5;                 % >27.5, 类别5

% 进行类别映射，符合舒适度要求
mappedCategory = initialCategory;
mappedCategory(initialCategory == 2) = 3;  % 类别2和4映射为3
mappedCategory(initialCategory == 4) = 3;  % 类别2和4映射为3
mappedCategory(initialCategory == 3) = 5;   % 类别3映射为5
mappedCategory(initialCategory == 1) = 1;  % 类别1和5映射为1
mappedCategory(initialCategory == 5) = 1;  % 类别1和5映射为1

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
title('温湿指数的分类结果');
legend('1-不舒适', '3-较舒适', '5-非常舒适');
grid on;

