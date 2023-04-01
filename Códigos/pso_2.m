clc;
clear;
close all;

%% Defini��o do problema
MSE = @(n, ft, tx) My_ANN_2(n, ft, tx); % Fun��o mse
nVar = 1;             % N�mero de variaveis de decis�o
VarSize = [1 nVar];   % Tamanho da matriz da vari�vel de decis�o
VarMinn = 1;          % Valor m�nimo para o n�mero de neur�nios
VarMaxn = 9;         % Valor m�ximo para o n�mero de neur�nios
VarMinft = 1;         % Valor m�nimo para a fun��o de transfer�ncia
VarMaxft = 3;         % Valor m�ximo para a fun��o de transfer�ncia
VarMintx = 0;         % Valor m�nimo para a taxa de aprendizagem
VarMaxtx = 1;         % Valor m�xima para a taxa de aprendizagem


%% Par�metros do PSO
MaxIt = 15; % M�ximo n�mero de intera��es
nPop = 25;   % Tamanho da popula��o (Swarm Size)
w = 0.9;       % Coeficiente Inercial
wdmap = 0.99;% Taxa de amortecimento do coeficiente inercial
c1 = 2.6;      % Coeficiente de acelera��o pessoal
c2 = 2.6;      % Coeficiente de acelera��o global
MaxVelocityn = 0.2*(VarMaxn - VarMinn);
MinVelocityn = -MaxVelocityn;
MaxVelocityft = 0.2*(VarMaxft - VarMinft);
MinVelocityft = -MaxVelocityft;
MaxVelocitytx = 0.2*(VarMaxtx - VarMintx);
MinVelocitytx = -MaxVelocitytx;
%% Se��o de inicializa��o

% O modelo de part�culas 
empty_particle.Positionn = [];
empty_particle.Positionft = [];
empty_particle.Positiontx = [];
empty_particle.Velocityn = [];
empty_particle.Velocityft = [];
empty_particle.Velocitytx = [];
empty_particle.mse = [];
empty_particle.rmse = [];
empty_particle.R2 = [];
empty_particle.Best.Position = [];
empty_particle.Best.mse = [];
empty_particle.Best.rmse = [];
empty_particle.Best.R2 = [];

% Cria��o da popula��o
particle = repmat(empty_particle, nPop, 1);

% Inicializa��o do melhor global
GlobalBest.mse = inf;

% Inicializa��o dos membros da popula��o
  for i =1:nPop
  % Gera��o das solu��es aleat�rias
  particle(i).Positionn = randi([VarMinn VarMaxn], VarSize);
  particle(i).Positionft = randi([VarMinft VarMaxft], VarSize);
  particle(i).Positiontx = unifrnd(VarMintx, VarMaxtx, VarSize);
  
  % Aplicando os limites m�ximos e m�nimos p/ o n� de neur�nios
  particle(i).Positionn = max (particle(i).Positionn, VarMinn);
  particle(i).Positionn = min (particle(i).Positionn, VarMaxn);
  
  % Aplicando os limites m�ximos e m�nimos p/ a fun��o de transfer�ncia
  particle(i).Positionft = max (particle(i).Positionft, VarMinft);
  particle(i).Positionft = min (particle(i).Positionft, VarMaxft);
  
   % Aplicando os limites m�ximos e m�nimos p/ a fun��o de transfer�ncia
  particle(i).Positiontx = max (particle(i).Positiontx, VarMintx);
  particle(i).Positiontx = min (particle(i).Positiontx, VarMaxtx);

  % Velocidade Inicial
  particle(i).Velocityn = zeros (VarSize);
  particle(i).Velocityft = zeros (VarSize);
  particle(i).Velocitytx = zeros (VarSize);
  
  % Update da melhor posi��o
  particle(i).Best.Positionn = particle(i).Positionn;
  particle(i).Best.Positionft = particle(i).Positionft;
  particle(i).Best.Positiontx = particle(i).Positiontx;
  particle(i).Best.mse = 1000;
  
  % Update o melhor global
    if particle(i).Best.mse < GlobalBest.mse
     GlobalBest = particle(i).Best;
    end
  end  
% Matriz que guarda o melhor valor de mse a cada intera��o
Bestmse = zeros(nPop,1);
j = zeros (nPop,1);

