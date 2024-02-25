clearvars; close all; clc
%% Inputs
% plan = [[100,0,50];[0,120,40];[20,70,60]];
% plan = max(0,10*(randi(20,6,5)-5));  % Note: batch 10 
%%% Processing Time
para.planGap = 50;
[~,~,dat1] = xlsread('Input.xlsx','Input');
para.proc(:,:,1) = para.planGap/10*cell2mat(dat1(2:7,2:6)); % mean proc. time {row = product, col = workstation}
para.proc(:,:,2) = sqrt(para.planGap/10)*cell2mat(dat1(2:7,9:13)); % std. proc. time {row = product, col = workstation}
para.setup = xlsread('Input.xlsx','Setup','A2:B2'); % setup time [mean,std];
para.Nwst = size(para.proc,2); % Number of workstartion
para.Nprod = size(para.proc,1); % Number of product families


%%% Delivery (Order) Plan
[~,~,dat2] = xlsread('Input.xlsx','Delivery');
para.order = cell2mat(dat2(3:8,2:27));
para.Nday = size(para.order,2) - 1;
para.invC = 1;
para.latC = 1000;

%%% Failure Parameters
[~,~,dat3] = xlsread('Input.xlsx','Failure');
para.Fail.age = cell2mat(dat3(11:16,2:6));
para.Fail.lastFail = cell2mat(dat3(11:16,9:13));
para.Fail.b = cell2mat(dat1(2:7,9:13)); 
para.Fail.a = cell2mat(dat1(2:7,2:6)); 

[~,~,dat4] = xlsread('Input.xlsx','Repair');
para.Repair.mu = cell2mat(dat4(2:7,2:6)); 
para.Repair.sig = cell2mat(dat4(2:7,9:13)); % Log-Normal
para.Repair.loc = cell2mat(dat4(2:7,16:20)); % Log-Normal

%% Deterministic Optimization
opts = optimoptions('ga','PopulationSize',300,'MaxGenerations',500,'EliteCount',25,'UseParallel',true,...
        'FunctionTolerance',1e-10,'PlotFcn', 'gaplotbestf','MaxStallGenerations',80);                   
func = @(x) DetOpt(x,para);    
LB = zeros(1,para.Nprod*para.Nday); UB = repmat([50,60,50,60,50,50],1,para.Nday); 
InPop = zeros(100,para.Nprod*para.Nday);
InPop(1:end-1,:) = randi(UB(1),size(InPop,1)-1,para.Nprod*para.Nday)-1;
for ii=1:5
    opts.InitialPopulationMatrix = InPop;
    [DetSol,GA_Det_obj] = ga(func,para.Nprod*para.Nday,[],[],[],[],LB,UB,[],1:para.Nprod*para.Nday,opts);
    InPop(1:10,:)=repmat(DetSol,10,1);
end
DetPlan = reshape(DetSol,[para.Nprod,para.Nday]);
[DetObj,Det_output] = Simul(DetPlan, para,1e3);
save('Deterministic_Solution','DetPlan','Det_output','DetObj','GA_Det_obj','para')




