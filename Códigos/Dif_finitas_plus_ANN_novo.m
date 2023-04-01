clear all
clc

%% Resolução numérica do modelo por Diferenças Finitas
%% ------------------------------------------------------------------------ 
% Utilização do modelo RNA para estimação dos das propriedades físicas
%da goiaba (densidade, diâmetro das partículas e umidade em b.s)
%--------------------------------------------------------------------------

ex = input('Insira o experimento a ser simulado:');
A = xlsread('F:\Documentos\Estudos\Mestrado\Dados e modelos\Bancos de dados\Banco de dados - Marcelo interpolados.xlsx', 'Dados interpolados (9 pts exp)');
D = A(1:180,1:7);
if (ex == 1)
    Z1= D(1:20,1:7);
    Up(1) = 0.649;
    hi = 0.09;
    v_vjm = 2;
    uar = 2.8;
end
if (ex == 2)
    Z1= D(21:40,1:7);
    Up(1) = 0.645;
    hi = 0.12;
    v_vjm = 1.07;
    uar = 2.8;
end
if (ex == 3)
    Z1= D(41:60,1:7);
    Up(1) = 1.478;
    hi = 0.09;
    v_vjm = 1.1;
    uar = 2.8;
end
if (ex == 4)
    Z1= D(61:80,1:7);
    Up(1) = 1.523;
    hi = 0.12;
    v_vjm = 1;
    uar = 2.8;
end
if (ex == 5)
    yy = msgbox('Você não possui dados deste experimento');
end
if (ex == 6)
    Z1= D(81:100,1:7);
    Up(1) = 0.622;
    hi = 0.12;
    v_vjm = 1.3;
    uar = 3.5;
end
if (ex == 7)
    Z1= D(101:120,1:7);
    Up(1) = 1.5;
    hi = 0.09;
    v_vjm = 1.4;
    uar = 3.5;
end
if (ex == 8)
    Z1= D(121:140,1:7);
    Up(1) = 1.4;
    hi = 0.12;
    v_vjm = 1.25;
    uar = 3.5;
end
if (ex == 9)
    Z1= D(141:160,1:7);
    Up(1) = 1.045;
    hi = 0.105;
    v_vjm = 1.88;
    uar = 3.2;
end
if (ex == 10)
    Z1= D(161:180,1:7);
    Up(1) = 1.050;
    hi = 0.105;
    v_vjm = 1.88;
    uar = 3.2;
end
    e1 = Z1(:,1:4);
    s1 = Z1(:,5:7);
    e1 = e1';
    s1 = s1';
    t_min = D(1:20,1);
    Z1 = Z1';
    D = D';
    
%--------------------------------------------------------------------------
% Discretização da variável tempo(s) e carregamento das variáveis de
% entrada do modelo 
%--------------------------------------------------------------------------
a = 0; % Limite inferior do intervalo
b = 3600; %limite superior do intervalo
N = 36000; %Quantidade de intervalos
h = (b-a)/N;
t1= [0:h:3600]; % Definição da malha
p= length(t1); % Tamanho de elementos contidos na malha

[Y1des]= ANN (Z1,e1,s1,D);
[div ,ac ,ao ,at_coluna ,kp ,r1 ,r2 ,L ,vj ,ro_ar ,visc_ar ,k_ar ,RA ,P ,t_ar ,Tar_e ,T_ar_ext ,Urel_e ,Urel ,Uabs_e ,cps ,ro_p_ap ,hparede ,cal_lat ,cpar ,cpl ,cpv ,ro_p ,dp ,Ubs ,Rep1 ,Nu ,hp1 ,St ,Rep2 ,hw1 ,e ,ae1 ,aet ,X1 ,t_seg ,X ,ae ,hp ,hw ,d_xp ,tt ,z ,vl ,mg ,mss ,mss1 ,d_xp2 ,Ubu]= variaveis (h, v_vjm, Y1des, hi, uar, t_min);
[G ,u, Pvse, Pve, UAEsat, UAE, He]= prop_ar (ro_ar,uar,ac, ao, at_coluna,t_ar, Tar_e, Urel_e, P);

