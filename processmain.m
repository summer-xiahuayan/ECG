clc;
fileID = fopen('MIT-BIH\\121.dat'); % ʹ��������б��
A = fread(fileID);
fclose(fileID); % ��ȡ��Ϻ�ر��ļ�

% ��FPGA�У�����һ�ν��в��ԣ���������̫��Ӳ���Բ���
M = A(1:8*16384);
TIME=1:8*16384;
%------------------------------��ͨ�˲����˳������ź�------------------------------
Fs=150;                        %����Ƶ��
fp=80;fs=100;                    %ͨ����ֹƵ�ʣ������ֹƵ��
rp=1.4;rs=1.6;                    %ͨ�������˥��
wp=2*pi*fp;ws=2*pi*fs;   
[n,wn]=buttord(wp,ws,rp,rs,'s');     %'s'��ȷ��������˹ģ���˲����״κ�3dB
                               %��ֹģ��Ƶ��
[z,P,k]=buttap(n);   %��ƹ�һ��������˹ģ���ͨ�˲�����zΪ���㣬pΪ����kΪ����
[bp,ap]=zp2tf(z,P,k)  %ת��ΪHa(p),bpΪ����ϵ����apΪ��ĸϵ��
[bs,as]=lp2lp(bp,ap,wp) %Ha(p)ת��Ϊ��ͨHa(s)��ȥ��һ����bsΪ����ϵ����asΪ��ĸϵ��
 
[hs,ws]=freqs(bs,as);         %ģ���˲����ķ�Ƶ��Ӧ
[bz,az]=bilinear(bs,as,Fs);     %��ģ���˲���˫���Ա任
[h1,w1]=freqz(bz,az);         %�����˲����ķ�Ƶ��Ӧ
m=filter(bz,az,M);
 
figure(1)
freqz(bz,az);title('������˹��ͨ�˲�����Ƶ����');
      
figure(2)
subplot(2,1,1);
plot(TIME,M);
xlabel('t(s)');ylabel('mv');title('ԭʼ�ĵ��źŲ���');grid;
 
subplot(2,1,2);
plot(TIME,m);
xlabel('t(s)');ylabel('mv');title('��ͨ�˲����ʱ��ͼ��');grid;
   
N=512
n=0:N-1;
mf=fft(M,N);
Y0=fftshift(mf); 
P2_0 = abs(Y0/N); % ˫��Ƶ��%����Ƶ�ױ任������Ҷ�任��
mag=abs(mf);
%f=(0:length(mf)-1)*Fs/length(mf);  %����Ƶ�ʱ任
 
% ����Ƶ����
fsam=150;
wsam=2*pi*fsam; 
f=(-(wsam)/2+(0:N-1)*(wsam)/N)/(2*pi); 


figure(3)
subplot(2,1,1)
plot(f,P2_0);axis([-80,80,1,50]);grid;      %����Ƶ��ͼ
xlabel('Ƶ��(HZ)');ylabel('��ֵ');title('�ĵ��ź�Ƶ��ͼ');
 
mfa=fft(m,N);                    %����Ƶ�ױ任������Ҷ�任��
%maga=abs(mfa);
Y0=fftshift(mfa); 
maga = abs(Y0/N);
fa=(0:length(mfa)-1)*Fs/length(mfa);  %����Ƶ�ʱ任
subplot(2,1,2)
plot(f,maga);axis([-80,80,1,50]);grid;  %����Ƶ��ͼ
xlabel('Ƶ��(HZ)');ylabel('��ֵ');title('��ͨ�˲����ĵ��ź�Ƶ��ͼ');
    
wn=M;
P=10*log10(abs(fftshift(fft(wn,N)).^2)/N);
%f=(0:length(P)-1)/length(P);
figure(4)
f1=(-(wsam)/2+(0:N-1)*(wsam)/N)/(2*pi);
plot(f1,P);grid
xlabel('��һ��Ƶ��');ylabel('����(dB)');title('�ĵ��źŵĹ�����');
 
