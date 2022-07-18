clear all
close all
animation = true;
saveVideo = false;
accelFact = 1;

modelfile = '../results/esse_deu_bom-qual_eh/model.h5';
net = importKerasNetwork(modelfile);
% plot(net)
% title('-- Network Architecture')

thetaGeneva = 30*pi/180; %�ngulo de inclina��o do robo
Xini = [-3 + 6*rand(1,1);-4.5 + 9*rand(1,1)];%[2;1]; %posi��o inicial da bola 4*rand(2,1);%
Xtarget = [-3 + 6*rand(1,1);-4.5 + 9*rand(1,1)];%[4;2]; %posi��o que se deseja atingir com a bola 4*rand(2,1);%
r = 0.043; %m %Raio da bola
tol = 0.6;
%% Sem Rede Neural

% Vchute = 8; %Velocidade inicial do chute
% Wdribbler = 10000*2*pi/60; %rad/s %Velocidade que o dribbler gira a bola;
% thetaRot = 50*pi/180; %�ngulo de inclina��o do robo

%% Rede Neural

% if exist('NetChuteAngulado.mat','file') == 2
%     load NetChuteAngulado
% else
%     if exist('NetChuteAngulado','var') == 0
%         [NetChuteAngulado,Neff,timeGenMatrix,timeTrain,numLayers] = TreinaSNNChuteCurvo();
%     end
% end

% Outputs = net(Inputs), com Outputs = [Vchute, Wdribbler, thetaGeneva] e
% Inputs = [Xobjetivo], com Xobtjetivo = [x_objetivo; y_objetivo]

discField

tic
Outputs = netSolution(Xini,Xtarget,xDiscret,yDiscret,Lfield,Hfield,tol,net,1);
timeInf = toc

Vchute = double(Outputs(1));
Wdribbler = double(Outputs(2));
thetaRot = double(Outputs(3));

%%

X = kickerAngSolver(Vchute,Wdribbler,thetaGeneva,Xini,thetaRot,Xtarget);
X1 = X(1,:);
X2 = X(2,:);

error = min(sqrt((X1-Xtarget(1)).^2+(X2-Xtarget(2)).^2));

% Neff
% timeGenMatrix;
% timeTrain;
% numLayers
error