%--------------------------------------------------------------------------
%Resolução numérica das equações
%--------------------------------------------------------------------------

%%% Condições iniciais de temperatura das partículas (Condição de contorno)
Tp(1)= 303.15; % Temperatura inicial do leito de partículas(K) (j)
Tar_s(1)= 300.15; % Temperatura no t = 0 na saída do secador
tar_s(1) = Tar_s(1)-273.15; % Temperatura do ar na saída do secador em °C

%%% Cálculo das propriedades do ar na saída do secador
Pvs1(1) = exp((-7511.52/Tar_s(1))+89.63121+(0.02399897*Tar_s(1))-...
    (1.1654551E-5*(Tar_s(1)^2))-(1.2810336E-8*(Tar_s(1)^3))+(2.0998405E-11*...
    (Tar_s(1)^4))-(12.150799*log(Tar_s(1)))); % Pressão de vapor na Saturação (kPa) (j)
Uabs_sat(1) = 0.62198*(Pvs1(1)/(P-Pvs1(1))); % Umidade absoluta na saturação na saída do secador (kg/kg) (j)
Pv1(1) = Urel_e*Pvs1(1); % Pressão de vapor (kPa) (j)
Uabs(1) = 0.62198*(Pv1(1)/(P-Pv1(1))); % Umidade absoluta do ar na saída do secador (kg/kg) (j)
Uabs1(1) = Uabs_e-(((d_xp(1)*mss(1)))/G); % Cálculo da Razão de mistura(kg/kg) (j)
tpo(1) = (13.8+9.478*(log(Pv1(1)))+1.9910*((log(Pv1(1)))^2))+273.15; % Temperatura do ponto de orvalho (K) (j)
v(1) = ((RA*Tar_s(1))/P)*(1+1.6078*Uabs(1));% Volume específico (m³/kg) (j)
Hs(1) = ((1.006*tar_s(1))+(Uabs(1)*(2501+(1.775*(tar_s(1))))))*1000; % Entalpia do ar em (J/Kg) (j)
%UR(1) = (exp(5417*((1/Tar_s(1))-(1/tpo(1)))))*100; % Umidade relativa do ar (%) (j)
%UR(1) = (Pv1(1)/Pvs1(1))*100;
% Qp(1)= (Tar_s(1)- T_ar_ext)/((1/(hw(1)*2*pi*r1*hi))+((log(r2/r1))/(2*pi*kp*L))...
%     +(1/(hparede*2*pi*r2*L))); %Cálculo da perda de calor do secador p/ ambiente (W) (j)
Qp (1) = 0;
deltaT(1) = ((G*(He-Hs(1)))-Qp(1))/(hp(1)*ae(1)*vl);% Cálculo do delta T (j)
Tpc(1) = Tp(1) - 273.15;
Tar_sc(1) = Tar_s(1) - 273.15;
AA(1) = G*(He-Hs(1));
BB(1) = hp(1)*ae(1)*deltaT(1)*vl;
CC(1) = mss(1)*cal_lat*d_xp(1);
DD(1) = hp(1)*ae(1)*vl;
EE(1) = cps*mss(1);

for i=2:(p-1)
  
%%% Cálculo das propriedades do ar na saída do secador
Tar_s(i) = (2*deltaT(i-1))+(2*Tp(i-1))-Tar_e;
if Tar_s(i) < 300.15
   Tar_s(i) = 300.15;
end
if Tp(i-1) < 303.15
   Tp(i-1) = 303.15;
end
% Tar_s(i)= (2*Tp(i-1))- 2*(((G*(He-Hs(i-1)))-Qp(i-1))/(hp(i)*ae(i)))-...
%      Tar_e; % Temperatura do ar na saída do secador (K) (j+1)
tar_s(i) = Tar_s(i)-273.15; % Temperatura do ar na saída do secador em °C
Pvs1(i) = exp((-7511.52/Tar_s(i))+89.63121+(0.02399897*Tar_s(i))-...
    (1.1654551E-5*(Tar_s(i)^2))-(1.2810336E-8*(Tar_s(i)^3))+(2.0998405E-11*...
    (Tar_s(i)^4))-(12.150799*log(Tar_s(i)))); % Pressão de vapor na Saturação (kPa) (j+1)
