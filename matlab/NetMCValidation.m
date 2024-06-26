clear all

tic
tol = 0.5;

numberSimuls = 10000;
countHit = 0;

countNotHit = 0;
meanError = 0;
% countErrorClose = 0;
% countErrorFar = 0;

% closeDist = 2.5;
% farDist = 5;

thetaGeneva = 30*pi/180; %Ângulo de inclinação do robo

discField
modelfile = '../results/initial_network/model.h5';
net = importKerasNetwork(modelfile);


wait = waitbar(0,'Starting Validation...');
ii = 1;
while ii <numberSimuls
    Xini = [-3 + 6*rand(1,1);-4.5 + 9*rand(1,1)];%[2;1]; %posição inicial da bola 4*rand(2,1);%

    Xtarget = [-3 + 6*rand(1,1);-4.5 + 9*rand(1,1)];
    Vtarget = 0.5 + (8-0.5)*rand(1,1);
    Wtarget = 0 + (12000*2*pi/60 - 0)*rand(1,1);
    thetatarget = 0 + (360*pi/180 - 0)*rand(1,1);

    % while min(sqrt((Xini-Xtarget(1)).^2+(Xini-Xtarget(2)).^2))>4
    %     Xtarget = [-3 + 6*rand(1,1);-4.5 + 9*rand(1,1)];
    % end

    X = kickerAngSolver(Vtarget,Wtarget,deg2rad(30),Xini,thetatarget,Xtarget);
    X(:,abs(X(1,:)) > 3) = [];
    X(:,abs(X(2,:)) > 4.5) = [];
    
    if size(X,2)>2
        Xini = X(:,1);
        Xtarget = X(:,randi([3,size(X,2)]));

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
        ii = ii +1;
    end
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