%-----------------�����˲������ƹ�Ƶ����-------------------
%50Hz�ݲ�������һ����ͨ�˲�������һ����ͨ�˲������
%����ͨ�˲�����һ��ȫͨ�˲�����ȥһ����ͨ�˲�������
Me=100;               %�˲�������
L=100;                %���ڳ���
beta=100;             %˥��ϵ��
Fs=150;
wc1=49/Fs*pi;     %wc1Ϊ��ͨ�˲�����ֹƵ�ʣ���Ӧ51Hz
wc2=51/Fs*pi     ;%wc2Ϊ��ͨ�˲�����ֹƵ�ʣ���Ӧ49Hz
h=ideal_lp(0.132*pi,Me)-ideal_lp(wc1,Me)+ideal_lp(wc2,Me); %hΪ�ݲ��������Ӧ
w=kaiser(L,beta);
y=h.*rot90(w);         %yΪ50Hz�ݲ��������Ӧ����
m2=filter(y,1,m);
 
figure(5)
f2=(0:100-1);
subplot(2,1,1);plot(f2,(abs(fft(y)))/N);%axis([-80 80 -1 0]);
xlabel('Ƶ��(Hz)');ylabel('����(mv)');title('�ݲ���������');grid;
N=512;
P=10*log10(abs((fft(y)).^2)/N);
f2=(0:length(P)-1);
subplot(2,1,2);plot(f2,P);%axis([-100 100 -1 0])
xlabel('Ƶ��(Hz)');ylabel('����(dB)');title('�ݲ���������');grid;
   
figure(6)
subplot (2,1,1); plot(TIME,m);
xlabel('t(s)');ylabel('��ֵ');title('ԭʼ�ź�');grid;
subplot(2,1,2);plot(TIME,m2);
xlabel('t(s)');ylabel('��ֵ');title('�����˲����ź�');grid;
  
figure(7)
N=512
subplot(2,1,1);plot(f,abs(fftshift(fft(m,N)))/N);axis([-80 80 0 50]);
xlabel('t(s)');ylabel('��ֵ');title('ԭʼ�ź�Ƶ��');grid;
subplot(2,1,2);plot(f,abs(fftshift(fft(m2,N)))/N);axis([-80 80 0 50]);
xlabel('t(s)');ylabel('��ֵ');title('�����˲����ź�Ƶ��');grid;  
 


%������������IIR�����������˲�����������Ư�ơ�����������-  
Wp=1.4*2/Fs;     %ͨ����ֹƵ��   
Ws=0.6*2/Fs;     %�����ֹƵ��   
devel=0.005;    %ͨ���Ʋ�   
Rp=20*log10((1+devel)/(1-devel));   %ͨ���Ʋ�ϵ��    
Rs=20;                          %���˥��   
[N Wn]=ellipord(Wp,Ws,Rp,Rs,'s');   %����Բ�˲����Ľ״�   
[b a]=ellip(N,Rp,Rs,Wn,'high');       %����Բ�˲�����ϵ��   
[hw,w]=freqz(b,a,512);     
result =filter(b,a,m2);   
  
figure(8)  
freqz(b,a);  
title('�����˲���')
figure(9)  
subplot(211); plot(TIME,m2);   
xlabel('t(s)');ylabel('��ֵ');title('ԭʼ�ź�');grid  
subplot(212); plot(TIME,result);   
xlabel('t(s)');ylabel('��ֵ');title('�����˲����ź�');grid  
    
figure(10)  
N=512  
subplot(2,1,1);plot(f,abs(fftshift(fft(m2,N)))/N);  
xlabel('Ƶ��(Hz)');ylabel('��ֵ');title('ԭʼ�ź�Ƶ��');grid;  
subplot(2,1,2);plot(f,abs(fftshift(fft(result,N)))/N);  
xlabel('Ƶ��(Hz)');ylabel('��ֵ');title('�����˲���');grid; 
  


% ��ȡ��ǰ����ͼ�ξ��
figs = findobj('Type', 'figure');

% ѭ����������ͼ��
for i = 1:length(figs)
    % ����ÿ��ͼ��
    saveas(figs(i), sprintf('ecg_%d.png', i));
end