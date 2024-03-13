function setfigdefaults
% for labels
set(groot,'defaultTextInterpreter','latex');
set(groot,'defaultTextFontName','Times New Roman'); 
set(groot,'defaultTextFontSize',18);
% for axes text
set(groot, 'defaultAxesTickLabelInterpreter','latex'); 
set(groot,'defaultAxesFontName','Times New Roman');
set(0,'defaultAxesFontSize',16); 
% for plots
set(groot,'defaultAxesLineStyleOrder',{'-','--','-.','-+','-o','-*','-x','-s','-d','-^','-v','->','-<','p','h'}); 
% for plot lines
set(groot,'defaultLineMarkerSize',5);
set(groot,'defaultLineLineWidth',3); 
% for legends
set(groot, 'defaultLegendInterpreter','latex');
set(groot, 'defaultLegendFontName','Times New Roman');
set(groot, 'defaultLegendFontSize',14);
end
