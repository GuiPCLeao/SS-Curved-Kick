function trajetoria = kickerAngSolver(Vchute,Wdribbler,thetaGeneva,Xini,thetaRot,Xobjective)


%% Definição de parametros gerais

m = 0.046; %kg %Massa da bola
g = 9.81; %m/s² %Gravidade
r = 0.043; %m %Raio da bola
%Vchute = 6.08; % m/s %Velocidade de chute da bola; usar para definur a parábola
%Wdribbler = 1000*2*pi/60; %rad/s %Velocidade que o dribbler gira a bola;
%theta = 58.1*(pi/180); %Angulo do chute, equivale ao angulo da engrenagem + angulação do robo no chute; angulos da engrenagem: theta e theta/2
I = (1/0.5805-1)*m*r^2; %Momento de inercia da bola, correção com artigo robocup
%bizu: Vchute = 6.16 e theta = 58.1°
Lfield = 6.0; %m largura do campo da divisão B
Hfield = 9.0; %m Altura do campo da divisão B
cutTraj = true;

%% Definição de parâmetros para iteração

TempoTot = 5; %s %Tempo total do movimento da bola
% tspan = [0 TempoTot];
tspan = 0:0.01:TempoTot;

%% Definição das condições iniciais
Xini0 = [0,0]';
VcomIni = Vchute.*[cos(pi/2-thetaGeneva-thetaRot); sin(pi/2-thetaGeneva-thetaRot)]; %%bola sai com a velocidade que foi chutada
WIni = Wdribbler.*[cos(pi/2-thetaRot); sin(pi/2-thetaRot)]; %Rotação inicial da bola é em apenas 1 eixo, igual a rotação do dribbler

% TempoInici = 0; %s %Tempo inicial

%% Processo iterativo

[t,sol] = ode45(@(t,var) ballEquation(t,var,I,r,m,g,VcomIni),tspan,[Xini0(1) Xini0(2) VcomIni(1) VcomIni(2) WIni(1) WIni(2)]);

X = [sol(:,1) sol(:,2)]';
Vel = [sol(:,3) sol(:,4)]';



% for k = 1:K-1 
%     
%     
%     
%     if sqrt(Vcom(1,k)^2+Vcom(2,k)^2)>0.5805*sqrt(Vcom(1,1)^2+Vcom(2,1)^2)
%         CoefAtrit(1,k) = 10/g; %Retirado do artigo da robocup
%         Fat(:,k) = -(CoefAtrit(1,k)*m*g/sqrt((Vcom(1,k))^2+(Vcom(2,k))^2)).*[Vcom(1,k); Vcom(2,k)];
%         acom(:,k) = Fat(:,k)/m;
%         
%         %agora determinar Vk+1,Wk+1 e Xk+1 para proxima iteração
%         
%         Vcom(:,k+1) = Vcom(:,k) + acom(:,k)*deltaT; %verdade para intervalo de tempo pequeno tendendo a 0
%         W(:,k+1) = W(:,k) -(5/(2*r))*(Vcom(:,k+1)-Vcom(:,k)); %Retirado do artigo da robocup
%         X(:,k+1) = X(:,k) + Vcom(:,k).*deltaT+acom(:,k).*deltaT^2/2;
%         Tempo(1,k+1) = Tempo(1,k)+deltaT;
%         
%     else
%         CoefAtrit(1,k) = 10/g; %Retirado do artigo da robocup
%         
%         Vpc(:,k) = Vcom(:,k)-r*[-W(2,k); W(1,k)]; %esse vetor com W equivale a W vetorial versor k da direção Z
%         Fat(:,k) = -(CoefAtrit(1,k)*m*g/(sqrt((Vcom(1,k)+r*W(2,k))^2+(Vcom(2,k)-r*W(1,k))^2))).*[Vcom(1,k)+r*W(2,k); Vcom(2,k) - r*W(1,k)];
%         
%         acom(:,k) = Fat(:,k)/m;
%         T(:,k) = r.*[-Fat(2,k); Fat(1,k)];
%         
%         %agora determinar Vk+1,Wk+1 e Xk+1 para proxima iteração
%         
%         Vcom(:,k+1) = Vcom(:,k) - acom(:,k)*deltaT; %verdade para intervalo de tempo pequeno tendendo a 0
%         W(:,k+1) = W(:,k) + (1/I)*T(:,k)*deltaT;
%         X(:,k+1) = X(:,k) + Vcom(:,k).*deltaT+acom(:,k).*deltaT^2/2;
%         Tempo(1,k+1) = Tempo(1,k)+deltaT;
%     end
%     
%     
%         if X(2,k+1) < -1 %|| (X(1,k+1) > 4 
%             break
%         end
% end
% 
%% Rotacionando o Robo

%rotação
M =@(thet) [cos(thet) sin(thet); -sin(thet) cos(thet)];

for i = 1:length(X)
    X(:,i) = M(thetaRot)*X(:,i);
end

%% reposicionando a curva

x0 = Xini;

if (Xobjective(1,1)-x0(1,1) < 0 && Xobjective(2,1)-x0(2,1) > 0) || (Xobjective(1,1)-x0(1,1) < 0 && Xobjective(2,1)-x0(2,1) < 0)
    
    thet = atan((Xobjective(2,1) - x0(2,1))/(Xobjective(1,1) - x0(1,1)));
    thet = thet + pi;
    
else
    
    thet = atan((Xobjective(2,1) - x0(2,1))/(Xobjective(1,1) - x0(1,1)));
    
end


%translação
posTranslat =@(x) [x(1,:) + x0(1,:);x(2,:) + x0(2,:)]; 



for i = 1:length(X)
    X(:,i) = M(-thet)*X(:,i);
    X(:,i) = posTranslat(X(:,i));
end

% Cutting the ball movement outside the field
if cutTraj
    if ~isempty(find(abs(X(1,:)) > Lfield/2,1)) || ~isempty(find(abs(X(2,:)) > Hfield/2,1))
        cutXpos = find(X(1,:)>Lfield/2,1);
        cutXneg = find(X(1,:)<-Lfield/2,1);
        cutYpos = find(X(2,:)>Hfield/2,1);
        cutYneg = find(X(2,:)<-Hfield/2,1);
        
        if isempty(cutXneg)
            cutXneg = length(X(1,:));
        end
        if isempty(cutYneg)
            cutYneg = length(X(2,:));
        end
        
        if isempty(cutXpos)
            cutXpos = length(X(1,:));
        end
        if isempty(cutYpos)
            cutYpos = length(X(2,:));
        end
        
        if ~isempty(find(sqrt(Vel(1).^2+Vel(2).^2)<0.02,1))
            
            cutXpos = find(sqrt(Vel(1)^2+Vel(2)^2)<0.02,1);
            cutYpos = find(sqrt(Vel(1)^2+Vel(2)^2)<0.02,1);
        end
        
        X = X(:,1:min([cutXneg,cutYneg,cutXpos,cutYpos]));
    end
end
trajetoria = X;
% plot(X(1,:),X(2,:))
% hold on
% plot(t,sqrt(sol(:,3).^2 + sol(:,4).^2))
end
