clear

tic
tol = 0.6;

numberSimuls = 10000;
countHit = 0;

countNotHit = 0;
meanError = 0;
% countErrorClose = 0;
% countErrorFar = 0;

% closeDist = 2.5;
% farDist = 5;

discField
modelfile = '../results/JINT/obsavd_net.h5';
net = importKerasNetwork(modelfile);

thetaGeneva = 30*pi/180;

ballFlag = 1;
allyFlag = 2;
advFlag = 3;

mymap = [rgb('green');rgb('red');rgb('blue');rgb('yellow')]; % 0 for field; 2 for ball; 3 for ally; 4 for adversary


% wait = waitbar(0,'Starting Validation...');

parfor ii = 1:numberSimuls
    zMeshGrid = 0*zDiscret';


    Xally = [-3 + 6*rand(1,1),-4.5 + 9*rand(1,1);...
        -3 + 6*rand(1,1),-4.5 + 9*rand(1,1);...
        -3 + 6*rand(1,1),-4.5 + 9*rand(1,1);...
        -3 + 6*rand(1,1),-4.5 + 9*rand(1,1);...
        -3 + 6*rand(1,1),-4.5 + 9*rand(1,1)]';

    Xadv = [-3 + 6*rand(1,1),-4.5 + 9*rand(1,1);...
        -3 + 6*rand(1,1),-4.5 + 9*rand(1,1);...
        -3 + 6*rand(1,1),-4.5 + 9*rand(1,1);...
        -3 + 6*rand(1,1),-4.5 + 9*rand(1,1);...
        -3 + 6*rand(1,1),-4.5 + 9*rand(1,1);...
        -3 + 6*rand(1,1),-4.5 + 9*rand(1,1)]';


    Xtarget = Xally(:,2);
    Xini = Xally(:,1);



    Outputs = ObsAvdSolution(Xally,Xadv,Xini,Xtarget,net,xDiscret,yDiscret,Lfield,Hfield);

    Vchute = double(Outputs(1));
    Wdribbler = double(Outputs(2));
    thetaRot = double(Outputs(3));

    %% Populating the field

    numAdv = size(Xadv,2);
    numAlly = size(Xally,2);

    % Creating ally

    XallyDisc = ones(2,round(2*sRadius/tol*2*pi/0.2),numAlly);

    for n = 1:1:numAlly
        count = 1;
        for r = 0:tol/2:sRadius
            for theta = 0:0.2:2*pi
                XallyDisc(:,count,n) = Xally(:,n)+[r*sin(theta);r*cos(theta)];
                count = count+1;
            end
        end
    end

    % Creating adversary

    XadvDisc = ones(2,round(2*sRadius/tol*2*pi/0.2),numAdv);

    for n = 1:1:numAdv
        count = 1;
        for r = 0:tol/2:sRadius
            for theta = 0:0.2:2*pi
                XadvDisc(:,count,n) = Xadv(:,n)+[r*sin(theta);r*cos(theta)];
                count = count+1;
            end
        end
    end


    %% Allies on the field
    for nn = 1:numAlly
        for iii = 1:size(XallyDisc,2)
            [row,col] = map2Disc(XallyDisc(:,iii,nn)',xDiscret,yDiscret,Lfield,Hfield);
            zMeshGrid(row,col) = allyFlag;
        end
    end

    %% Adversaries on the field
    for nn = 1:numAdv
        for iii = 1:size(XadvDisc,2)
            [row,col] = map2Disc(XadvDisc(:,iii,nn)',xDiscret,yDiscret,Lfield,Hfield);
            zMeshGrid(row,col) = advFlag;
        end
    end

    %% Kicking the ball
    hit = false;

    zMeshGridAux = zMeshGrid;


    Xball = kickerAngSolver(Vchute,Wdribbler,thetaGeneva,Xini,thetaRot,Xtarget);

    for iii = 1:size(Xball,2)
        [row,col] = map2Disc(Xball(:,iii),xDiscret,yDiscret,Lfield,Hfield);
        %         if zMeshGridAux(row,col) < advFlag+ballFlag && zMeshGridAux(row,col) ~= ballFlag && zMeshGridAux(row,col) ~= allyFlag
        %             zMeshGridAux(row,col) = zMeshGridAux(row,col)+ballFlag;
        %         end
        if sqrt((Xball(1,iii)-Xtarget(1)).^2+(Xball(2,iii)-Xtarget(2)).^2) < tol && isempty(find(zMeshGridAux >= advFlag+ballFlag,1))
            hit = true;
            break
        end
    end

%%

% waitbar(ii/numberSimuls,wait,strcat('Case number:',num2str(ii),' of ',num2str(numberSimuls)));

if hit
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

end

% close(wait)
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
