clearvars; close all; clc
%% Inputs
if isfile('Simulation_Solution.mat')
    load('Simulation_Solution.mat')
    IntPlan = SimPlan;
    bestOpt = SimOpt(SimPlan,para,500);
elseif isfile('Deterministic_Solution.mat')
    load('Deterministic_Solution.mat')
    IntPlan = DetPlan;
    bestOpt = SimOpt(DetPlan,para,500);
end
%%% Processing Time
% para.planGap = 50;
% [~,~,dat1] = xlsread('Input.xlsx','Input');
% para.proc(:,:,1) = para.planGap/10*cell2mat(dat1(2:7,2:6)); % mean proc. time {row = product, col = workstation}
% para.proc(:,:,2) = sqrt(para.planGap/10)*cell2mat(dat1(2:7,9:13)); % std. proc. time {row = product, col = workstation}
% para.setup = xlsread('Input.xlsx','Setup','A2:B2'); % setup time [mean,std];
% para.Nwst = size(para.proc,2); % Number of workstartion
% para.Nprod = size(para.proc,1); % Number of product families
% 
% %%% Delivery (Order) Plan
% [~,~,dat2] = xlsread('Input.xlsx','Delivery');
% para.order = cell2mat(dat2(3:8,2:27));
% para.Nday = size(para.order,2) - 1;
% para.invC = 1;
% para.latC = 100;
% 
% %%% Failure Parameters
% [~,~,dat3] = xlsread('Input.xlsx','Failure');
% para.Fail.age = cell2mat(dat3(11:16,2:6));
% para.Fail.lastFail = cell2mat(dat3(11:16,9:13));
% para.Fail.b = cell2mat(dat1(2:7,9:13)); 
% para.Fail.a = cell2mat(dat1(2:7,2:6)); 
% 
% [~,~,dat4] = xlsread('Input.xlsx','Repair');
% para.Repair.mu = cell2mat(dat4(2:7,2:6)); 
% para.Repair.sig = cell2mat(dat4(2:7,9:13)); % Log-Normal
% para.Repair.loc = cell2mat(dat4(2:7,16:20)); % Log-Normal

%% Simulation Optimization
LB = zeros(1,para.Nprod*para.Nday); UB = repmat([50,60,50,60,50,50],1,para.Nday); 
% opts = optimoptions('ga','PopulationSize',150,'MaxGenerations',500,'EliteCount',15,'UseParallel',true,...
%         'FunctionTolerance',1e-8,'PlotFcn', 'gaplotbestf','MaxStallGenerations',50);                   
% func = @(x) SimOpt(x,para,100);    
% InPop = zeros(50,para.Nprod*para.Nday);
% InPop(1:end-1,:) = randi(UB(1),size(InPop,1)-1,para.Nprod*para.Nday)-1;
% InPop(1,:) = reshape(IntPlan,1,para.Nprod*para.Nday);
% SimObj_best = 1e10;
% for ii=1:4
%     opts.InitialPopulationMatrix = InPop;
%     [SimSol,GA_sim_obj] = ga(func,para.Nprod*para.Nday,[],[],[],[],LB,UB,[],1:para.Nprod*para.Nday,opts);
%     InPop(6:10,:)=repmat(SimSol,5,1);
%     SimPlan = reshape(SimSol,[para.Nprod,para.Nday]);
%     [SimObj,Sim_output] = Simul(SimPlan, para,1e3);
%     if SimObj < SimObj_best
%         save('Simulation_Solution','Sim_output','SimObj','SimPlan','GA_sim_obj','para')
%         SimObj_best = SimObj;
%     end
% end

%%% Random Search
Pop = randi(UB(1),10,para.Nprod*para.Nday)-1;
Pop(1:2,:) = repmat(reshape(IntPlan,1,para.Nprod*para.Nday),2,1);
bestOpt(2:10,:) = randi([1e8,1e10],9,1);
[bestOpt,sortID] = sort(bestOpt);
Pop = Pop(sortID,:);

for ii = 1:500
    id1 = find(Pop(1,:)==0);    
    rndPop = Pop(randi([2,10]),:);  id2 = find(rndPop==0);
    Cand = zeros(10,size(Pop,2));  CandObj = nan(10,1);
    %%% Adjust values    
    add1 = 6*randn(4,size(Pop,2));   add2 = 6*randn(4,size(Pop,2));
    add1(:,id1) = 0;    add2(:,id2) = 0;
    Cand(1:4,:) = Pop(1,:) + add1; 
    Cand(5:8,:) = rndPop + add2;
    
    %%% Change zero values
    Cand(9:10,:) = [Pop(1,:);rndPop];
    Cand(9,id1(randi(length(id1)))) = randi([3,25]);
    Cand(10,id2(randi(length(id2)))) = randi([3,25]);
    Cand = max(0,round(Cand));
    for jj = 1:size(Cand,1)
        CandObj(jj) = SimOpt(Cand(jj,:),para,500);        
    end
    AllObj = [bestOpt(1:6);CandObj];    AllSol = [Pop(1:6,:);Cand];
    [AllObj,sortID] = sort(AllObj);
    AllSol = AllSol(sortID,:);
    bestOpt = AllObj(1:10,:);   Pop = AllSol(1:10,:);
    display(['Rep ',num2str(ii),': ',num2str(bestOpt(1:4)')])
end
GA_sim_obj = bestOpt(1);
SimPlan = reshape(Pop(1,:),[para.Nprod,para.Nday]);
[SimObj,Sim_output] = Simul(SimPlan, para,1e3);
save('Best_Plan','SimPlan','GA_sim_obj','para')
save('Simulation_Solution','Sim_output','SimObj','SimPlan','GA_sim_obj','para','-v7.3')
