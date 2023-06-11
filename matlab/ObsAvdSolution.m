function out = ObsAvdSolution(Xally,Xadv,Xini,Xtarget,net,xDiscret,yDiscret,Lfield,Hfield)

[~,idxAlly] = sort(Xally(1,:));
Xally = Xally(:,idxAlly);
[~,idxAdv] = sort(Xadv(1,:));
Xadv = Xadv(:,idxAdv);

dataTab = table('Size',[1 26],'VariableTypes',repmat({'double'},1,26),'VariableNames', ...
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
    'ini_row','ini_col'});

[row,col] = map2Disc(Xally(:,1),xDiscret,yDiscret,Lfield,Hfield);
dataTab(1,:).Ally_1_row=row;
dataTab(1,:).Ally_1_col=col;
[row,col] = map2Disc(Xally(:,2),xDiscret,yDiscret,Lfield,Hfield);
dataTab(1,:).Ally_2_row=row;
dataTab(1,:).Ally_2_col=col;
[row,col] = map2Disc(Xally(:,3),xDiscret,yDiscret,Lfield,Hfield);
dataTab(1,:).Ally_3_row=row;
dataTab(1,:).Ally_3_col=col;
[row,col] = map2Disc(Xally(:,4),xDiscret,yDiscret,Lfield,Hfield);
dataTab(1,:).Ally_4_row=row;
dataTab(1,:).Ally_4_col=col;
[row,col] = map2Disc(Xally(:,5),xDiscret,yDiscret,Lfield,Hfield);
dataTab(1,:).Ally_5_row=row;
dataTab(1,:).Ally_5_col=col;
[row,col] = map2Disc(Xadv(:,1),xDiscret,yDiscret,Lfield,Hfield);
dataTab(1,:).Adv_1_row=row;
dataTab(1,:).Adv_1_col=col;
[row,col] = map2Disc(Xadv(:,2),xDiscret,yDiscret,Lfield,Hfield);
dataTab(1,:).Adv_2_row=row;
dataTab(1,:).Adv_2_col=col;
[row,col] = map2Disc(Xadv(:,3),xDiscret,yDiscret,Lfield,Hfield);
dataTab(1,:).Adv_3_row=row;
dataTab(1,:).Adv_3_col=col;
[row,col] = map2Disc(Xadv(:,4),xDiscret,yDiscret,Lfield,Hfield);
dataTab(1,:).Adv_4_row=row;
dataTab(1,:).Adv_4_col=col;
[row,col] = map2Disc(Xadv(:,5),xDiscret,yDiscret,Lfield,Hfield);
dataTab(1,:).Adv_5_row=row;
dataTab(1,:).Adv_5_col=col;
[row,col] = map2Disc(Xadv(:,6),xDiscret,yDiscret,Lfield,Hfield);
dataTab(1,:).Adv_6_row=row;
dataTab(1,:).Adv_6_col=col;
[row,col] = map2Disc(Xini(:),xDiscret,yDiscret,Lfield,Hfield);
dataTab(1,:).ini_row=row;
dataTab(1,:).ini_col=col;
[row,col] = map2Disc(Xtarget(:),xDiscret,yDiscret,Lfield,Hfield);
dataTab(1,:).Target_row=row;
dataTab(1,:).Target_col=col;

out = predict(net,[dataTab(1,:).Variables]);
end