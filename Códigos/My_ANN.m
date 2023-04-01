function [MSE, RMSE, R2] = My_ANN (n, ft, tx)

% Para treinos futuros, a tabela embaralhada foi fixada.
D = xlsread('TABELAFIXADA.xlsx');
% Etada de separa��o de entradas e sa�da da rede.
%%% Sele��o das entradas do modelo
ent= D(:,1:4);
%%% Sele��o das sa�das do modelo
saida= D(:,5:7);

% ETAPA DE SEPARA��O DOS DADOS

% Separando dados de treino da entrada. (70%)
enttr=ent(1:126,:);
% Separando dados de valida��o da entrada. (15%)
entval=ent(127:153,:);
% Separando dados de teste da entrada. (15%)
enttest=ent(154:180,:);

% Separando dados de treino da sa�da. (70%)
saidatr=saida(1:126,:);
% Separando dadis de valida��o da sa�da. (15%)
saidaval=saida(127:153,:);
% Separando dadis de teste da sa�da. (15%)
saidatest=saida(154:180,:);

% invertendo a matriz 
entin=ent'; % Todas as entradas do banco de dados
saidain=saida'; % Todas as sa�das do banco de dados

enttrin=enttr'; % Entradas do banco de treinamento
saidatrin=saidatr'; % Sa�da do banco de treinamento

entvalin=entval';% Entradas do banco de valida��o
saidavalin=saidaval';% Sa�da do banco de valida��o

enttestin=enttest';% Entradas do banco de teste
saidatestin=saidatest';% Sa�da do banco de teste

% ETAPA DE NORMALIZA��O DAS VARIAVEIS
[entradan,entradas]=mapminmax(entin);
[saidan,saidas]=mapminmax(saidain);

[entradatrn]=mapminmax('apply',enttrin,entradas);
[saidatrn]=mapminmax('apply',saidatrin,saidas);

[entradavaln]=mapminmax('apply',entvalin,entradas);
[saidavaln]=mapminmax('apply',saidavalin,saidas);

[entradatestn]=mapminmax('apply',enttestin,entradas);
[saidatestn]=mapminmax('apply',saidatestin,saidas);

% Etapa de cria��o da estrutura: Arquitetura, n� de neuronios e algoritmo
% de treinamento
net = feedforwardnet([n],'trainlm');
% DIVIDINDO OS DADOS PARA TREINO,VALIDA��O E TESTE
net.divideFcn = 'divideind';

[trainInd,valInd,testInd] = divideind(180,1:126,127:153,154:180);

net.divideParam.trainInd = 1:126;

net.divideParam.valInd = 127:153;

net.divideParam.testInd = 154:180;

% Par�metro de avalia��o de desenpenho da rede
net.performFcn = 'mse';

% Etapa para criar camadas e definir suas fun��es de transferencias
net.layers{1}, net.layers{2};
%, net.layers{3}
%, net.layers{4}
if (ft == 1)
   net.layers{1}.transferFcn = 'purelin'; %Fun��o linear
end
if (ft == 2)
   net.layers{1}.transferFcn = 'tansig'; %Fun��o tangente hiperb�lica
end
if (ft == 3)
   net.layers{1}.transferFcn = 'logsig'; % Fun��o sigmoide
end
net.layers{2}.transferFcn = 'purelin';
%net.layers{3}.transferFcn = 'tansig'
%net.layers{4}.transferFcn = 'tansig'

% ETAPA DE DEFICI��O DOS PARAMETROS DE TREINAMENTO
net.trainParam.epochs = 3000; % N� m�ximo de "loops" da rede no treinamento
net.trainParam.min_grad = 1e-6; % Valor limite do gradiente a ser atingido
%net.trainParam.mc = 0.632359246225410; % valor do momentum
net.trainParam.max_fail = 10; %N�mero de verifica��o de valida��es
net.trainParam.lr = tx % Taxa de aprendizado
%net.trainParam.time = % Tempo m�ximo em seg. p/ treinamento
%net.trainParam.goal = % Erro desejado



% ETAPA DE DESENVOLVIMENTO DO MODELO (TREINANDO)
[net,tr] = train(net,entradan,saidan);


% Etapa da simula��o TOTAL com 100% dos dados

Y_mod = sim(net,entradan);
% Y_mod_desn=mapminmax('reverse',Y_mod,saidas);
% Y_mod_desn = Y_mod_desn';
MSE_1 = mean(var(Y_mod,1));
MSE = mse(net,saidan,Y_mod);
RMSE = sqrt(MSE);
SSE = sse(net,saidan,Y_mod); % Soma dos quadrados dos erros
erro = abs(saidan-Y_mod); % Erro absoluto
MAE = mae(erro); % Erro absoluto m�dio

y00 = repmat(mean(saidan,3),1,1);
e00 = saidan-y00;
MSE00 = mse(e00);
MSE00 = mean (var(saidan',1));
R2 = 1 - (MSE_1/MSE00); 

end
