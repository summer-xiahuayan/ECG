load('Fault_Diag_Data.mat')
% ����TrainData��һ��cell���飬����ÿ��Ԫ�ذ���data�ṹ��
% data�ṹ�����DE_time��FE_time��BA_time�����ֶ�

% ��ɫ���飬�������ֲ�ͬ��ʱ������
colors = ['r', 'g', 'b']; % �졢�̡���

% ����TrainData�е�ÿ��Ԫ��
for i = 1:length(TrainData)
% ��ȡ��ǰ���ݼ���ʱ������
deTime = TrainData{i}.data.DE_time(1:1024);
feTime = TrainData{i}.data.FE_time(1:1024);
baTime = TrainData{i}.data.BA_time(1:1024);

% �����µ�ͼ�δ���
figure;

% ����DE_time��ʹ�ú�ɫ
plot(deTime, colors(1), 'LineWidth', 0.5);
hold on; % ���ֵ�ǰͼ�Σ��Ա���ͬһͼ�ϻ�������ʱ������

% ����FE_time��ʹ����ɫ
plot(feTime, colors(2), 'LineWidth', 0.5);

% ����BA_time��ʹ����ɫ
plot(baTime, colors(3), 'LineWidth', 0.5);

% ���ͼ��

% ���ñ��⣬ʹ�õ�ǰ���ݼ��ı�ǩ
title(sprintf('%s',TrainData{i}.label));

% �������ǩ
%xlabel('Sample Index');
%ylabel('Amplitude');
xlim([0,1024]);
% ���hold״̬
hold off;
end


% ��ȡ��ǰ����ͼ�ξ��
figs = findobj('Type', 'figure');

% ѭ����������ͼ��
for i = 1:length(figs)
    % ����ÿ��ͼ��
    saveas(figs(i), sprintf('BFD_%d.png', i));
end
%legend('DE_ time', 'FE_ time', 'BA_ time');
