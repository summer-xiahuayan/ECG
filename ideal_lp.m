%���У�ideal_lp������������һ��M�ļ��У��������£�
%�����ͨ�˲���
%��ֹ��Ƶ��wc������Me
function hd=ideal_lp(wc,Me)
alpha=(Me-1)/2;
n=[0:Me-1];
p=n-alpha+eps;              %epsΪ��С���������ⱻ0��
hd=sin(wc*p)./(pi*p);       %��Sin�������������Ӧ
end