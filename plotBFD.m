load('Fault_Diag_Data.mat')
% 假设TrainData是一个cell数组，其中每个元素包含data结构体
% data结构体包含DE_time、FE_time、BA_time三个字段

% 颜色数组，用于区分不同的时间序列
colors = ['r', 'g', 'b']; % 红、绿、蓝

% 遍历TrainData中的每个元素
for i = 1:length(TrainData)
% 获取当前数据集的时间序列
deTime = TrainData{i}.data.DE_time(1:1024);
feTime = TrainData{i}.data.FE_time(1:1024);
baTime = TrainData{i}.data.BA_time(1:1024);

% 创建新的图形窗口
figure;

% 绘制DE_time，使用红色
plot(deTime, colors(1), 'LineWidth', 0.5);
hold on; % 保持当前图形，以便在同一图上绘制其他时间序列

% 绘制FE_time，使用绿色
plot(feTime, colors(2), 'LineWidth', 0.5);

% 绘制BA_time，使用蓝色
plot(baTime, colors(3), 'LineWidth', 0.5);

% 添加图例

% 设置标题，使用当前数据集的标签
title(sprintf('%s',TrainData{i}.label));

% 设置轴标签
%xlabel('Sample Index');
%ylabel('Amplitude');
xlim([0,1024]);
% 解除hold状态
hold off;
end


% 获取当前所有图形句柄
figs = findobj('Type', 'figure');

% 循环遍历所有图形
for i = 1:length(figs)
    % 保存每个图形
    saveas(figs(i), sprintf('BFD_%d.png', i));
end
%legend('DE_ time', 'FE_ time', 'BA_ time');
