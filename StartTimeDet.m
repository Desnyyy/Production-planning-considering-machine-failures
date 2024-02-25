function [StartT,EndT] = StartTimeDet(taskDur,varargin)
Nwst = size(taskDur,2);
if nargin > 1
    failT = varargin{1};
else
    failT = zeros(size(taskDur));
end
StartT = zeros(size(taskDur,1),Nwst); EndT = zeros(size(taskDur,1),Nwst);
for ws = 1:Nwst
    if ws > 1
        StartT(:,ws) = EndT(:,ws-1); 
    else
        StartT(:,1) = max(cumsum([0;taskDur(1:end-1,1)]),failT(:,1));
    end
    EndT(:,ws) = StartT(:,ws) + taskDur(:,ws);
    cond = 1;
    while cond >0 % start time of task in WS(i) depend on the end time of same task on WS(ii-1) and end time of previous task of WS(ii)
        time1 = failT(2:end,ws); time2 = EndT(1:end-1,ws);
        if ws>1
            time3 = EndT(2:end,ws-1);
        else
            time3 = zeros(size(time1));
        end

        tmp = StartT(2:end,ws) - max([time1,time2,time3],[],2);
        cond = sum(tmp<0);
        if cond>0
            StartT(2:end,ws) = max([time1,time2,time3],[],2);
            EndT(:,ws) = StartT(:,ws) + taskDur(:,ws);
        end
    end
end
end