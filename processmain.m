clc;
fileID = fopen('MIT-BIH\\121.dat'); % 使用两个反斜杠
A = fread(fileID);
fclose(fileID); % 读取完毕后关闭文件

% 在FPGA中，保留一段进行测试，否则数据太大，硬件吃不消
M = A(1:8*16384);
TIME=1:8*16384;
%------------------------------低通滤波器滤除肌电信号------------------------------
Fs=150;                        %采样频率
fp=80;fs=100;                    %通带截止频率，阻带截止频率
rp=1.4;rs=1.6;                    %通带、阻带衰减
wp=2*pi*fp;ws=2*pi*fs;   
[n,wn]=buttord(wp,ws,rp,rs,'s');     %'s'是确定巴特沃斯模拟滤波器阶次和3dB
                               %截止模拟频率
[z,P,k]=buttap(n);   %设计归一化巴特沃斯模拟低通滤波器，z为极点，p为零点和k为增益
[bp,ap]=zp2tf(z,P,k)  %转换为Ha(p),bp为分子系数，ap为分母系数
[bs,as]=lp2lp(bp,ap,wp) %Ha(p)转换为低通Ha(s)并去归一化，bs为分子系数，as为分母系数
 
[hs,ws]=freqs(bs,as);         %模拟滤波器的幅频响应
[bz,az]=bilinear(bs,as,Fs);     %对模拟滤波器双线性变换
[h1,w1]=freqz(bz,az);         %数字滤波器的幅频响应
m=filter(bz,az,M);
 
figure(1)
freqz(bz,az);title('巴特沃斯低通滤波器幅频曲线');
      
figure(2)
subplot(2,1,1);
plot(TIME,M);
xlabel('t(s)');ylabel('mv');title('原始心电信号波形');grid;
subplot(2,1,2);
plot(TIME,m);
xlabel('t(s)');ylabel('mv');title('低通滤波后的时域图形');grid;

figure(14)
plot(TIME,M);
xlabel('t(s)');ylabel('mv');title('原始心电信号波形');grid;
axis([4500 7500 0 300])

   
N=512
n=0:N-1;
mf=fft(M,N);
Y0=fftshift(mf); 
P2_0 = abs(Y0/N); % 双边频谱%进行频谱变换（傅里叶变换）
mag=abs(mf);
%f=(0:length(mf)-1)*Fs/length(mf);  %进行频率变换
 
% 计算频率轴
fsam=150;
wsam=2*pi*fsam; 
f=(-(wsam)/2+(0:N-1)*(wsam)/N)/(2*pi); 


figure(3)
subplot(2,1,1)
plot(f,P2_0);axis([-800,800,1,50]);grid;      %画出频谱图
xlabel('频率(HZ)');ylabel('幅值');title('心电信号频谱图');
 
mfa=fft(m,N);                    %进行频谱变换（傅里叶变换）
%maga=abs(mfa);
Y0=fftshift(mfa); 
maga = abs(Y0/N);
fa=(0:length(mfa)-1)*Fs/length(mfa);  %进行频率变换
subplot(2,1,2)
plot(f,maga);axis([-80,80,1,50]);grid;  %画出频谱图
xlabel('频率(HZ)');ylabel('幅值');title('低通滤波后心电信号频谱图');
    
wn=M;
P=10*log10(abs(fftshift(fft(wn,N)).^2)/N);
%f=(0:length(P)-1)/length(P);
figure(4)
f1=(-(wsam)/2+(0:N-1)*(wsam)/N)/(2*pi);
plot(f1,P);grid
xlabel('归一化频率');ylabel('功率(dB)');title('心电信号的功率谱');
 
%-----------------带陷滤波器抑制工频干扰-------------------
%50Hz陷波器：由一个低通滤波器加上一个高通滤波器组成
%而高通滤波器由一个全通滤波器减去一个低通滤波器构成
Me=100;               %滤波器阶数
L=100;                %窗口长度
beta=100;             %衰减系数
Fs=360;
wc1=49/Fs*pi;     %wc1为高通滤波器截止频率，对应51Hz
wc2=51/Fs*pi     ;%wc2为低通滤波器截止频率，对应49Hz
h=ideal_lp(0.132*pi,Me)-ideal_lp(wc1,Me)+ideal_lp(wc2,Me); %h为陷波器冲击响应
w=kaiser(L,beta);
y=h.*rot90(w);         %y为50Hz陷波器冲击响应序列
m2=filter(y,1,m);
 
