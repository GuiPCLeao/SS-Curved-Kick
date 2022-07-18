function [row,col] = map2Disc(X,xDiscret,yDiscret,Lfield,Hfield)


x = X(1);
y = X(2);

f1 = abs(yDiscret*Hfield/length(yDiscret)-y);
row = find(f1 == min(f1),1);

f2 = abs(xDiscret*Lfield/length(xDiscret)-x);
col = find(f2 == min(f2));

% M =@(thet) [cos(thet) sin(thet); -sin(thet) cos(thet)];
% X = X*M(pi/2);
% x = -X(1);
% y = X(2);
% 
% row = size(xDiscret,1)/2+floor(x/tol)+.5;
% col = size(yDiscret,2)/2+floor(y/tol)+.5;
end

