ft_defaults

clearvars

for i=19

pnums=[3 4 6 7 9 10 11 13 14 15 17 25 28 29 47 48 49 51 54];

behav_filename=strcat('/Volumes/Luis_HDD_3/SEEG_All/Patients/Patient_',num2str(pnums(i)),'/behav_data/EDID_Behav_',num2str(pnums(i)),'.mat');
filename2=strcat('/Volumes/Luis_HDD_3/SEEG_All/Patients/Patient_',num2str(pnums(i)),'/seeg_data/EDID',num2str(pnums(i)),'.set');

partic=pnums(i);
save('edid_marks.mat','filename2','behav_filename','partic');
load('electrodes.mat');

cfg = [];
cfg.dataset=filename2;
datahdr=ft_read_header(cfg.dataset);
dataevent=ft_read_event(cfg.dataset);
[data]=ft_preprocessing(cfg);
data.label(:,1)=elec_vec2{pnums(i)}';

clc
load('refs.mat')
if isempty(ref_elec{pnums(i)})==1
[elec_vec2{pnums(i)}' num2cell(1:length(elec_vec2{pnums(i)}))']
ref_elec{pnums(i)}=input('Enter Indices of Electrodes to reference?\n\n');
save('refs.mat','ref_elec')
end

count=0;
for j=1:length(ref_elec{pnums(i)})
        count=count+1;
        bipolar.tra(count,1:length(elec_vec2{pnums(i)}))=0;
        bipolar.tra(count,[ref_elec{pnums(i)}(j) ref_elec{pnums(i)}(j)-1])=[1 -1];
        bipolar.labelnew(count,1)=strcat(elec_vec2{pnums(i)}(ref_elec{pnums(i)}(j)),'-',elec_vec2{pnums(i)}(ref_elec{pnums(i)}(j)-1));
end
if sum(strcmp(elec_vec2{pnums(i)},'HEOG1'))==1 & sum(strcmp(elec_vec2{pnums(i)},'HVEOG1'))==1 & sum(strcmp(elec_vec2{pnums(i)},'LVEOG1'))==1
bipolar.tra(count+1,strcmp(elec_vec2{pnums(i)},'HEOG1'))=1;
bipolar.tra(count+2,strcmp(elec_vec2{pnums(i)},'HVEOG1'))=1;
bipolar.tra(count+3,strcmp(elec_vec2{pnums(i)},'LVEOG1'))=1;
bipolar.labelnew(count+1:count+3)={'HEOG';'HVEOG';'LVEOG'};
end
bipolar.labelold(:,1)=elec_vec2{pnums(i)};
[data]=ft_apply_montage(data,bipolar);

dataz=data;
dataz.trial{1}(:,:)=ft_preproc_highpassfilter(dataz.trial{1}(:,:),1000,1,[],'fir','twopass','no');
dataz.trial{1}(:,:)=ft_preproc_notch(dataz.trial{1}(:,:),1000,[50 100 150 200],'hnotch',1);
dataz.trial{1}(:,:)=ft_preproc_standardize(dataz.trial{1}(:,:),1,size(dataz.trial{1}(:,:),2));

% cfg=[];
% cfg.event=dataevent;
% cfg.preproc.demean='yes';
% cfg.viewmode = 'vertical';
% cfg.plotevents='yes';
% cfg.continuous='yes';
% cfg.linewidth=1;
% cfg=ft_databrowser(cfg,data);
% 
% clc
% chns2remove=[];
% [data.label num2cell(1:length(data.label))']
% chns2remove=input('Channel number to remove?');
% 
% chans2=data.label;
% chans2(chns2remove)=[];
% 
% cfg=[];
% cfg.channel=chans2;
% data=ft_selectdata(cfg,data);

cfg=[];
cfg.dataset=filename2;
cfg.trialfun='trialfun_edid';
cfg=ft_definetrial(cfg);

trl=cfg.trl;
cfg=[];
cfg.trl=trl;
final_dataz=ft_redefinetrial(cfg,dataz);

cfg=[];
cfg.event=dataevent;
cfg.artfctdef.feedback='yes';
cfg.plotevents='yes';
cfg.viewmode = 'vertical';
cfg.preproc.demean='yes';
cfg.linewidth=1;
cfg=ft_databrowser(cfg,final_dataz);

nt=1:length(final_dataz.sampleinfo(:,2));
arts=find(ismember(final_dataz.sampleinfo(:,2),cfg.artfctdef.visual.artifact));
nt(arts)=[];
keep_trials=nt;

clc
chns2remove=[];
[final_dataz.label num2cell(1:length(final_dataz.label))']
chns2remove=input('Channel number to remove?');

chans2=data.label;
chans2(chns2remove)=[];

clc
SEEG_Ok=input('SEEG Ok? 1 = Yes 2 = no\n\n');
clc
Notes=input('Notes?\n\n','s');

outname=strcat('Pre_Processed/Preproc_',num2str(pnums(i)),'.mat');

save(outname,'data','chans2','keep_trials','SEEG_Ok','Notes')

clearvars -except i

end