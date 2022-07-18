function dXdt = ballEquation(t,X,I,r,m,g,ViniCom)

x = X(1);
y = X(2);
vx_com = X(3);
vy_com = X(4);
wx = X(5);
wy = X(6);



CoefAtritR = 0.3; %coeficiente no deslizamento %Retirado do artigo da robocup
CoefAtritG = 0.5; %coeficiente no rolamento

if sqrt(vx_com^2+vy_com^2)>0.5805*sqrt(ViniCom(1)^2+ViniCom(2)^2) %deslizando
    Fat = -(CoefAtritG*m*g/sqrt(vx_com^2+vy_com^2)).*[vx_com; vy_com];     
else %rolando
    Fat = -(CoefAtritR*m*g/(sqrt((vx_com+r*wy)^2+(vy_com-r*wx)^2))).*[vx_com+r*wy; vy_com - r*wx];
end
    acom = Fat/m;
    vx_comDot = acom(1);
    vy_comDot = acom(2);

    T = r*[-Fat(2); Fat(1)];
    
    wxDot = 1/I*T(1);
    wyDot = 1/I*T(2);

dXdt = [vx_com vy_com vx_comDot vy_comDot wxDot wyDot]';

end