%% Loop principal do PSO
for it = 1:MaxIt  
   for i =1:nPop

    % OTIMIZA��O DO NUMERO DE NEUR�NIOS
    % Update da velocidade
    particle(i).Velocityn = w*particle(i).Velocityn...
      + c1*rand(VarSize).*(particle(i).Best.Positionn - particle(i).Positionn)...
      + c2*rand(VarSize).*(GlobalBest.Positionn - particle(i).Positionn);
    % Aplica��o dos limites de velocidade
    particle(i).Velocityn = max(particle(i).Velocityn, MinVelocityn);
    particle(i).Velocityn = min(particle(i).Velocityn, MaxVelocityn); 
    % Update da posi��o
    particle(i).Positionn = particle(i).Positionn + round(particle(i).Velocityn);
    % Aplicando os limites m�ximos e m�nimos p/ o momentum
    particle(i).Positionn = max (particle(i).Positionn, VarMinn);
    particle(i).Positionn = min (particle(i).Positionn, VarMaxn);
    
    % OTIMIZA��O DA FUN��O DE TRANSFER�NCIA
    % Update da velocidade
    particle(i).Velocityft = w*particle(i).Velocityft...
      + c1*rand(VarSize).*(particle(i).Best.Positionft - particle(i).Positionft)...
      + c2*rand(VarSize).*(GlobalBest.Positionft - particle(i).Positionft);
    % Aplica��o dos limites de velocidade
    particle(i).Velocityft = max(particle(i).Velocityft, MinVelocityft);
    particle(i).Velocityft = min(particle(i).Velocityft, MaxVelocityft); 
    % Update da posi��o
    particle(i).Positionft = particle(i).Positionft + round(particle(i).Velocityft);
    % Aplicando os limites m�ximos e m�nimos p/ o momentum
    particle(i).Positionft = max (particle(i).Positionft, VarMinft);
    particle(i).Positionft = min (particle(i).Positionft, VarMaxft);
    
    % OTIMIZA��O DA TAXA DE APRENDIZAGEM
    % Update da velocidade
    particle(i).Velocitytx = w*particle(i).Velocitytx...
      + c1*rand(VarSize).*(particle(i).Best.Positiontx - particle(i).Positiontx)...
      + c2*rand(VarSize).*(GlobalBest.Positiontx - particle(i).Positiontx);
    % Aplica��o dos limites de velocidade
    particle(i).Velocitytx = max(particle(i).Velocitytx, MinVelocitytx);
    particle(i).Velocitytx = min(particle(i).Velocitytx, MaxVelocitytx);  
    % Update da posi��o
    particle(i).Positiontx = particle(i).Positiontx + particle(i).Velocitytx;
    % Aplicando os limites m�ximos e m�nimos p/ a taxa de aprendizado
    particle(i).Positiontx = max (particle(i).Positiontx, VarMintx);
    particle(i).Positiontx = min (particle(i).Positiontx, VarMaxtx);
    
    % Evolu��o
    particle(i).mse = MSE(particle(i).Positionn, particle(i).Positionft, particle(i).Positiontx);

    % Update da melhor posi��o
    if particle(i).mse < particle(i).Best.mse
       particle(i).Best.Positionn = particle(i).Positionn;
       particle(i).Best.Positionft = particle(i).Positionft;
       particle(i).Best.Positiontx = particle(i).Positiontx;
       particle(i).Best.mse = particle(i).mse;

      % Update o melhor global
      if particle(i).Best.mse < GlobalBest.mse
        GlobalBest = particle(i).Best;
      end
    end
              
    % Armazenar o melhor valor de mse
    Bestmse(i) = GlobalBest.mse;
    mse1(i) = particle(i).mse; 
    n1(i) = particle(i).Positionn;
    mc1(i) = particle(i).Positionft;
    tx1(i) = particle(i).Positiontx;
    % Vizualiza��o das informa��es de intera��es
    disp (['Intera��o ' num2str(i) ': Melhor mse ='  num2str(Bestmse(i))]);
    % Amortecimento do coeficiente inercial
    w = w*wdmap;
    j = j+1;
    % Plotting the swarm
    %clf    
    %plot(particle.Positionn, particle.Positionn,'x')   % drawing swarm movements
    %axis([-2 25 -2 25])
    %pause(.1) 
   end

end
%% Resultados

