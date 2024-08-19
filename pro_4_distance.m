clc;
clear;

% 读取城市经纬度数据
filename = '第五问经纬度.xlsx';
data = readtable(filename);

% 提取城市名称、纬度和经度列
cities = data{:, 1};  % 假设城市名称在第一列
latitudes = data{:, 3};  % 假设纬度在第二列
longitudes = data{:, 2};  % 假设经度在第三列

% 城市数量
numCities = length(cities);

% 初始化距离矩阵
distanceMatrix = zeros(numCities);

% 地球半径（单位：公里）
R = 6371;

% 计算两两城市之间的直线距离
for i = 1:numCities
    for j = 1:numCities
        % 将纬度和经度转换为弧度
        lat1 = deg2rad(latitudes(i));
        lon1 = deg2rad(longitudes(i));
        lat2 = deg2rad(latitudes(j));
        lon2 = deg2rad(longitudes(j));
        
        % 计算两个城市之间的直线距离（使用 Haversine 公式）
        deltaLat = lat2 - lat1;
        deltaLon = lon2 - lon1;
        a = sin(deltaLat/2)^2 + cos(lat1) * cos(lat2) * sin(deltaLon/2)^2;
        c = 2 * atan2(sqrt(a), sqrt(1-a));
        distance = R * c;
        
        % 填充距离矩阵
        distanceMatrix(i, j) = distance;
    end
end

% 创建一个单元格数组用于保存结果，包括城市名称
outputMatrix = cell(numCities + 1, numCities + 1);

% 填写城市名称到第一行和第一列
outputMatrix(2:end, 1) = cities;
outputMatrix(1, 2:end) = cities';

% 填写距离数据
outputMatrix(2:end, 2:end) = num2cell(distanceMatrix);

% 将结果保存到Excel文件
resultFilename = '城市距离矩阵2.xlsx';
writecell(outputMatrix, resultFilename);

% 输出提示信息
fprintf('城市间的距离矩阵已成功保存到文件 "%s"。\n', resultFilename);
