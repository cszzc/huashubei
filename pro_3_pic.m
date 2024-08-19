% 清空环境变量
clc; clear; close all;

% 读取城市经纬度数据
filename_latlon = '前50个城市经纬度.xlsx';
latlonData = readtable(filename_latlon);

% 获取城市名称、纬度和经度
cityNames = latlonData{:, 1};
latitudes = latlonData{:, 3};
longitudes = latlonData{:, 2};

% 从城市名称中提取路径
path = {'广州', '东莞', '佛山', '江门', '中山', '深圳', '珠海', '惠州', '屯昌', '白沙', '昌江', '三亚', '湛江', '海口', '五指山'};

% 查找路径中城市的经纬度
pathLatitudes = [];
pathLongitudes = [];
for i = 1:length(path)
    idx = strcmp(cityNames, path{i});
    if any(idx)
        pathLatitudes = [pathLatitudes; latitudes(idx)];
        pathLongitudes = [pathLongitudes; longitudes(idx)];
    end
end

% 创建图形
figure;

% 绘制城市
plot(pathLongitudes, pathLatitudes, 'bo', 'MarkerSize', 8, 'MarkerFaceColor', 'b');
hold on;

% 绘制路径
plot(pathLongitudes, pathLatitudes, 'r-', 'LineWidth', 2);

% 添加城市名称标签
for i = 1:length(path)
    text(pathLongitudes(i), pathLatitudes(i), path{i}, 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right');
end

% 设置图形属性
xlabel('经度');
ylabel('纬度');
title('城市路径图');
grid on;
axis equal;
xlim([min(pathLongitudes) - 1, max(pathLongitudes) + 1]);
ylim([min(pathLatitudes) - 1, max(pathLatitudes) + 1]);

hold off;
