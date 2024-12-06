clc;
clear;
close all;
warning off;

%122
fileID = fopen('MIT-BIH\\121.dat'); % 使用两个反斜杠
A = fread(fileID);
fclose(fileID); % 读取完毕后关闭文件

fileID = fopen('MIT-BIH\\121.atr'); % 使用两个反斜杠
B = fread(fileID);
fclose(fileID); % 读取完毕后关闭文件

% 在FPGA中，保留一段进行测试，否则数据太大，硬件吃不消
X0 = A(1:8*16384);
% X0是原始信号
X0_mean = mean(X0); % 计算信号X0的均值
X0 = X0 - X0_mean; % 从信号中减去均值，去除直流分量


% 绘制原始信号
figure(1);
plot(X0(1:3000));
title('原始信号');

% 对原始信号进行FFT
N = length(X0); % 信号长度
Y0 = fft(X0); % 计算FFT
Y0=fftshift(Y0); 
P2_0 = abs(Y0/N); % 双边频谱
P1_0 = P2_0(1:N/2+1); % 单边频谱
P1_0(2:end-1) = 2*P1_0(2:end-1);


% 计算频率轴
fsam=150;
wsam=2*pi*fsam; 
f=(-(wsam)/2+(0:N-1)*(wsam)/N)/(2*pi); 
%f = (0:(N/2));

% 绘制原始信号的FFT结果
figure(2);
plot(f, P2_0);
title('原始信号频谱');
xlabel('Frequency (Hz)');
ylabel('|P1_0(f)|');

% 进行滤波
M = 16; % 定义滤波器的阶数


b = fir1(M, 0.1); % 使用fir1函数设计滤波器
X1 = filter(b, 1, X0);
% 计算频率响应
[H, w] = freqz(b, 1, 512, 150); % 假设Fs是采样频率
% 绘制频率响应的幅度
figure(11);
plot(w, abs(H));
xlabel('频率 (Hz)');
ylabel('幅度');
title('低通FIR滤波器的频率响应');
% 如果需要，也可以绘制相位响应
figure(12);
plot(w, angle(H));
xlabel('频率 (Hz)');
ylabel('相位 (弧度)');
title('低通FIR滤波器的相位响应');
figure(3);
plot(X1(1:3000));
title('低通滤波后信号');
% 对滤波后的信号进行FFT
Y1 = fft(X1); % 计算FFT
Y1=fftshift(Y1); 
P2_1 = abs(Y1/N); % 双边频谱
P1_1 = P2_1(1:N/2+1); % 单边频谱
P1_1(2:end-1) = 2*P1_1(2:end-1);

% 绘制滤波后信号的FFT结果
figure(4);
plot(f, P2_1);
ylim([0, max(P1_1)]); % 设置纵坐标显示范围从0到P1_1的最大值
title('低通滤波后信号频谱');
xlabel('Frequency (Hz)');
ylabel('|P1_1(f)|');

% 进行高通滤波
b = fir1(M, 0.12, 'high'); % 使用fir1函数设计滤波器
X3 = filter(b, 1, X1);
% 计算频率响应
[H, w] = freqz(b, 1, 512, 150); % 假设Fs是采样频率
% 绘制频率响应的幅度
figure(9);
plot(w, abs(H));
xlabel('频率 (Hz)');
ylabel('幅度');
title('高通FIR滤波器的频率响应');
% 如果需要，也可以绘制相位响应
figure(10);
plot(w, angle(H));
xlabel('频率 (Hz)');
ylabel('相位 (弧度)');
title('高通FIR滤波器的相位响应');



figure(5);
plot(X3(1:3000));
title('高通滤波后信号');
% 对高通滤波后的信号进行FFT
Y3 = fft(X3); % 计算FFT
Y3=fftshift(Y3); 
P2_3 = abs(Y3/N); % 双边频谱
P1_3 = P2_3(1:N/2+1); % 单边频谱
P1_3(2:end-1) = 2*P1_3(2:end-1);

% 绘制高通滤波后信号的FFT结果
figure(6);
plot(f, P2_3);
ylim([0, max(P1_3)]); % 设置纵坐标显示范围从0到P1_1的最大值
title('高通滤波后信号频谱');
xlabel('Frequency (Hz)');
ylabel('|P1_3(f)|');

% 均值滤波
X2 = abs(X3);
X2 = filter(ones(1, 30), 1, X2);
figure(7);
plot(X2(1:3000));
title('均值滤波后信号');
% 对均值滤波后的信号进行FFT
Y2 = fft(X2); % 计算FFT
Y2=fftshift(Y2);
P2_2 = abs(Y2/N); % 双边频谱
P1_2 = P2_2(1:N/2+1); % 单边频谱
P1_2(2:end-1) = 2*P1_2(2:end-1);

% 绘制均值滤波后信号的FFT结果
figure(8);
plot(f, P2_2);
ylim([0, max(P1_2)]); % 设置纵坐标显示范围从0到P1_1的最大值
title('均值滤波后信号频谱');
xlabel('Frequency (Hz)');
ylabel('|P1_2(f)|');

% 将处理后的信号yy写入文件
%yy = round(10*X2) - 30;
%figure;
%plot(X2(1:3000));



% 获取当前所有图形句柄
%figs = findobj('Type', 'figure');

% 循环遍历所有图形
%for i = 1:length(figs)
    % 保存每个图形
 %   saveas(figs(i), sprintf('figure_%d.png', i));
%end


