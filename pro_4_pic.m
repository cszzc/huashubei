% 清空环境变量
clc; clear;

% 加载经纬度数据
filename_latlon = '前50个城市经纬度.xlsx';
latlonData = readtable(filename_latlon);

% 城市经纬度
cityNames = latlonData{:, 1};
latitudes = latlonData{:, 3};
longitudes = latlonData{:, 2};

% 需要绘制的城市路径
cityPath = {'广州', '佛山', '江门', '中山', '珠海', '深圳', '惠州', '东莞', '白沙', '茂名', '湛江', '海口', '屯昌', '昌江', '保亭', '五指山'};
numCitiesPath = length(cityPath);

% 获取路径中城市的经纬度
pathLatitudes = [];
pathLongitudes = [];
for i = 1:numCitiesPath
    idx = find(strcmp(cityNames, cityPath{i}));
    if ~isempty(idx)
        pathLatitudes(i) = latitudes(idx);
        pathLongitudes(i) = longitudes(idx);
    end
end

% 绘制城市及路径
figure;
hold on;

% 绘制路径
plot(pathLongitudes, pathLatitudes, '-o', 'MarkerSize', 8, 'LineWidth', 2, 'Color', 'b');

% 绘制城市名称
for i = 1:numCitiesPath
    text(pathLongitudes(i), pathLatitudes(i), cityPath{i}, 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right', 'FontSize', 10, 'FontWeight', 'bold');
end

% 设置坐标轴标签
xlabel('经度');
ylabel('纬度');

% 设置图形标题
title('城市旅行路径');

% 设置坐标轴范围（根据实际数据设置范围）
xlim([min(longitudes) - 1, max(longitudes) + 1]);
ylim([min(latitudes) - 1, max(latitudes) + 1]);

% 绘制网格
grid on;

% 显示图形
hold off;
