function out = netSolution(Xini,Xtarget,xDiscret,yDiscret,Lfield,Hfield,tol,net,rank)

% Reposicionando o robô

% translação
posTranslat =@(x) [x(1,1) - Xini(1,1);x(2,1) - Xini(2,1)];

Xobj_transl = posTranslat(Xtarget);

%rotação
M =@(thet) [cos(thet) -sin(thet); sin(thet) cos(thet)];



if (Xtarget(1,1)-Xini(1,1) > 0 && Xtarget(2,1)-Xini(2,1) > 0)%1° quadrante
    thet = atan(abs(Xobj_transl(1,1)/Xobj_transl(2,1)));
    thet = thet;
end

if (Xtarget(1,1)-Xini(1,1) < 0 && Xtarget(2,1)-Xini(2,1) > 0)%2° quadrante
    thet = atan(abs(Xobj_transl(1,1)/Xobj_transl(2,1)));
    thet = 2*pi-thet;
end

if (Xtarget(1,1)-Xini(1,1) < 0 && Xtarget(2,1)-Xini(2,1) < 0) %3° quadrante
    thet = atan(abs(Xobj_transl(1,1)/Xobj_transl(2,1)));
    thet = pi+thet;
end

if (Xtarget(1,1)-Xini(1,1) > 0 && Xtarget(2,1)-Xini(2,1) < 0)%4° quadrante
    thet = atan(abs(Xobj_transl(1,1)/Xobj_transl(2,1)));
    thet = pi-thet;
end



% robô reposicionado no (0,0), chutando na linha do gol (x = 0)
Xobj_transl_rot = (M(thet)*Xobj_transl);


[Yf,Xf] = map2Disc(Xobj_transl_rot(:)',xDiscret,yDiscret,Lfield,Hfield);%Yf é o input da rede

out = predict(net,[Yf,rank]);
out(3) = pi-out(3);
end