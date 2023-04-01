function [MSE MSE2] = My_ANN_2 (n, ft, tx)
%Montagem do banco de dados
A = xlsread('TABELAFIXADA2.xlsx');
T = xlsread('F:\Documentos\Estudos\Mestrado\Dados e modelos\Bancos de dados\Banco de dados - Marcelo interpolados.xlsx', 'Dados interpolados (3 pts exp)2');
D = xlsread('F:\Documentos\Estudos\Mestrado\Dados e modelos\Bancos de dados\Pesos e bias.xlsx', 'modelo 2');
v_do_ar = A(:,2);
regime = A(:,5);
Lit = A(:,3);
Ar = A(:,4);
b_d2 = [Lit Ar v_do_ar regime];
Lit2 = T(:,3);
Ar2 = T(:,4);
v_do_ar2 = T(:,2);
regime2 = T(:,5);
b_d = [Lit2 Ar2 v_do_ar2 regime2];

%%% ENTRADAS DO MODELO
CC01_2= b_d2(:,1:3);
%%% SAIDAS DO MODELO
CC02_2= b_d2(:,4);
%%% FIXANDO TABELA
CC03_2= [CC01_2,CC02_2];

% Para treinos futuros, a tabela embaralhada foi fixada.
E = CC03_2;
% Etada de separação de entradas e saída da rede.
%%% Seleção das entradas do modelo
ent= E(:,1:3);
%%% Seleção das saídas do modelo
r_f_rand = E (:,4);
saida= E(:,4);
R = 1:numel(saida');
B = zeros(numel(saida'),max(saida'));
B(sub2ind(size(B),R,saida'))=1;
saida = B;

% ETAPA DE SEPARAÇÃO DOS DADOS

% Separando dados de treino da entrada. (70%)
enttr=ent(1:126,:);
% Separando dados de validação da entrada. (15%)
entval=ent(127:153,:);
% Separando dados de teste da entrada. (15%)
enttest=ent(154:180,:);

% Separando dados de treino da saída. (70%)
saidatr=saida(1:126,:);
% Separando dadis de validação da saída. (15%)
saidaval=saida(127:153,:);
% Separando dadis de teste da saída. (15%)
saidatest=saida(154:180,:);

% invertendo a matriz 
entin=ent';
saidain=saida';

enttrin=enttr';
saidatrin=saidatr';

entvalin=entval';
saidavalin=saidaval';

enttestin=enttest';
saidatestin=saidatest';

% ETAPA DE NORMALIZAÇÃO DAS VARIAVEIS
[entradan,entradas]=mapminmax(entin);
[saidan,saidas]=mapminmax(saidain);

[entradatrn]=mapminmax('apply',enttrin,entradas);
[saidatrn]=mapminmax('apply',saidatrin,saidas);

[entradavaln]=mapminmax('apply',entvalin,entradas);
[saidavaln]=mapminmax('apply',saidavalin,saidas);

[entradatestn]=mapminmax('apply',enttestin,entradas);
[saidatestn]=mapminmax('apply',saidatestin,saidas);

p.outputs{2}.processParams{1}.max_range = 0; % params for remove constant rows
p.outputs{2}.processParams{2}.ymin = 0; % Params for mapminmax
p.outputs{2}.processParams{2}.ymax = 1; % Params for mapminmax
% Etapa de criação da estrutura: Arquitetura, nº de neuronios e algoritmo
% de treinamento
net2 = patternnet([n],'trainlm');

% DIVIDINDO OS DADOS PARA TREINO,VALIDAÇÃO E TESTE
net2.divideFcn = 'divideind';

[trainInd,valInd,testInd] = divideind(180,1:126,127:153,154:180);

net2.divideParam.trainInd = 1:126;

net2.divideParam.valInd = 127:153;

net2.divideParam.testInd = 154:180;

% Etapa para criar camadas e definir suas funções de transferencias
net2.layers{1}, net2.layers{2};
if (ft == 1)
 net2.layers{1}.transferFcn = 'purelin'; %Função linear
end
if (ft == 2)
   net2.layers{1}.transferFcn = 'tansig'; %Função tangente hiperbólica
end
if (ft == 3)
   net2.layers{1}.transferFcn = 'logsig'; % Função sigmoide
end
net2.layers{2}.transferFcn = 'softmax';


% ETAPA DE DEFICIÇÃO DOS PARAMETROS DE TREINAMENTO
net2.trainParam.epochs = 3000; % N° máximo de "loops" da rede no treinamento
net2.trainParam.min_grad = 1e-6; % Valor limite do gradiente a ser atingido
net2.trainParam.max_fail = 10; %Número de verificação de validações
net2.trainParam.lr = tx; % Taxa de aprendizado


% ETAPA DE DESENVOLVIMENTO DO MODELO (TREINANDO)
[net2,tr] = train(net2,entradan,saidan);
y = net2(entradan);
perf = perform(net2,saidan,y);
class_reg = vec2ind(y); % Classificação do regime para todo o banco randomizado, comparar valore com a variável "r_f_rand"
class_reg = class_reg';


%% SIMULAÇAO DO REGIME DE FLUXO
Y1=sim(net2,entradatrn); % Simulação da rede com dados do treinamento
MSE = mse(net2,saidatrn,Y1); % Erro quadrático médio
RMSE = sqrt(MSE); % Raiz do erro quadrático médio
SSE = sse(net2,saidatrn,Y1); % Soma dos quadrados dos erros
error = abs(saidatrn-Y1); % Erro absoluto
MAE = mae(error); % Média do erro absoluto


inpute1=b_d(:,1:3);
targete1 =b_d(:,4);
tempo1=T(:,1);
rf7=targete1(1:60);
rf8=targete1(61:120);
rf10=targete1(121:180);
inpute1in=inpute1';
[pne4]=mapminmax('apply',inpute1in,entradas);
targete1in=targete1';
z = sim(net2,pne4);
z= mapminmax('reverse',z,saidas);
[class,n] = vec2ind(z);
class2 = full(ind2vec(class,n));
class = class'; % Classificação do regime de fluxo em ordem de cada experimento, comprara valores com "targete1"

rf_mod7=class(1:60);
rf_mod8=class(61:120);
rf_mod10=class(121:180);
t = tempo1(1:60);

acerto = 0;
acerto1 = 0;
n1= 0;
acerto2 = 0;
n2= 0;
acerto3 = 0;
n3= 0;
acerto4 = 0;
n4= 0;

for i=1:180
 a = regime2(i) - class(i);
 
 if (a==0)
  acerto = acerto +1;
 end
 
 if (regime2(i) == 1)
  n1 = n1+1;
  a1 = regime2(i) - class(i);
  if (a1 == 0)
   acerto1 = acerto1 + 1;
  end
 end
 
  if (regime2(i) == 2)
   n2 = n2+1;
   a2 = regime2(i) - class(i);
   if (a2 == 0)
    acerto2 = acerto2 + 1;
   end
  end
 
 if (regime2(i) == 3)
  n3 = n3+1;
  a3 = regime2(i) - class(i);
  if (a3 == 0)
   acerto3 = acerto3 +1;
  end
 end

 if (regime2(i) == 4)
  n4 = n4+1;
  a4 = regime2(i) - class(i);
  if (a4 == 0)
   acerto4 = acerto4 +1;
  end
 end
 
 porc_acerto_1 = (acerto1/n1)*100;
 porc_acerto_2 = (acerto2/n2)*100;
 porc_acerto_3 = (acerto3/n3)*100;
 porc_acerto_4 = (acerto4/n4)*100;
 MSE2 = (acerto/180)*100;
end



end
