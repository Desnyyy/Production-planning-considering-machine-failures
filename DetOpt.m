function [obj,output] = DetOpt(var,para)

plan = reshape(var,[para.Nprod,para.Nday]);
Nday = size(plan,2);
Inv = zeros(para.Nprod,size(para.order,2)+1); InvCost = zeros(1,size(para.order,2)+1);

for dd = 1:Nday
    % Create task sequence: 1..Nprod: product family, 0: setup, negative: failure (for future)
    % Create matrix of task duration {Nevents x NWst}
    planDay = plan(:,dd);
    PlanProd = find(planDay>0); % identify products will be produced
    task = []; taskDur = [];
    for ii = 1:length(PlanProd)
        %%% setup
        task(end+1,:) = 0; % setup before produce product PlanProd(ii)
        taskDur(end+1,:) = zeros(1,para.Nwst);
        taskDur(end,1) = para.setup(1); % assign the setup time on WS 1 only!!!

        %%% production
        task(end+1:end+planDay(PlanProd(ii)),:) = PlanProd(ii); % produce products PlanProd(ii)
        taskDur(end+1:end+planDay(PlanProd(ii)),:) = repmat(para.proc(PlanProd(ii),:,1),planDay(PlanProd(ii)),1);

    end
    % Note!!!!: some duration times are negatvive (<0) due to norm. dist is
    % from -inf to inf. Hence, we set these <0 values to zeros here OR instead of
    % using normrnd, we have to make truncate norm random at 0
    taskDur(taskDur<0) = 0;

    %%% Determine start time and end time of each WS
    [startT,endT] = StartTimeDet(taskDur);

    % Assume that 1 day consists only 14 hrs (840 mins) working. Then all jobs
    % that after 10hrs will be assign to next planning day
    if isempty(task)
        remProd = [];
    else
        remProd = task(find(endT(:,end)>=840)); % remaining tasks
    end
    DummyPen = length(remProd) * 1e8;
    
    Inv(:,dd+1) = Inv(:,dd) + para.planGap*plan(:,dd) - para.order(:,dd);
    output.sequence{dd} = task; output.startTime{dd} = startT; output.endTime{dd} = endT;    
end
Inv(:,end) = Inv(:,end-1) - para.order(:,end);
InvCost = sum((Inv>=0).*Inv*para.invC + (Inv<0).*(-Inv)*para.latC);

obj = sum(InvCost,2) + DummyPen;
output.adjustPlan = plan; output.Inv = Inv; output.InvCost = InvCost;
end

