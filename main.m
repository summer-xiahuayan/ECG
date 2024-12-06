clc;
clear;
close all;
warning off;

%122
fileID = fopen('MIT-BIH\\121.dat'); % ʹ��������б��
A = fread(fileID);
fclose(fileID); % ��ȡ��Ϻ�ر��ļ�

fileID = fopen('MIT-BIH\\121.atr'); % ʹ��������б��
B = fread(fileID);
fclose(fileID); % ��ȡ��Ϻ�ر��ļ�

% ��FPGA�У�����һ�ν��в��ԣ���������̫��Ӳ���Բ���
X0 = A(1:8*16384);
% X0��ԭʼ�ź�
X0_mean = mean(X0); % �����ź�X0�ľ�ֵ
X0 = X0 - X0_mean; % ���ź��м�ȥ��ֵ��ȥ��ֱ������


% ����ԭʼ�ź�
figure(1);
plot(X0(1:3000));
title('ԭʼ�ź�');

% ��ԭʼ�źŽ���FFT
N = length(X0); % �źų���
Y0 = fft(X0); % ����FFT
Y0=fftshift(Y0); 
P2_0 = abs(Y0/N); % ˫��Ƶ��
P1_0 = P2_0(1:N/2+1); % ����Ƶ��
P1_0(2:end-1) = 2*P1_0(2:end-1);


% ����Ƶ����
fsam=150;
wsam=2*pi*fsam; 
f=(-(wsam)/2+(0:N-1)*(wsam)/N)/(2*pi); 
%f = (0:(N/2));

% ����ԭʼ�źŵ�FFT���
figure(2);
plot(f, P2_0);
title('ԭʼ�ź�Ƶ��');
xlabel('Frequency (Hz)');
ylabel('|P1_0(f)|');

% �����˲�
M = 16; % �����˲����Ľ���


b = fir1(M, 0.1); % ʹ��fir1��������˲���
X1 = filter(b, 1, X0);
% ����Ƶ����Ӧ
[H, w] = freqz(b, 1, 512, 150); % ����Fs�ǲ���Ƶ��
% ����Ƶ����Ӧ�ķ���
figure(11);
plot(w, abs(H));
xlabel('Ƶ�� (Hz)');
ylabel('����');
title('��ͨFIR�˲�����Ƶ����Ӧ');
% �����Ҫ��Ҳ���Ի�����λ��Ӧ
figure(12);
plot(w, angle(H));
xlabel('Ƶ�� (Hz)');
ylabel('��λ (����)');
title('��ͨFIR�˲�������λ��Ӧ');
figure(3);
plot(X1(1:3000));
title('��ͨ�˲����ź�');
% ���˲�����źŽ���FFT
Y1 = fft(X1); % ����FFT
Y1=fftshift(Y1); 
P2_1 = abs(Y1/N); % ˫��Ƶ��
P1_1 = P2_1(1:N/2+1); % ����Ƶ��
P1_1(2:end-1) = 2*P1_1(2:end-1);

% �����˲����źŵ�FFT���
figure(4);
plot(f, P2_1);
ylim([0, max(P1_1)]); % ������������ʾ��Χ��0��P1_1�����ֵ
title('��ͨ�˲����ź�Ƶ��');
xlabel('Frequency (Hz)');
ylabel('|P1_1(f)|');

% ���и�ͨ�˲�
b = fir1(M, 0.12, 'high'); % ʹ��fir1��������˲���
X3 = filter(b, 1, X1);
% ����Ƶ����Ӧ
[H, w] = freqz(b, 1, 512, 150); % ����Fs�ǲ���Ƶ��
% ����Ƶ����Ӧ�ķ���
figure(9);
plot(w, abs(H));
xlabel('Ƶ�� (Hz)');
ylabel('����');
title('��ͨFIR�˲�����Ƶ����Ӧ');
% �����Ҫ��Ҳ���Ի�����λ��Ӧ
figure(10);
plot(w, angle(H));
xlabel('Ƶ�� (Hz)');
ylabel('��λ (����)');
title('��ͨFIR�˲�������λ��Ӧ');



figure(5);
plot(X3(1:3000));
title('��ͨ�˲����ź�');
% �Ը�ͨ�˲�����źŽ���FFT
Y3 = fft(X3); % ����FFT
Y3=fftshift(Y3); 
P2_3 = abs(Y3/N); % ˫��Ƶ��
P1_3 = P2_3(1:N/2+1); % ����Ƶ��
P1_3(2:end-1) = 2*P1_3(2:end-1);

% ���Ƹ�ͨ�˲����źŵ�FFT���
figure(6);
plot(f, P2_3);
ylim([0, max(P1_3)]); % ������������ʾ��Χ��0��P1_1�����ֵ
title('��ͨ�˲����ź�Ƶ��');
xlabel('Frequency (Hz)');
ylabel('|P1_3(f)|');

% ��ֵ�˲�
X2 = abs(X3);
X2 = filter(ones(1, 30), 1, X2);
figure(7);
plot(X2(1:3000));
title('��ֵ�˲����ź�');
% �Ծ�ֵ�˲�����źŽ���FFT
Y2 = fft(X2); % ����FFT
Y2=fftshift(Y2);
P2_2 = abs(Y2/N); % ˫��Ƶ��
P1_2 = P2_2(1:N/2+1); % ����Ƶ��
P1_2(2:end-1) = 2*P1_2(2:end-1);

% ���ƾ�ֵ�˲����źŵ�FFT���
figure(8);
plot(f, P2_2);
ylim([0, max(P1_2)]); % ������������ʾ��Χ��0��P1_1�����ֵ
title('��ֵ�˲����ź�Ƶ��');
xlabel('Frequency (Hz)');
ylabel('|P1_2(f)|');

% ���������ź�yyд���ļ�
%yy = round(10*X2) - 30;
%figure;
%plot(X2(1:3000));



% ��ȡ��ǰ����ͼ�ξ��
%figs = findobj('Type', 'figure');

% ѭ����������ͼ��
%for i = 1:length(figs)
    % ����ÿ��ͼ��
 %   saveas(figs(i), sprintf('figure_%d.png', i));
%end