figure(5)
f2=(0:100-1);
subplot(2,1,1);plot(f2,(abs(fft(y)))/N);%axis([-80 80 -1 0]);
xlabel('频率(Hz)');ylabel('幅度(mv)');title('陷波器幅度谱');grid;
N=512;
P=10*log10(abs((fft(y)).^2)/N);
f2=(0:length(P)-1);
subplot(2,1,2);plot(f2,P);%axis([-100 100 -1 0])
xlabel('频率(Hz)');ylabel('功率(dB)');title('陷波器功率谱');grid;
   
figure(6)
subplot (2,1,1); plot(TIME,m);
xlabel('t(s)');ylabel('幅值');title('原始信号');grid;
subplot(2,1,2);plot(TIME,m2);
xlabel('t(s)');ylabel('幅值');title('带阻滤波后信号');grid;
  
figure(7)
N=512
subplot(2,1,1);plot(f,abs(fftshift(fft(m,N)))/N);axis([-80 80 0 50]);
xlabel('t(s)');ylabel('幅值');title('原始信号频谱');grid;
subplot(2,1,2);plot(f,abs(fftshift(fft(m2,N)))/N);axis([-80 80 0 50]);
xlabel('t(s)');ylabel('幅值');title('带阻滤波后信号频谱');grid;  
 


%——————IIR零相移数字滤波器纠正基线漂移——————-  
Wp=1.4*2/Fs;     %通带截止频率   
Ws=0.6*2/Fs;     %阻带截止频率   
devel=0.005;    %通带纹波   
Rp=20*log10((1+devel)/(1-devel));   %通带纹波系数    
Rs=20;                          %阻带衰减   
[N Wn]=ellipord(Wp,Ws,Rp,Rs,'s');   %求椭圆滤波器的阶次   
[b a]=ellip(N,Rp,Rs,Wn,'high');       %求椭圆滤波器的系数   
[hw,w]=freqz(b,a,512);     
result =filter(b,a,m2);   
  
figure(8)  
freqz(b,a);  
title('线性滤波器')
figure(9)  
subplot(211); plot(TIME,m2);   
xlabel('t(s)');ylabel('幅值');title('原始信号');grid  
subplot(212); plot(TIME,result);   
xlabel('t(s)');ylabel('幅值');title('线性滤波后信号');grid  
    
figure(10)  
N=512  
subplot(2,1,1);plot(f,abs(fftshift(fft(m2,N)))/N);  
xlabel('频率(Hz)');ylabel('幅值');title('原始信号频谱');grid;  
subplot(2,1,2);plot(f,abs(fftshift(fft(result,N)))/N);  
xlabel('频率(Hz)');ylabel('幅值');title('线性滤波后');grid; 
  


% 均值滤波
X2 = result;
X2 = filter(ones(1, 30), 1, X2);
figure(11);
subplot(2,1,1);
plot(result);axis([4500 7500 -80 80])
title('均值滤波前信号');grid;
subplot(2,1,2);
plot(X2);axis([4500 7500 -1000 1000])
title('均值滤波后信号');grid;




% 对均值滤波后的信号进行FFT
Y2 = fft(X2,N); % 计算FFT
Y2=fftshift(Y2);
P2_2 = abs(Y2/N); % 双边频谱
P1_2 = P2_2(1:N/2+1); % 单边频谱
P1_2(2:end-1) = 2*P1_2(2:end-1);

% 绘制均值滤波后信号的FFT结果
figure(12);
subplot(2,1,1);
plot(f,abs(fftshift(fft(result,N)))/N);
title('均值滤波前信号频谱');grid;
subplot(2,1,2);
plot(f, P2_2);
title('均值滤波后信号频谱');grid;


[pks, locs] = findpeaks(X2, 'MinPeakHeight', 400, 'MinPeakDistance', 50);

% 计算相邻峰值位置之间的差值
differences = diff(locs);

% 求这些差值的平均值
averageDifference = mean(differences);

% 计算阈值，即平均间隔的1/3
threshold = averageDifference*3 / 5;

% 初始化新的峰值列表
newPks = pks(1); % 从第一个峰值开始
newLocs = locs(1); % 从第一个峰值位置开始