%% desenhando o ambiente
figure
if animation == true
    for i = 1:round(length(X)/accelFact)%para ver o movimento da bola
        a = cos(linspace(0,2*pi));
        b = sin(linspace(0,2*pi));
        plot(0,0)
        %campo
        plot([-0.5 -3 -3 -0.5],[4.5 4.5 -4.5 -4.5],'k','LineWidth',0.5)
        hold all
        grid on
        axis equal
        plot([0.5 3 3 0.5],[-4.5 -4.5 4.5 4.5],'k','LineWidth',0.5)
        
        %Area gol 1
        plot([-1 -1 1 1],[-4.5 -3.5 -3.5 -4.5],'k','LineWidth',2) %gol
        plot([-0.5 0.5],[-4.5 -4.5],'r--')%linha do gol
        
        %Area gol 2
        plot([-1 -1 1 1],[4.5 3.5 3.5 4.5],'k','LineWidth',2) %gol
        plot([-0.5 0.5],[4.5 4.5],'r--')%linha do gol
        
        %center
        plot(0,0,'ko','LineWidth',0.5)
        plot(0.5*a,0.5*b,'k')

        %gol 1
        plot([-0.5 -0.5 0.5 0.5],[-4.5 -5 -5 -4.5],'k','LineWidth',4) %gol
        
        %gol 2
        plot([-0.5 -0.5 0.5 0.5],[4.5 5 5 4.5],'k','LineWidth',4) %gol
        
        %big cross
        plot([0 0],[4.5 -4.5],'k','LineWidth',0.5)
        plot([-3 3],[0 0],'k','LineWidth',0.5)
        
        %small que chuta
        as = cos(linspace(pi-0.8671,2*pi+0.8671)+thetaRot+2*pi/2);
        bs = sin(linspace(pi-0.8671,2*pi+0.8671)+thetaRot+2*pi/2);
        patch(0.085*as+Xini(1,1),0.085*bs+Xini(2,1)-0.055,'k')
        patch(0.05*a+Xini(1,1),0.05*b+Xini(2,1)-0.055,rgb('blue'));
        
        %         %small goleiro lat
        %         as = cos(linspace(pi-0.8671,2*pi+0.8671));
        %         bs = sin(linspace(pi-0.8671,2*pi+0.8671));
        %         patch(0.085*as+2.5,0.085*bs+0.1,'k')
        %         patch(0.05*a+2.5,0.05*b+0.1,rgb('yellow'));
        %
        %         %small barreira lat 1
        %         as = cos(linspace(pi-0.8671,2*pi+0.8671));
        %         bs = sin(linspace(pi-0.8671,2*pi+0.8671));
        %         patch(0.085*as+2,0.085*bs+0.07,'k')
        %         patch(0.05*a+2,0.05*b+0.07,rgb('yellow'));
        %
        %         %small barreira lat 2
        %         as = cos(linspace(pi-0.8671,2*pi+0.8671));
        %         bs = sin(linspace(pi-0.8671,2*pi+0.8671));
        %         patch(0.085*as+2,0.085*bs+0.24,'k')
        %         patch(0.05*a+2,0.05*b+0.24,rgb('yellow'));
        %
        %         %small barreira lat 3
        %         as = cos(linspace(pi-0.8671,2*pi+0.8671));
        %         bs = sin(linspace(pi-0.8671,2*pi+0.8671));
        %         patch(0.085*as+2,0.085*bs+0.4,'k')
        %         patch(0.05*a+2,0.05*b+0.4,rgb('yellow'));
        
        %         %small goleiro front
        %         as = cos(linspace(pi-0.8671,2*pi+0.8671));
        %         bs = sin(linspace(pi-0.8671,2*pi+0.8671));
        %         patch(0.085*as+3,0.085*bs+0.5,'k')
        %         patch(0.05*a+3,0.05*b+0.5,rgb('yellow'));
        %
        %         %small barreira front 1
        %         as = cos(linspace(pi-0.8671,2*pi+0.8671));
        %         bs = sin(linspace(pi-0.8671,2*pi+0.8671));
        %         patch(0.085*as+3,0.085*bs+1,'k')
        %         patch(0.05*a+3,0.05*b+1,rgb('yellow'));
        %
        %         %small barreira front 2
        %         as = cos(linspace(pi-0.8671,2*pi+0.8671));
        %         bs = sin(linspace(pi-0.8671,2*pi+0.8671));
        %         patch(0.085*as+2.5,0.085*bs+1,'k')
        %         patch(0.05*a+2.5,0.05*b+1,rgb('yellow'));
        %
        %         %small barreira front 3
        %         as = cos(linspace(pi-0.8671,2*pi+0.8671));
        %         bs = sin(linspace(pi-0.8671,2*pi+0.8671));
        %         patch(0.085*as+3.5,0.085*bs+1,'k')
        %         patch(0.05*a+3.5,0.05*b+1,rgb('yellow'));
        
        % ponto que mirou
        plot(Xtarget(1,1)*ones(1,100) + linspace(-0.25,0.25),Xtarget(2,1)*ones(1,100),'--r');
        plot(Xtarget(1,1)*ones(1,100),Xtarget(2,1)*ones(1,100)+ linspace(-0.25,0.25),'--r');
        plot(Xtarget(1,1),Xtarget(2,1),'ob')
        plot(tol*a+Xtarget(1,1),tol*b+Xtarget(2,1),'--r');
        %% gerando anima��o
        %bal movimento+video
        
        plot(X(1,:),X(2,:));
        
        if accelFact*i>length(X(1,:))
            frame = length(X(1,:));
        else
            frame = accelFact*i;
        end
        trajetoria = patch(r*a+X(1,frame),r*b+X(2,frame),rgb('orange'));
        hold off
        %plot(0,0)
        %hold on
        set(gcf, 'units','normalized','outerposition',[0 0 1 1]);
        videoFrame(i) = getframe(gcf);
        pause(0.000000000007)
        
    end
    if saveVideo
        video = VideoWriter('SimulGolOlimpicoTest','Motion JPEG AVI');
        video.FrameRate = 20;
        video.Quality = 100;
        open(video);
        writeVideo(video,videoFrame);
        close(video);
    end
    
end
%end


% plot(X(1,:),X(2,:))
% hold on
%
% %% fitting polinomial da curvahSurface = surf(peaks(20));
%
%
% s = polyfit(X(1,:),X(2,:),4); %interpola��o do resultado
% %plot(X(1,:),polyval(s,X(1,:)))
%
% pos = @(x) s(1)*x.^4+s(2)*x.^3 + s(3)*x.^2 + s(4)*x + s(5);
% %
% % Xf=@(v,theta,x) 3.097*10^-7*v^(-6.00713)*5.734*10^9*theta^(-3.7)*x.^4 + 0.0146*v^(-4.13024)*(0.4197*theta^4-31.46*theta^3-1172*theta^2+1.479*10^5*theta-5.017*10^6)/(theta^2+-6.64*theta+27.79)*x.^3+0.0058*v^(-2.27056)*(-3.629*10^-6*theta^5+0.00133*theta^4-0.2113*theta^3+15.97*theta^2-587*theta+1.058*10^4)/(theta+0.1656)*x.^2+0.0096*v^0.237667*(53.61*theta^(-1.092)-0.3465)*x;
% %
% % figure
% % hold on
% % plot(X(1,:),pos(X(1,:)),'x')
% % plot(X(1,:), Xf(Vchute,theta,X(1,:)),'--')
%

%% Coleta de par�metros da curva
%
% Y = pos(X(1,:));
%
% Ymax = max(Y);
%
% Alc = max(X(1,:));
