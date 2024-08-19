clc;
clear;

% 读取城市距离矩阵
filename = '城市距离矩阵.xlsx';
distanceMatrix = readmatrix(filename,'Range','B2:AY51');


% 高铁定价标准
baseRate = 0.46;  % 元/公里

% 定价折扣
distanceBrackets = [500, 1000, 1500, 2000, 2500, 3000];
discounts = [1, 0.9, 0.8, 0.7, 0.6, 0.5];  % 对应折扣

% 计算交通费用矩阵
numCities = size(distanceMatrix, 1);
costMatrix = zeros(numCities);

% 计算每对城市之间的交通费用
for i = 1:numCities
    for j = 1:numCities
        distance = distanceMatrix(i, j);
        
        if distance == 0
            costMatrix(i, j) = 0;  % 距离为零，费用也为零
        elseif distance < 0
            costMatrix(i, j) = NaN;  % 如果距离为负，设为 NaN
        else
            cost = 0;
            remainingDistance = distance;

            % 逐段计算费用
            for k = 1:length(distanceBrackets)
                if remainingDistance > distanceBrackets(k)
                    if k == 1
                        segmentDistance = distanceBrackets(k);  % 第一段的距离
                    else
                        segmentDistance = distanceBrackets(k) - distanceBrackets(k-1);
                    end
                else
                    if k == 1
                        segmentDistance = remainingDistance;
                    else
                        segmentDistance = remainingDistance - distanceBrackets(k-1);
                    end
                end
                
                % 计算该段距离的费用
                segmentCost = segmentDistance * baseRate * discounts(k);
                cost = cost + segmentCost;

                % 更新剩余距离
                remainingDistance = remainingDistance - segmentDistance;

                % 如果没有剩余距离，退出循环
                if remainingDistance <= 0
                    break;
                end
            end
            
            % 计算最后一段超过最大折扣的部分（如果有）
            if remainingDistance > 0
                cost = cost + remainingDistance * baseRate * discounts(end);
            end
            
            costMatrix(i, j) = cost;
        end
    end
end

% 读取城市名称
cityNames = readcell(filename, 'Range', 'A2:A51');  % 假设城市名称在第一列，从第1行到第50行
cityNames = cityNames(:);  % 转换为列向量

% 添加城市名称作为第一行和第一列
costMatrixWithNames = [[{'城市'}, cityNames']; [cityNames, num2cell(costMatrix)]];

% 将交通费用矩阵保存至新的 Excel 文件
writecell(costMatrixWithNames, '城市交通费用矩阵.xlsx');

% 输出提示信息
fprintf('交通费用矩阵已成功保存到文件“城市交通费用矩阵.xlsx”。\n');
