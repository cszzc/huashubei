clc;
clear;

% 读取距离矩阵
filename = '城市距离矩阵2.xlsx';
data = readmatrix(filename);
distanceMatrix = data(1:end,2:end);

% 高铁时速 (km/h)
trainSpeed = 300;

% 计算时间矩阵 (时间 = 距离 / 速度)
timeMatrix = distanceMatrix / trainSpeed;

% 读取城市名称
cityNames = readcell(filename, 'Range', 'A2:A300');  % 假设城市名称在第一列，从第1行到第50行
cityNames = cityNames(:);  % 转换为列向量

% 添加城市名称作为第一行和第一列
timeMatrixWithNames = [[{'城市'}, cityNames']; [cityNames, num2cell(timeMatrix)]];

% 将时间矩阵保存至新的 Excel 文件
writecell(timeMatrixWithNames, '城市时间矩阵2.xlsx');

% 输出提示信息
fprintf('时间矩阵已成功保存到文件“城市时间矩阵2.xlsx”。\n');
