clear
tic
run('discField')
% hold on
datasize = 300000;
modelfile = '../results/initial_network/model.h5';
net = importKerasNetwork(modelfile);

thetaGeneva = 30*pi/180;

ballFlag = 1;
allyFlag = 2;
advFlag = 3;

mymap = [rgb('green');rgb('red');rgb('blue');rgb('yellow')]; % 0 for field; 2 for ball; 3 for ally; 4 for adversary

dataTab = table('Size',[datasize 29],'VariableTypes',repmat({'double'},1,29),'VariableNames', ...
    {'Ally_1_row','Ally_1_col',...
    'Ally_2_row','Ally_2_col',...
    'Ally_3_row','Ally_3_col',...
    'Ally_4_row','Ally_4_col',...
    'Ally_5_row','Ally_5_col',...
    'Adv_1_row','Adv_1_col',...
    'Adv_2_row','Adv_2_col',...
    'Adv_3_row','Adv_3_col',...
    'Adv_4_row','Adv_4_col',...
    'Adv_5_row','Adv_5_col',...
    'Adv_6_row','Adv_6_col',...
    'Target_row','Target_col',...
    'ini_row','ini_col',...
    'V','W','Theta'});

parfor ii = 1:datasize
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
    zMeshGridAux = zMeshGrid;
    rank = 0;
    hit = false;
    while  rank<=5
        if hit
            break
        end
        zMeshGridAux = zMeshGrid;
        Outputs = netSolution(Xini,Xtarget,xDiscret,yDiscret,Lfield,Hfield,tol,net,rank);

        Vchute = double(Outputs(1));
        Wdribbler = double(Outputs(2));
        thetaRot = double(Outputs(3));

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
        rank = rank+1;
    end

    if rank > 5
        continue
    else
        [~,idxAlly] = sort(Xally(1,:));
        Xally = Xally(:,idxAlly);
        [~,idxAdv] = sort(Xadv(1,:));
        Xadv = Xadv(:,idxAdv);
        fprintf("iteration: " + string(ii) + ", rank: " + string(rank) + newline)
        [row,col] = map2Disc(Xally(:,1),xDiscret,yDiscret,Lfield,Hfield);
        dataTab(ii,:).Ally_1_row=row;
        dataTab(ii,:).Ally_1_col=col;
        [row,col] = map2Disc(Xally(:,2),xDiscret,yDiscret,Lfield,Hfield);
        dataTab(ii,:).Ally_2_row=row;
        dataTab(ii,:).Ally_2_col=col;
        [row,col] = map2Disc(Xally(:,3),xDiscret,yDiscret,Lfield,Hfield);
        dataTab(ii,:).Ally_3_row=row;
        dataTab(ii,:).Ally_3_col=col;
        [row,col] = map2Disc(Xally(:,4),xDiscret,yDiscret,Lfield,Hfield);
        dataTab(ii,:).Ally_4_row=row;
        dataTab(ii,:).Ally_4_col=col;
        [row,col] = map2Disc(Xally(:,5),xDiscret,yDiscret,Lfield,Hfield);
        dataTab(ii,:).Ally_5_row=row;
        dataTab(ii,:).Ally_5_col=col;
        [row,col] = map2Disc(Xadv(:,1),xDiscret,yDiscret,Lfield,Hfield);
        dataTab(ii,:).Adv_1_row=row;
        dataTab(ii,:).Adv_1_col=col;
        [row,col] = map2Disc(Xadv(:,2),xDiscret,yDiscret,Lfield,Hfield);
        dataTab(ii,:).Adv_2_row=row;
        dataTab(ii,:).Adv_2_col=col;
        [row,col] = map2Disc(Xadv(:,3),xDiscret,yDiscret,Lfield,Hfield);
        dataTab(ii,:).Adv_3_row=row;
        dataTab(ii,:).Adv_3_col=col;
        [row,col] = map2Disc(Xadv(:,4),xDiscret,yDiscret,Lfield,Hfield);
        dataTab(ii,:).Adv_4_row=row;
        dataTab(ii,:).Adv_4_col=col;
        [row,col] = map2Disc(Xadv(:,5),xDiscret,yDiscret,Lfield,Hfield);
        dataTab(ii,:).Adv_5_row=row;
        dataTab(ii,:).Adv_5_col=col;
        [row,col] = map2Disc(Xadv(:,6),xDiscret,yDiscret,Lfield,Hfield);
        dataTab(ii,:).Adv_6_row=row;
        dataTab(ii,:).Adv_6_col=col;
        [row,col] = map2Disc(Xini(:),xDiscret,yDiscret,Lfield,Hfield);
        dataTab(ii,:).ini_row=row;
        dataTab(ii,:).ini_col=col;
        [row,col] = map2Disc(Xtarget(:),xDiscret,yDiscret,Lfield,Hfield);
        dataTab(ii,:).Target_row=row;
        dataTab(ii,:).Target_col=col;
        dataTab(ii,:).V=Vchute;
        dataTab(ii,:).W=Wdribbler;
        dataTab(ii,:).Theta=thetaRot;
    end
end
dataTab(dataTab.V == 0,:)=[];
size(dataTab)

save('dataTab_tol05.mat','dataTab')
toc