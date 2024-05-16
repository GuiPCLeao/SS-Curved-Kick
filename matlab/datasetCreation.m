discField
%% Params for iteration

% if exist('TreinaPosicGeneva.mat','file') ~= 2
    % Prepara a matriz
    
    %Posição
    Xini = [0;0];
    Xtarg = [0;4.5];
    
    
    %Número de casos testes de Vchute
    
    Vchute0 = 0.5;
    VchuteF = 8;
    VchutePasso = 0.3;
    VchuteCasos = round((VchuteF - Vchute0)/VchutePasso)+1;
    
    %Número de casos testes de Wdribbler
    
    Wdribbler0 = 0;
    WdribblerF = 12000*2*pi/60;
    WdribblerPasso = 200*2*pi/60;
    WdribblerCasos = round((WdribblerF - Wdribbler0)/WdribblerPasso)+1;
    
    %Número de casos testes de thetaRot
    
    thetaRot0 = 0;
    thetaRotF = 360*pi/180;
    thetaRotPasso = 5*pi/180;
    thetaRotCasos = round((thetaRotF - thetaRot0)/thetaRotPasso)+1;
    
    %Número de casos testes de thetaGeneva, São 2 casos por padrão
    
    % thetaGenevaCasos = 1; % Retirado do projeto
    
    %Por fim
    N = VchuteCasos*WdribblerCasos*thetaRotCasos
    
    %Tactic factor
    lambda = @(v,w,theta) 123*v/VchuteF + 21*w/WdribblerF + 10*theta/thetaRotF;
    %% Preparing the dataset
    
    %Preparando a matriz
    
    TreinaPosicGenevaAux = zeros(N,5);
    tic
    i = 1;
    f = waitbar(0,'Starting to create trainning dataset');
    for Vchute = Vchute0:VchutePasso:VchuteF
        for Wdribbler = Wdribbler0:WdribblerPasso:WdribblerF
            %for thetaGeneva = 10*pi/180:10*pi/180:20*pi/180
            for thetaRot = thetaRot0:thetaRotPasso:thetaRotF
                %                 Vchute = 1
                %                 Wdribbler=12000*2*pi/60
                %                 thetaRot=0*pi/180
                X = kickerAngSolver(Vchute,Wdribbler,deg2rad(30),[0;0],thetaRot,[0;4.5]);
                
                k1 = find(X(1,:).^2 < 10^-6);
                k2 = k1(2:end);
                k = find((k2-k1(1:end-1))>1,1);
%                 plot(X(1,k1(k+1)),X(2,k1(k+1)),'*')
%                 hold off
                if ~isempty(k)
                    [Yf,Xf] = map2Disc(X(:,k1(k+1))',xDiscret,yDiscret,Lfield,Hfield);
                    TreinaPosicGenevaAux(i,:) = [Vchute, Wdribbler, thetaRot, Yf,lambda(Vchute, Wdribbler, thetaRot)]; % Importante! ordem dos elementos no vetor
                    i = i+1;
                end
                waitbar(i/N,f,'Creating trainning dataset: '+string(i)+"/"+string(N));
            end
            % end
        end
    end
    
    % Retira os casos não usados na matriz
    
    CasosNulos = find(abs(TreinaPosicGenevaAux(:,1)) < 10^-5);
    if isempty(CasosNulos) ~=1
        LinhasEfetivas = CasosNulos(1,1);
        
        TreinaPosicGeneva = zeros(LinhasEfetivas-1,5);
        
        for i = 1:1:LinhasEfetivas-1
            TreinaPosicGeneva(i,:) = TreinaPosicGenevaAux(i,:);
        end
    end
    
    Neff = length(TreinaPosicGeneva);
    
    timeGenMatrix = toc;
    
    waitbar(1,f,'Ranking the tactics parameter')
    yrange = min(TreinaPosicGeneva(:,4)):1:max(TreinaPosicGeneva(:,4));
    yrangeStats = yrange*0;
    % normalizing the tactic parameter
    for iter = 1:1:length(yrange)
       waitbar(iter/length(yrange),f,'Normalizing the tactics parameter')
       k = find(TreinaPosicGeneva(:,4) == yrange(iter));
%        TreinaPosicGeneva(k,5) = TreinaPosicGeneva(k,5)/max(TreinaPosicGeneva(k,5)); 
        count = 1;
        yrangeStats(iter) = length(k);
       while ~isempty(k)
           maxTactic = find(TreinaPosicGeneva(k,5)==max(TreinaPosicGeneva(k,5)));
           TreinaPosicGeneva(k(maxTactic(end)),5) = count;
           k(maxTactic(end)) = [];
           count = count+1;
       end
    end
%     zMeshGrid(yrange,11)=yrangeStats;
    waitbar(1,f,'Saving dataset')
    save TreinaPosicGeneva
    writematrix(TreinaPosicGeneva,'TreinaPosicGeneva_tol05.csv') 
    close(f)
% else
%     load TreinaPosicGeneva
% end
