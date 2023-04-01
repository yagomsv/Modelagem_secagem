function [Y1des] = ANN (Z1, e1, s1,D)

 B = xlsread('F:\Documentos\Estudos\Mestrado\Dados e modelos\Bancos de dados\Pesos e bias.xlsx', 'modelo 1');

A = xlsread('F:\Documentos\Estudos\Mestrado\Dados e modelos\Bancos de dados\Banco de dados - Marcelo interpolados.xlsx', 'Dados interpolados (9 pts exp)');
D = A(1:180,1:7);

%%% Seleção das entradas do modelo
ent= D(:,1:4);
%%% Seleção das saídas do modelo
saida= D(:,5:7);

 % invertendo a matriz
 entin=ent';
 saidain=saida';

 % ETAPA DE NORMALIZAÇÃO DAS VARIAVEIS
 %mapminmax --> [-1 +1]
 [entradan,entradas]=mapminmax(entin);
 [saidan,saidas]=mapminmax(saidain);

 [ent_exp1]=mapminmax('apply',e1,entradas);
 [saida_exp1]=mapminmax('apply',s1,saidas);

 % Etapa de criação da estrutura: Arquitetura, nº de neuronios e algoritmo
 % de treinamento
 net = feedforwardnet(7);
 net = configure (net,entradan,saidan);
 IW = B (1:28,1);
 IW = reshape (IW,[7,4]);
 LW = B(36:56,1);
 LW = reshape(LW,[7,3]);
 LW = LW';
 b1 = B(29:35,1);
 b2 = B(57:59,1);
 net.IW{1,1}= IW;%
 net.LW{2,1}= LW;%
 net.b{1,1}= b1;%
 net.b{2,1}= b2;%

 % Etapa para criar camadas e definir suas funções de transferencias
 net.layers{1}, net.layers{2};
 net.layers{1}.transferFcn = 'tansig'; % Função tangente hiperbólica [-1 +1]
 net.layers{2}.transferFcn = 'purelin';% Função linear [-1 +1]

 Y1=sim(net,ent_exp1); % Simulação da rede com dados do treinamento
 Y1des= mapminmax('reverse',Y1,saidas); % Desnormalizando as respostas da rede no treinamento

end