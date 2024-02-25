function obj = SimOpt(var,para,Nsim)
plan = reshape(var,[para.Nprod,para.Nday]);
Nday = size(plan,2);
InventoryCost = zeros(Nsim,size(para.order,2)+1);
% sequence = cell(Nsim,Nday); startTime = cell{Nsim,Nday}; endTime = cell(Nsim,Nday);
age = para.Fail.age; age(isnan(age)) = 0;
parfor sim = 1:Nsim    
    rng('shuffle')
    plan_sim = plan; 
    Inv = zeros(para.Nprod,size(para.order,2)+1); InvCost = zeros(1,size(para.order,2)+1);
    lastFail = para.Fail.lastFail; lastFail(isnan(lastFail)) = 0;    
    for dd = 1:Nday        
        % Create task sequence: 1..Nprod: product family, 0: setup, negative: failure (for future)
        % Create matrix of task duration {Nevents x NWst}
        planDay = plan_sim(:,dd);
        PlanProd = find(planDay>0); % identify products will be produced
        task = []; taskDur = [];
        for ii = 1:length(PlanProd)
            %%% setup
            task(end+1,:) = 0; % setup before produce product PlanProd(ii)
            taskDur(end+1,:) = zeros(1,para.Nwst);
            taskDur(end,1) = normrnd(para.setup(1),para.setup(2)); % assign the setup time on WS 1 only!!!

            %%% production
            task(end+1:end+planDay(PlanProd(ii)),:) = PlanProd(ii); % produce products PlanProd(ii)
            taskDur(end+1:end+planDay(PlanProd(ii)),:) = ...
                normrnd(repmat(para.proc(PlanProd(ii),:,1),planDay(PlanProd(ii)),1),...
                repmat(para.proc(PlanProd(ii),:,2),planDay(PlanProd(ii)),1));
        end
        % Note!!!!: some duration times are negatvive (<0) due to norm. dist is
        % from -inf to inf. Hence, we set these <0 values to zeros here OR instead of
        % using normrnd, we have to make truncate norm random at 0
        taskDur(taskDur<0) = 0;

        %%% Determine start time and end time of each WS
        [startT,endT] = StartTimeDet(taskDur);

    %%% Insert Failure
    rndU = rand(1,para.Nwst);
    a = zeros(para.Nprod,para.Nwst); a(PlanProd,:) = para.Fail.a(PlanProd,:); a(isnan(a)) = 0;
    b = zeros(para.Nprod,para.Nwst); b(PlanProd,:) = para.Fail.b(PlanProd,:); b(isnan(b)) = 0;
    failT = (lastFail.^b-log(rndU)./a).^(1./b)-para.Fail.age;    
    fail = failT<=dd & failT > dd -1;
    if sum(fail,'all') > 0
        lastFail(find(fail)) = failT(find(fail)) + age(find(fail));  % update last failure time
        tmp = failT(find(fail));
        failStart = min(tmp-dd+1)*14*60; 
        failID = find(failT==min(tmp));
        repairT = para.Repair.loc(failID) + lognrnd(para.Repair.mu(failID),para.Repair.sig(failID));   
        failTimeMat = zeros(size(taskDur));
        for ws = 1:para.Nwst
            fID = find(endT(:,ws)<failStart,1,'last');
            if fID < length(task)
                task = [task(1:fID);-ws;task(fID+1:end)];
                taskDur = [taskDur(1:fID,:); zeros(1,para.Nwst); taskDur(fID+1:end,:)];
                taskDur(fID+1,ws) = repairT;
                failTimeMat = [failTimeMat(1:fID,:); failTimeMat(fID+1,:); failTimeMat(fID+1:end,:)];
                failTimeMat(fID+1,ws) = failStart;
            else
                break
            end
        end
        [startT,endT] = StartTimeDet(taskDur,failTimeMat);
    end       
        
    
    % Assume that 1 day consists only 14 hrs (840 mins) working. Then all jobs
        % that after 10hrs will be assign to next planning day
        if isempty(task)
            remProd = [];
        else
            remProd = task(find(endT(:,end)>=840)); % remaining tasks
        end
        task = task(1:end-length(remProd));
        remProd = remProd(remProd>0); % Taking only production (remove setup and failure)
        if ~isempty(remProd) % count remaining planned products and move to next day (update plan)
            for ii = 1:length(PlanProd)
                rem = sum(remProd==PlanProd(ii));
                if rem > 0
                    plan_sim(PlanProd(ii),dd) = plan_sim(PlanProd(ii),dd) - rem;                    
                    if dd < Nday
                        nextProDay = find(plan(PlanProd(ii),dd+1:end)>0,1);
                        if ~isempty(nextProDay)
                            plan_sim(PlanProd(ii),dd+nextProDay) = plan_sim(PlanProd(ii),dd+nextProDay) + rem;
                        end
                    end
                end
            end
        end    
        Inv(:,dd+1) = Inv(:,dd) + para.planGap*plan_sim(:,dd) - para.order(:,dd);
    end  
    Inv(:,end) = Inv(:,end-1) - para.order(:,end);
    InvCost = sum((Inv>=0).*Inv*para.invC + (Inv<0).*(-Inv)*para.latC);
    InventoryCost(sim,:) = InvCost;
end
obj = mean(sum(InventoryCost,2));
end