% 遍历原始的峰值位置，从第二个峰值开始
for i = 2:length(locs)
    % 如果当前峰值与上一个峰值的间隔大于阈值，则添加当前峰值
    if locs(i) - newLocs(end) > threshold
        newPks(end+1) = pks(i);
        newLocs(end+1) = locs(i);
    elseif pks(i) > newPks(end) % 如果当前峰值的高度大于上一个保留的峰值
        % 则替换上一个峰值为当前峰值
        newPks(end) = pks(i);
        newLocs(end) = locs(i);
    end
end


figure(13)
plot(X2, 'b');   % 绘制原始数据，'b'表示蓝色
hold on;        % 保持当前图形，以便在上面添加新的图形层
% 绘制峰值
plot(newLocs, newPks, 'r*', 'MarkerSize', 10); % 'r*'表示红色星号标记
axis([4500 7500 -1500 1500])
% 可选：添加图例和标签
legend('Original Data', 'Peaks');
xlabel('Data Points');
ylabel('Amplitude');
% 可选：设置图形标题
title('Peak Detection');
hold off; % 释放图形，完成绘图

heart_rate=length(newPks)/(length(M)/Fs/60)
disp(averageDifference)
% 获取当前所有图形句柄
%figs = findobj('Type', 'figure');

% 循环遍历所有图形
%for i = 1:length(figs)
    % 保存每个图形
 %   saveas(figs(i), sprintf('ecg_%d.png', i));
%end





figure(15)
subplot(3,2,1);plot(TIME,M);title('原始心电信号波形');grid;axis([4500 7500 0 300]);
subplot(3,2,2);plot(TIME,m);title('低通滤波后的波形');grid;axis([4500 7500 0 300]);
subplot(3,2,3);plot(TIME,m2);title('带阻滤波后波形');grid;axis([4500 7500 20 150]);
subplot(3,2,4); plot(TIME,result);title('线性滤波后波形');grid;axis([4500 7500 -80 80]);  
subplot(3,2,5);plot(X2);title('均值滤波后波形');grid;axis([4500 7500 -1000 1000]);
subplot(3,2,6);plot(X2, 'b');   hold on; plot(newLocs, newPks, 'r*', 'MarkerSize', 10);title('心跳检测算法'); grid;axis([4500 7500 -1000 1000]);


%------------------------------心跳的时域特征------------------------------
% 计算相邻心跳之间的间隔（RR间期）
RR_intervals = diff(newLocs);
% 计算RR间期的均值
mean_RR = mean(RR_intervals);
% 计算RR间期的标准差
sd_RR = std(RR_intervals);
% 计算变异系数（CV），即标准差除以均值
cv_RR = sd_RR / mean_RR;
% 计算区间连续差的标准差（RMSSD）
rmssd_RR = sqrt(sum((RR_intervals(1:end-1) - RR_intervals(2:end)).^2) / (length(RR_intervals) - 1));
% 显示结果
fprintf('心跳间隔的均值是: %f\n', mean_RR);
fprintf('心跳间隔的标准差是: %f\n', sd_RR);
fprintf('心跳间隔的变异系数（CV）是: %f\n', cv_RR);
fprintf('区间连续差的标准差（RMSSD）是: %f\n', rmssd_RR);

%------------------------------心跳的频域特征------------------------------
Fs = 150;
% 计算FFT
N = length(X2);
X2_fft = fft(X2);
% 计算功率谱
Pxx = (abs(X2_fft).^2) / N;
% 确定频率范围
f = (0:N-1) * (Fs / N);
% 找到低频和高频范围的索引
low_freq_range = f >= 0.04 & f <= 0.15;
high_freq_range = f >= 0.15 & f <= 0.4;
% 计算低频和高频功率
low_freq_power = sum(Pxx(low_freq_range));
high_freq_power = sum(Pxx(high_freq_range));
% 计算功率比
power_ratio = low_freq_power / high_freq_power;
% 显示结果
fprintf('低频功率是: %f\n', low_freq_power);
fprintf('高频功率是: %f\n', high_freq_power);
fprintf('功率比是: %f\n', power_ratio);

%------------------------------心跳的分布特征------------------------------
% 计算偏度
skewness_value = skewness(X2);
% 计算熵
entropy_value = entropy(X2);
% 显示结果
fprintf('偏度值是: %f\n', skewness_value);
fprintf('熵值是: %f\n', entropy_value);
% 绘制直方图查看分布特征
figure(16);
histogram(X2);
title('数据分布特征');






