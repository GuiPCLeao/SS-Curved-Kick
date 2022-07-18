discField

Xally = [-3 + 6*rand(1,1),-4.5 + 9*rand(1,1);...
    -3 + 6*rand(1,1),-4.5 + 9*rand(1,1);...
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


Xtarget = [-3 + 6*rand(1,1);-4.5 + 9*rand(1,1)];
Xini = Xally(:,1);

ballFlag = 2;
allyFlag = 3;
advFlag = 4;
%% Populating the field

numAdv = size(Xadv,2);
numAlly = size(Xally,2);

% Creating ally

XallyDisc = ones(2,round(2*sRadius/tol)*round(2*pi/0.2),numAlly);

for n = 1:1:numAlly
    rank = 1;
    for r = 0:tol/2:sRadius
        for theta = 0:0.2:2*pi
            XallyDisc(:,rank,n) = Xally(:,n)+[r*sin(theta);r*cos(theta)];
            rank = rank+1;
        end
    end
end

% Creating adversary

XadvDisc = ones(2,round(2*sRadius/tol)*round(2*pi/0.2),numAdv);

for n = 1:1:numAdv
    rank = 1;
    for r = 0:tol/2:sRadius
        for theta = 0:0.2:2*pi
            XadvDisc(:,rank,n) = Xadv(:,n)+[r*sin(theta);r*cos(theta)];
            rank = rank+1;
        end
    end
end

zMeshGrid(1,1) = 5;
%% Allies on the field
for nn = 1:numAlly
    for ii = 1:size(XallyDisc,2)
        [row,col] = map2Disc(XallyDisc(:,ii,nn)',xDiscret,yDiscret,Lfield,Hfield);
        zMeshGrid(row,col) = 3;
    end
end

%% Adversaries on the field
for nn = 1:numAdv
    for ii = 1:size(XadvDisc,2)
        [row,col] = map2Disc(XadvDisc(:,ii,nn)',xDiscret,yDiscret,Lfield,Hfield);
        zMeshGrid(row,col) = 4;
    end
end

%% Kicking the ball
zMeshGridAux = zMeshGrid;
rank = 1;
while ~isempty(zMeshGridAux >=5) && rank<10
    zMeshGridAux = zMeshGrid;
    Outputs = netSolution(Xini,Xtarget,xDiscret,yDiscret,Lfield,Hfield,tol,net,rank);
    
    Vchute = double(Outputs(1));
    Wdribbler = double(Outputs(2));
    thetaRot = double(Outputs(3));
    
    Xball = kickerAngSolver(Vchute,Wdribbler,thetaGeneva,Xini,thetaRot,Xtarget);
    
    for ii = 1:size(Xball,2)
        [row,col] = map2Disc(Xball(:,ii),xDiscret,yDiscret,Lfield,Hfield);
        zMeshGridAux(row,col) = zMeshGridAux(row,col)+ballFlag;
    end
    rank = rank+1;
end


%% plotting
field = pcolor(xMeshGrid*Lfield/length(xDiscret),yMeshGrid*Hfield/length(yDiscret),zMeshGrid);

field.EdgeColor = [0 0 0];
field.LineWidth = 1;
axis equal
hold on

plot(Xball(1,:),Xball(2,:),'-r')

xDiscMax = size(xMeshGrid,1) - 1;
yDiscMax = size(yMeshGrid,2) - 1;

a = cos(linspace(0,2*pi));
b = sin(linspace(0,2*pi));
%campo
plot([-0.5 -3 -3 -0.5],[4.5 4.5 -4.5 -4.5],'w','LineWidth',0.5)
hold all
grid on
axis equal
plot([0.5 3 3 0.5],[-4.5 -4.5 4.5 4.5],'w','LineWidth',0.5)

%Area gol 1
plot([-1 -1 1 1],[-4.5 -3.5 -3.5 -4.5],'w','LineWidth',2) %gol
plot([-0.5 0.5],[-4.5 -4.5],'r--')%linha do gol

%Area gol 2
plot([-1 -1 1 1],[4.5 3.5 3.5 4.5],'w','LineWidth',2) %gol
plot([-0.5 0.5],[4.5 4.5],'r--')%linha do gol

%center
plot(0,0,'ro','LineWidth',0.5)
plot(0.5*a,0.5*b,'w')

%gol 1
plot([-0.5 -0.5 0.5 0.5],[-4.5 -5 -5 -4.5],'w','LineWidth',4) %gol

%gol 2
plot([-0.5 -0.5 0.5 0.5],[4.5 5 5 4.5],'w','LineWidth',4) %gol

%big cross
plot([0 0],[4.5 -4.5],'w','LineWidth',0.5)
plot([-3 3],[0 0],'w','LineWidth',0.5)

hold off