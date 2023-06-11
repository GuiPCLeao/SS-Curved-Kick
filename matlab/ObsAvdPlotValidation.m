clear
run('discField')
hold on

modelfile = '../results/JINT/obsavd_net.h5';
net = importKerasNetwork(modelfile);

thetaGeneva = 30*pi/180;

ballFlag = 1;
allyFlag = 2;
advFlag = 3;

mymap = [rgb('green');rgb('red');rgb('blue');rgb('yellow')]; % 0 for field; 2 for ball; 3 for ally; 4 for adversary

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

%% plotting

% colormap(mymap)
% field = pcolor(xMeshGrid*Lfield/length(xDiscret),yMeshGrid*Hfield/length(yDiscret),zMeshGrid);
% 
% field.EdgeColor = [0 0 0];
% field.LineWidth = 1;

%     zMeshGrid(35,23) = 5;
%     field = pcolor(xMeshGrid*Lfield/length(xDiscret),yMeshGrid*Hfield/length(yDiscret),zMeshGrid);
%
%     field.EdgeColor = [0 0 0];
%     field.LineWidth = 1;


im.CData = zMeshGrid;

plot(Xball(1,:),Xball(2,:),'Color',rgb('purple'), 'LineWidth', 2)

plot(Xini(1,:),Xini(2,:),'*','Color',rgb('purple'))
plot(Xtarget(1,:),Xtarget(2,:),'*k')

a = cos(linspace(0,2*pi));
b = sin(linspace(0,2*pi));

plot(Xtarget(1,1)*ones(1,100) + linspace(-0.75,0.75),Xtarget(2,1)*ones(1,100),'--','Color','r','LineWidth',2);
plot(Xtarget(1,1)*ones(1,100),Xtarget(2,1)*ones(1,100)+ linspace(-0.75,0.75),'--','Color','r','LineWidth',2);
plot(Xtarget(1,1),Xtarget(2,1),'xr','LineWidth',3)
plot(tol*a+Xtarget(1,1),tol*b+Xtarget(2,1),'--','Color','k','LineWidth',1.5);
% print -depsc2 out.eps
% print -dpng -r400 out.png

xDiscMax = size(xMeshGrid,1) - 1;
yDiscMax = size(yMeshGrid,2) - 1;


% %campo
% plot([-0.5 -3 -3 -0.5],[4.5 4.5 -4.5 -4.5],'w','LineWidth',0.5)
% hold all
% grid on
% axis equal
% plot([0.5 3 3 0.5],[-4.5 -4.5 4.5 4.5],'w','LineWidth',0.5)
% 
% %Area gol 1
% plot([-1 -1 1 1],[-4.5 -3.5 -3.5 -4.5],'w','LineWidth',2) %gol
% plot([-0.5 0.5],[-4.5 -4.5],'r--')%linha do gol
% 
% %Area gol 2
% plot([-1 -1 1 1],[4.5 3.5 3.5 4.5],'w','LineWidth',2) %gol
% plot([-0.5 0.5],[4.5 4.5],'r--')%linha do gol
% 
% %center
% plot(0,0,'ro','LineWidth',0.5)
% plot(0.5*a,0.5*b,'w')
% 
% % %gol 1
% % plot([-0.5 -0.5 0.5 0.5],[-4.5 -5 -5 -4.5],'k','LineWidth',4) %gol
% % 
% % %gol 2
% % plot([-0.5 -0.5 0.5 0.5],[4.5 5 5 4.5],'k','LineWidth',4) %gol
% 
% %big cross
% plot([0 0],[4.5 -4.5],'w','LineWidth',0.5)
% plot([-3 3],[0 0],'w','LineWidth',0.5)

hold off