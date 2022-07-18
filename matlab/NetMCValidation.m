clear all

tic
tol = 0.6;

numberSimuls = 200;
countHit = 0;

countNotHit = 0;
meanError = 0;
% countErrorClose = 0;
% countErrorFar = 0;

% closeDist = 2.5;
% farDist = 5;

thetaGeneva = 30*pi/180; %Ângulo de inclinação do robo

discField
modelfile = '../results/model.h5';
net = importKerasNetwork(modelfile);


wait = waitbar(0,'Starting Validation...');

for ii = 1:1:numberSimuls
    Xini = [-3 + 6*rand(1,1);-4.5 + 9*rand(1,1)];%[2;1]; %posição inicial da bola 4*rand(2,1);%
    
    Xtarget = [-3 + 6*rand(1,1);-4.5 + 9*rand(1,1)];
    
    while min(sqrt((Xini-Xtarget(1)).^2+(Xini-Xtarget(2)).^2))>4
        Xtarget = [-3 + 6*rand(1,1);-4.5 + 9*rand(1,1)];
    end

    
    Outputs = netSolution(Xini,Xtarget,xDiscret,yDiscret,Lfield,Hfield,tol,net,1);
    
    Vchute = double(Outputs(1));
    Wdribbler = double(Outputs(2));
    thetaRot = double(Outputs(3));
    
    X = kickerAngSolver(Vchute,Wdribbler,thetaGeneva,Xini,thetaRot,Xtarget);
    X1 = X(1,:);
    X2 = X(2,:);
    
    error = min(sqrt((X1-Xtarget(1)).^2+(X2-Xtarget(2)).^2));
    
    waitbar(ii/numberSimuls,wait,strcat('Case number:',num2str(ii),' of ',num2str(numberSimuls)));
    
    if error <= tol
        countHit = countHit+1;
    else
        countNotHit = countNotHit+1;
%         if min(sqrt((Xini(1)-Xtarget(1)).^2+(Xini(2)-Xtarget(2)).^2)) < closeDist
%             countErrorClose = countErrorClose+1;
%             
%         else
%             if min(sqrt((Xini(1)-Xtarget(1)).^2+(Xini(2)-Xtarget(2)).^2)) > farDist
%                 countErrorFar = countErrorFar+1;
%             end
%         end
    end
    meanError = meanError+error;
end

close(wait)
meanError = meanError/numberSimuls;
totalTima = toc;

figure
pieTotalError = [round(countHit/numberSimuls,2) 1-round(countHit/numberSimuls,2)];
labelsTotalError = {'Target Hit', 'Target Not Hit'};
p1 = pie(pieTotalError);
legend(labelsTotalError);
% 
% figure
% pieError = [countErrorClose/countNotHit (countNotHit-(countErrorClose))/countNotHit];
% labelsError = {'Target too close', 'Other cases'};
% p2 = pie(pieError);
% legend(labelsError);
