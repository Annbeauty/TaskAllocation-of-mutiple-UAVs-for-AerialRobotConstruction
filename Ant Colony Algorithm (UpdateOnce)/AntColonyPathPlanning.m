function [Shortest_Route, Shortest_Length] = AntColonyPathPlanning (Map, ant_num_PP, iteratornum_PP, Speed)

% ant_num_PP=50;%% m ���ϸ���  
Alpha=1;%% Alpha ������Ϣ����Ҫ�̶ȵĲ���  
Beta=5;%% Beta ��������ʽ������Ҫ�̶ȵĲ���  
Rho=0.1;%% Rho ��Ϣ������ϵ��  
% iteratornum_PP=200;%%����������  
Q=100;%%��Ϣ������ǿ��ϵ��

%%��һ����������ʼ��  
n=size(Map,1);%n��ʾ����Ĺ�ģ�����и�����  
D=zeros(n,n);%D��ʾ��ȫͼ�ĸ�Ȩ�ڽӾ���  
for i=1:n  
    for j=1:n  
        if i~=j  
            D(i,j)=((Map(i,1)-Map(j,1))^2+(Map(i,2)-Map(j,2))^2)^0.5;  
        else  
            D(i,j)=eps;      %i=jʱ�����㣬Ӧ��Ϊ0�����������������Ҫȡ��������eps��������Ծ��ȣ���ʾ  
        end  
        D(j,i)=D(i,j);   %�Գƾ���  
    end  
end  
Eta=1./D;          %EtaΪ�������ӣ�������Ϊ����ĵ���  
Tau=ones(n,n);     %TauΪ��Ϣ�ؾ���  
Tabu=zeros(ant_num_PP,n);   %�洢����¼·��������  
NC=1;               %��������������¼��������  
R_best=zeros(iteratornum_PP,n);       %�������·��  
L_best=inf.*ones(iteratornum_PP,1);   %�������·�ߵĳ���  
L_ave=zeros(iteratornum_PP,1);        %����·�ߵ�ƽ������  


while NC<=iteratornum_PP        %ֹͣ����֮һ���ﵽ������������ֹͣ  
    %%�ڶ�������mֻ���Ϸŵ�n��������  
    Randpos=[];   %�漴��ȡ  
    for i=1:(ceil(ant_num_PP/n))  
        Randpos=[Randpos,randperm(n)];  
    end  
    Tabu(:,1)=(Randpos(1,1:ant_num_PP))';     
    %%��������mֻ���ϰ����ʺ���ѡ����һ�����У���ɸ��Ե�����  
    for j=2:n     %���ڳ��в�����  
        for i=1:ant_num_PP  
            visited=Tabu(i,1:(j-1)); %��¼�ѷ��ʵĳ��У������ظ�����  
            J=zeros(1,(n-j+1));       %�����ʵĳ���  
            P=J;                      %�����ʳ��е�ѡ����ʷֲ�  
            Jc=1;  
            for k=1:n  
                if length(find(visited==k))==0   %��ʼʱ��0  
                    J(Jc)=k;  
                    Jc=Jc+1;                         %���ʵĳ��и����Լ�1  
                end  
            end  
            %��������ѡ���еĸ��ʷֲ�  
            for k=1:length(J)  
                P(k)=(Tau(visited(end),J(k))^Alpha)*(Eta(visited(end),J(k))^Beta);  
            end  
            P=P/(sum(P));  
            %������ԭ��ѡȡ��һ������  
            Pcum=cumsum(P);     %cumsum��Ԫ���ۼӼ����  
            Select=find(Pcum>=rand); %������ĸ��ʴ���ԭ���ľ�ѡ������·��  
            to_visit=J(Select(1));  
            Tabu(i,j)=to_visit;  
        end  
    end  
    if NC>=2  
        Tabu(1,:)=R_best(NC-1,:);  
    end  
    %%���Ĳ�����¼���ε������·��  
    L=zeros(ant_num_PP,1);     %��ʼ����Ϊ0��m*1��������  
    for i=1:ant_num_PP  
        R=Tabu(i,:);  
        for j=1:(n-1)
            if (R(j+1) ~=1)
                L(i)=L(i)+D(R(j),R(j+1))/Speed;    %ԭ������ϵ�j�����е���j+1�����еľ���
            end
        end 
        if (R(1) ~=1)
            L(i)=L(i)+D(R(1),R(n))/Speed;      %һ���������߹��ľ��� 
        end
    end  
    L_best(NC)=min(L);           %��Ѿ���ȡ��С  
    pos=find(L==L_best(NC));  
    R_best(NC,:)=Tabu(pos(1),:); %���ֵ���������·��  
    L_ave(NC)=mean(L);           %���ֵ������ƽ������  
    NC=NC+1;                      %��������  

 %%���岽��������Ϣ��  
    Delta_Tau=zeros(n,n);        %��ʼʱ��Ϣ��Ϊn*n��0����  
    for i=1:ant_num_PP  
        for j=1:(n-1)  
            Delta_Tau(Tabu(i,j),Tabu(i,j+1))=Delta_Tau(Tabu(i,j),Tabu(i,j+1))+Q/L(i);  
            %�˴�ѭ����·����i��j���ϵ���Ϣ������  
        end  
        Delta_Tau(Tabu(i,n),Tabu(i,1))=Delta_Tau(Tabu(i,n),Tabu(i,1))+Q/L(i);  
        %�˴�ѭ��������·���ϵ���Ϣ������  
    end  
    Tau=(1-Rho).*Tau+Delta_Tau; %������Ϣ�ػӷ������º����Ϣ��  
    %%�����������ɱ�����  
    Tabu=zeros(ant_num_PP,n);             %%ֱ������������  
end  
%%���߲���������  
Pos=find(L_best==min(L_best)); %�ҵ����·������0Ϊ�棩  
Shortest_Route=R_best(Pos(1),:); %���������������·��  
Shortest_Length=L_best(Pos(1)); %��������������̾��� 