function [trl, event] = trialfun_edid(cfg);

load('edid_marks.mat')
load(behav_filename)

cfg.dataset=filename2;
hdr=ft_read_header(cfg.dataset);
event=ft_read_event(cfg.dataset);

for j=1:length(event)
    sample(j)=event(j).sample;
    vals{j}=event(j).value;
end

s2=Shifttype;
s2(:,1)=99;
s2(:,2)=345;

s2([1 8 15 22],1)=0;

vals(1)=[];
sample(1)=[];

sample=round(sample);

if partic==4
sample(585)=[];
vals(585)=[];
end

if partic==25
sample(1)=[];
vals(1)=[];
end

for j=1:length(vals)
    valuesv(j)=sscanf(vals{j},'S%d');
end

fast=valuesv==254;
fast(find(fast==1)-1)=1;
sample(fast==1)=[];
valuesv(fast==1)=[];

fast=[];
fast=valuesv==255;
fast(find(fast==1)-1)=1;
sample(fast==1)=[];
valuesv(fast==1)=[];

trial_num=zeros(28,size(Shifttype,2));
rule1=zeros(28,size(Shifttype,2));
trials_1=zeros(28,size(Shifttype,2));

count=0;
for j=1:28
for k=1:sum(choice_cat(j,:)~=0)
count=count+1;
trial_num(j,k)=j;
rule1(j,k)=rule_type(j);
trials_1(j,k)=count;
end
end

rt1=squeeze(rt(:,:,1));
rt2=squeeze(rt(:,:,2));
% rt1(rt1==0)=NaN;
% rt2(rt2==0)=NaN;
% rt1=log10(rt1);
% rt2=log10(rt2);
rt1=rt1(:);
rt2=rt2(:);
% mz=nanmean([rt1]);
% sz=nanstd([rt1]);
% rt1=(rt1-mz)/sz;
% rt2=(rt2-mz)/sz;
Accuracy=Accuracy(:);
Shifttype=Shifttype(:);
s2=s2(:);
trial_num=trial_num(:);
rule1=rule1(:);
trials_1=trials_1(:);

all_dat=[rt1 rt2 Accuracy Shifttype rule1 trial_num trials_1 s2];
all_dat(all_dat(:,3)==0,:)=[];
[a b]=sort(all_dat(:,7));
all_dat=all_dat(b,:);

for i=1:28
temp_b=[];
temp_b=find(all_dat(:,6)==i);
all_dat(temp_b(end-1),8)=199;
all_dat(temp_b(end),8)=200;
all_dat(temp_b(end-2),8)=198;
end

s2_all=all_dat(:,8); %reversal
s2_all2=[300;s2_all(1:end-1,1)]; %reversal on previous trial
all_dat(:,8)=[];

acc2=[300;all_dat(1:end-1,3)];
acc3=[300;300;all_dat(1:end-2,3)];

st2=[all_dat(2:end,4);300];
all_dat=[all_dat acc2 acc3 st2 s2_all s2_all2];

trlbegin(:,1)=sample(1:5:end)-4000;
trlend(:,1)=sample(5:5:end)+4000;
offset=zeros(size(all_dat,1),1)-4000;

choice2(:,1)=sample(3:5:end);
choice3(:,1)=sample(5:5:end);

trl=[trlbegin trlend offset trlbegin trlend choice3 all_dat];

clearvars -except trl event