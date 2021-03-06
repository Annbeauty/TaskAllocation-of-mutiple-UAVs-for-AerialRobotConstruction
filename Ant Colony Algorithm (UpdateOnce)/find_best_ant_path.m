function [best_ant_path,min_distance] = find_best_ant_path(all_ant_path,worker_number,task_number,...
    ant_num,Robot_position,Target_position, UAV_speed, ant_num_PP, iteratornum_PP)

% Define the calculated distance
SumOfDistance=zeros(ant_num,1);

% Calculate the distance between robots and targets positions, and then
% compare them to find the best task allocation strategy
%ite = 1;

for i=1:ant_num
    
    OneOfPath=all_ant_path((i-1)*task_number+1:(i-1)*task_number+task_number,:);
    [row,col]=find(OneOfPath==1);
    for j=1:worker_number
        
        %         display(OneOfPath)
        %         display(col)
        %         display(row)
        
        SizeOfSubMap = length (find(col==j));
        UAV_contained = find(col==j);
        Map(1,:) = Robot_position (j,:);
        for k = 2 : (SizeOfSubMap+1)
            Map(k,:) = Target_position( row(UAV_contained(k-1)),:);
        end
        [Shortest_Route, Shortest_Length] = AntColonyPathPlanning (Map, ant_num_PP, iteratornum_PP, UAV_speed(j));
        SumOfDistance(i) = SumOfDistance(i) + Shortest_Length;
        Map = [];
    end
    %ite= ite+1;
end

%display(SumOfDistance);
[min_distance,ind]=min(SumOfDistance(find(SumOfDistance~=0)));
if (isempty(min_distance) == 0)
    %min_distance = min(SumOfDistance);
    index=find(SumOfDistance==min_distance);
    %display(index)
    choice = index(unidrnd(size(index,1)));
    %display(choice);
    best_ant_path = all_ant_path((choice-1)*task_number+1:(choice-1)*task_number+task_number,:);
end
end