Pv1(i) = Urel_e*Pvs1(i); % Pressão de vapor (kPa) (j+1)
Uabs_sat(i) = 0.62198*(Pvs1(i)/(P-Pvs1(i))); % Umidade absoluta na saturação na saída do secador(%) (j+1)
Uabs(i) = 0.62198*(Pv1(i)/(P-Pv1(i))); % Umidade absoluta do ar na saída do secador (kg/kg) (j+1)
Uabs1(i) = Uabs_e-(((d_xp(i)*mss(i)))/G); % Cálculo da Razão de mistura(kg/kg) (j+1)
tpo(i) = (6.983+14.38*(log(Pv1(i)))+1.079*((log(Pv1(i)))^2))+273.15;
% tpo(i) = (13.8+9.478*(log(Pv1(i)))+1.9910*((log(Pv1(i)))^2))+273.15; % Temperatura do ponto de orvalho (K) (j+1)
v(i) = ((RA*Tar_s(i))/P)*(1+1.6078*Uabs(i)); % Volume específico (m³/kg) (j+1)
%UR(i) = (exp(5417*((1/Tar_s(i))-(1/tpo(i)))))*100; % Umidade relativa do ar (%) (j+1)
%UR(i) = (Pv1(i)/Pvs1(i))*100;
Hs(i) = ((1.006*tar_s(i))+(Uabs(i)*(2501+(1.775*(tar_s(i))))))*1000; % Cálculo da entalpia do ar na saída do secador (j+1)

%%% Temperatura das partículas e Qp pelo secador para o ar externo
% Qp(i)= (Tar_s(i)-T_ar_ext)/((1/(hw(i)*2*pi*r1*hi))+((log(r2/r1))/(2*pi*kp*L))...
%     +(1/(hparede*2*pi*r2*L))); %Cálculo da perda de calor do secador p/ ambiente (W) (j+1)
Qp(i)=0;
deltaT(i) = ((G*(He-Hs(i)))-Qp(i))/(hp(i)*ae(i)*vl);% Cálculo do delta T (j+1)
Tp(i)= h*(((hp(i)*ae(i)*deltaT(i)*vl)-(cal_lat*mss(1)*d_xp(i))))/(cps*mss(1))+Tp(i-1); % Cálculo da temperatura da partícula (j+1)
Up(i) = h*((G*(Uabs1(i)-Uabs_e))/mss(i-1))+Up(i-1);
Tpc(i) = Tp(i) - 273.15;
Tar_sc(i) = Tar_s(i) - 273.15;
AA(i) = G*(He-Hs(i));
BB(i) = hp(i)*ae(i)*deltaT(i)*vl;
CC(i) = mss(1)*cal_lat*d_xp(i);
DD(i) = hp(i)*ae(i)*vl;
EE(i) = cps*mss(1);
end

 Tpc = Tpc';
 Tar_sc = Tar_sc';
 Uabs = Uabs';
 Up = Up';
 tt = tt';
% 
figure ('name','Temperaturas');
plot (tt,Tpc,'-k',tt, Tar_sc, '--k');
title ('H_{i}= 0,09 m, M.C_{i} = 0,6 e u_{air} = 2,8 m.s^{-1}');
xlabel ('Drying time (s)');
ylabel ('Temperature (°C)');
legend ('Particle temperature','Outlet air temperature','Location','southwest')
legend ('boxoff')

figure ('name','Umidades');
title ('H_{i}= 0,09 m, M.C_{i} = 0,6 e u_{air} = 2,8 m.s^{-1}');
yyaxis left
plot ( tt, Uabs,'-k');
xlabel ('Drying time (s)');
ylabel ('W_{o} (Kg_{water}. Kg_{dry air}^{-1})');
yyaxis right
plot (tt, Up,'--k');
ylabel ('M.C_{(d.b)}');
legend ('Absolute Humidity (Kg_{water}. Kg_{dry air}^{-1})', 'Particle moisture (d.b)','Location','southwest')
legend ('boxoff')
