clc;
clear;
close all;

%% Definição do problema
MSE = @(n, ft, tx) My_ANN_2(n, ft, tx); % Função mse
nVar = 1;             % Número de variaveis de decisão
VarSize = [1 nVar];   % Tamanho da matriz da variável de decisão
VarMinn = 1;          % Valor mínimo para o número de neurônios
VarMaxn = 9;         % Valor máximo para o número de neurônios
VarMinft = 1;         % Valor mínimo para a função de transferência
VarMaxft = 3;         % Valor máximo para a função de transferência
VarMintx = 0;         % Valor mínimo para a taxa de aprendizagem
VarMaxtx = 1;         % Valor máxima para a taxa de aprendizagem


%% Parâmetros do PSO
MaxIt = 15; % Máximo número de interações
nPop = 25;   % Tamanho da população (Swarm Size)
w = 0.9;       % Coeficiente Inercial
wdmap = 0.99;% Taxa de amortecimento do coeficiente inercial
c1 = 2.6;      % Coeficiente de aceleração pessoal
c2 = 2.6;      % Coeficiente de aceleração global
MaxVelocityn = 0.2*(VarMaxn - VarMinn);
MinVelocityn = -MaxVelocityn;
MaxVelocityft = 0.2*(VarMaxft - VarMinft);
MinVelocityft = -MaxVelocityft;
MaxVelocitytx = 0.2*(VarMaxtx - VarMintx);
MinVelocitytx = -MaxVelocitytx;
%% Seção de inicialização

% O modelo de partículas 
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

% Criação da população
particle = repmat(empty_particle, nPop, 1);

% Inicialização do melhor global
GlobalBest.mse = inf;

% Inicialização dos membros da população
  for i =1:nPop
  % Geração das soluções aleatórias
  particle(i).Positionn = randi([VarMinn VarMaxn], VarSize);
  particle(i).Positionft = randi([VarMinft VarMaxft], VarSize);
  particle(i).Positiontx = unifrnd(VarMintx, VarMaxtx, VarSize);
  
  % Aplicando os limites máximos e mínimos p/ o n° de neurônios
  particle(i).Positionn = max (particle(i).Positionn, VarMinn);
  particle(i).Positionn = min (particle(i).Positionn, VarMaxn);
  
  % Aplicando os limites máximos e mínimos p/ a função de transferência
  particle(i).Positionft = max (particle(i).Positionft, VarMinft);
  particle(i).Positionft = min (particle(i).Positionft, VarMaxft);
  
   % Aplicando os limites máximos e mínimos p/ a função de transferência
  particle(i).Positiontx = max (particle(i).Positiontx, VarMintx);
  particle(i).Positiontx = min (particle(i).Positiontx, VarMaxtx);

  % Velocidade Inicial
  particle(i).Velocityn = zeros (VarSize);
  particle(i).Velocityft = zeros (VarSize);
  particle(i).Velocitytx = zeros (VarSize);
  
  % Update da melhor posição
  particle(i).Best.Positionn = particle(i).Positionn;
  particle(i).Best.Positionft = particle(i).Positionft;
  particle(i).Best.Positiontx = particle(i).Positiontx;
  particle(i).Best.mse = 1000;
  
  % Update o melhor global
    if particle(i).Best.mse < GlobalBest.mse
     GlobalBest = particle(i).Best;
    end
  end  
% Matriz que guarda o melhor valor de mse a cada interação
Bestmse = zeros(nPop,1);
j = zeros (nPop,1);

%% Loop principal do PSO
for it = 1:MaxIt  
   for i =1:nPop

    % OTIMIZAÇÃO DO NUMERO DE NEURÔNIOS
    % Update da velocidade
    particle(i).Velocityn = w*particle(i).Velocityn...
      + c1*rand(VarSize).*(particle(i).Best.Positionn - particle(i).Positionn)...
      + c2*rand(VarSize).*(GlobalBest.Positionn - particle(i).Positionn);
    % Aplicação dos limites de velocidade
    particle(i).Velocityn = max(particle(i).Velocityn, MinVelocityn);
    particle(i).Velocityn = min(particle(i).Velocityn, MaxVelocityn); 
    % Update da posição
    particle(i).Positionn = particle(i).Positionn + round(particle(i).Velocityn);
    % Aplicando os limites máximos e mínimos p/ o momentum
    particle(i).Positionn = max (particle(i).Positionn, VarMinn);
    particle(i).Positionn = min (particle(i).Positionn, VarMaxn);
    
    % OTIMIZAÇÃO DA FUNÇÃO DE TRANSFERÊNCIA
    % Update da velocidade
    particle(i).Velocityft = w*particle(i).Velocityft...
      + c1*rand(VarSize).*(particle(i).Best.Positionft - particle(i).Positionft)...
      + c2*rand(VarSize).*(GlobalBest.Positionft - particle(i).Positionft);
    % Aplicação dos limites de velocidade
    particle(i).Velocityft = max(particle(i).Velocityft, MinVelocityft);
    particle(i).Velocityft = min(particle(i).Velocityft, MaxVelocityft); 
    % Update da posição
    particle(i).Positionft = particle(i).Positionft + round(particle(i).Velocityft);
    % Aplicando os limites máximos e mínimos p/ o momentum
    particle(i).Positionft = max (particle(i).Positionft, VarMinft);
    particle(i).Positionft = min (particle(i).Positionft, VarMaxft);
    
    % OTIMIZAÇÃO DA TAXA DE APRENDIZAGEM
    % Update da velocidade
    particle(i).Velocitytx = w*particle(i).Velocitytx...
      + c1*rand(VarSize).*(particle(i).Best.Positiontx - particle(i).Positiontx)...
      + c2*rand(VarSize).*(GlobalBest.Positiontx - particle(i).Positiontx);
    % Aplicação dos limites de velocidade
    particle(i).Velocitytx = max(particle(i).Velocitytx, MinVelocitytx);
    particle(i).Velocitytx = min(particle(i).Velocitytx, MaxVelocitytx);  
    % Update da posição
    particle(i).Positiontx = particle(i).Positiontx + particle(i).Velocitytx;
    % Aplicando os limites máximos e mínimos p/ a taxa de aprendizado
    particle(i).Positiontx = max (particle(i).Positiontx, VarMintx);
    particle(i).Positiontx = min (particle(i).Positiontx, VarMaxtx);
    
    % Evolução
    particle(i).mse = MSE(particle(i).Positionn, particle(i).Positionft, particle(i).Positiontx);

    % Update da melhor posição
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
    % Vizualização das informações de interações
    disp (['Interação ' num2str(i) ': Melhor mse ='  num2str(Bestmse(i))]);
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

