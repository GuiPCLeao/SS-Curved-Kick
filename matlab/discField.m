%% Parameters


Lfield = 6.0; %m largura do campo da divisão B
Hfield = 9.0; %m Altura do campo da divisão B
sRadius = 0.085;

% Xball = [-1.6 -3.4]';
% 
% Xally = [-1 -2.3; -0.5 2]';
% Xadv = [2 0.5; 1.2 -2]';

ballFlag = 1;
allyFlag = 2;
advFlag = 3;

tol = 0.7746;
% tol = 0.5;
l = sqrt(2)*tol/2;

%% Field creation

xDiscret = ceil(-Lfield/l):1:floor(Lfield/l);
yDiscret = ceil(-Hfield/l)+1:1:floor(Hfield/l)-1;
zDiscret = zeros(length(xDiscret),length(yDiscret));

[xMeshGrid,yMeshGrid] = meshgrid(xDiscret,yDiscret);
zMeshGrid = zDiscret';
mymap = [rgb('green');rgb('red');rgb('blue');rgb('yellow')]; % 1 for field; 2 for ball; 3 for ally; 4 for adversary

%% Populating the field
% 
% numAdv = size(Xadv,2);
% numAlly = size(Xally,2);
% 
% % Creating ally
% 
% XallyDisc = ones(2,round(2*sRadius/tol)*round(2*pi/0.2),numAlly);
% 
% for n = 1:1:numAlly
%     count = 1;
%     for r = 0:tol/2:sRadius
%         for theta = 0:0.2:2*pi
%             XallyDisc(:,count,n) = Xally(:,n)+[r*sin(theta);r*cos(theta)];
%             count = count+1;
%         end
%     end
% end
% 
% % Creating adversary
% 
% XadvDisc = ones(2,round(2*sRadius/tol)*round(2*pi/0.2),numAdv);
% 
% for n = 1:1:numAdv
%     count = 1;
%     for r = 0:tol/2:sRadius
%         for theta = 0:0.2:2*pi
%             XadvDisc(:,count,n) = Xadv(:,n)+[r*sin(theta);r*cos(theta)];
%             count = count+1;
%         end
%     end
% end
% 
% %% Ball on the field
% 
% for ii = 1:size(Xball,2)
%     [row,col] = map2Disc(Xball(:,ii),xDiscret,yDiscret,Lfield,Hfield);
%     zMeshGrid(row,col) = ballFlag;
% end
% % zMeshGrid(1,1) = 5;
% %% Allies on the field
% for nn = 1:numAlly
%     for ii = 1:size(XallyDisc,2)
%         [row,col] = map2Disc(XallyDisc(:,ii,nn)',xDiscret,yDiscret,Lfield,Hfield);
%         zMeshGrid(row,col) = allyFlag;
%     end
% end
% 
% %% Adversaries on the field
% for nn = 1:numAdv
%     for ii = 1:size(XadvDisc,2)
%         [row,col] = map2Disc(XadvDisc(:,ii,nn)',xDiscret,yDiscret,Lfield,Hfield);
%         zMeshGrid(row,col) = advFlag;
%     end
% end


%% Plotting the field
if exist('plotField','var') && plotField
    
    fig = figure;
    hold on
    clim(gca,[0 4])
    colormap(fig,mymap)
    %     zMeshGrid(35,23) = 5;
    %     field = pcolor(xMeshGrid*Lfield/length(xDiscret),yMeshGrid*Hfield/length(yDiscret),zMeshGrid);
    %
    %     field.EdgeColor = [0 0 0];
    %     field.LineWidth = 1;
    im = imagesc(xMeshGrid(1,:)*Lfield/length(xDiscret),yMeshGrid(:,1)*Hfield/length(yDiscret),zMeshGrid);
    
    % cells edges
    edge_x = repmat((xDiscret(1)-0.5:xDiscret(end)+0.5)*Lfield/length(xDiscret), length(yDiscret)+1,1);
    edge_y = repmat((yDiscret(1)-0.5:yDiscret(end)+0.5)*Hfield/length(yDiscret), length(xDiscret)+1,1).';
    plot(edge_x ,edge_y, ' k') % vertical lines
    plot(edge_x.', edge_y.', 'k') % horizontal lines
    axis equal

%     plot(Xball(1,:),Xball(2,:),'*')

    xDiscMax = size(xMeshGrid,1) - 1;
    yDiscMax = size(yMeshGrid,2) - 1;

    a = cos(linspace(0,2*pi));
    b = sin(linspace(0,2*pi));
    %campo
    plot([-0.5 -3 -3 -0.5],[4.5 4.5 -4.5 -4.5],'w','LineWidth',0.5)
    hold all

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
    plot([-0.5 -0.5 0.5 0.5],[-4.5 -5 -5 -4.5],'k','LineWidth',4) %gol

    %gol 2
    plot([-0.5 -0.5 0.5 0.5],[4.5 5 5 4.5],'k','LineWidth',4) %gol

    %big cross
    plot([0 0],[4.5 -4.5],'w','LineWidth',0.5)
    plot([-3 3],[0 0],'w','LineWidth',0.5)

    hold off

end
