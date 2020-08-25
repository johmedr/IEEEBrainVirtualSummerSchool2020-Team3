%% Pre-processing training paradigm

clear all
close all
clc
%% Input
path='C:\Users\HP\Desktop\PhD\IEEEbrain_SummerSchool\BYB';
data_folder='Data';
Parameters.PreProcess.LF_cutoff= 1;
Parameters.PreProcess.HF_cutoff=45;
Parameters.PreProcess.Notch_cutoff=[49 51]; 
Parameters.PreProcess.filter_order=4;
EEG_thr=100; % mircoV
%% Output directory
dirname='Picture'; 
outputpath_dir=fullfile(path,dirname);
if ~exist(outputpath_dir,'dir')
    mkdir(outputpath_dir);
end

%% Loading data
data_filename='DEVA_2020-08-25.wav';
[data,FSamp]=audioread(fullfile(path,data_folder,data_filename));
markers_filename='DEVA_2020-08-25-events_times.txt';
fileID = fopen(fullfile(path,data_folder,markers_filename),'r');
markers=fscanf(fileID,'%d,%f',[2,12]);
sequence=markers(1,:);
markers_times=marskers(2,:); %s
EEG=downsample(data,10)*1000;
FSamp=FSamp/10;
markers_ind=round(markers_times*FSamp);

%% Pre-processing
% Notch filter
[b_notch,a_notch]=butter(Parameters.PreProcess.filter_order/2,Parameters.PreProcess.Notch_cutoff/(FSamp/2),'stop');% filtro notch di ordine 4 
EEG=filtfilt(b_notch,a_notch,double(EEG));            

% Band-pass filter [1-45] Hz zero-phase Butterworth
d= designfilt('bandpassiir','FilterOrder',Parameters.PreProcess.filter_order, ...
    'HalfPowerFrequency1',Parameters.PreProcess.LF_cutoff,'HalfPowerFrequency2',Parameters.PreProcess.HF_cutoff, ...
    'SampleRate',FSamp,'DesignMethod','butter');

 EEG= filtfilt(d,double(EEG));


%% Artifact detection
artifact=find(abs(EEG)>EEG_thr);
if isempty(artifact)
   art=0
else 
   art=1
end

%% Epoching
for ep=1:length(markers_ind)
   epochs(:,ep)=EEG(markers_ind(ep):markers_ind(ep)+7*FSamp-1);
end

%% Compute PSD
win_width=FSamp;
window=hamming(round(win_width));
fRes=.3;
noverlap=0;
nfft=round(FSamp/fRes);
for ep=1:size(epochs,2)
    [PSD(:,ep),freq]=pwelch(epochs(:,ep),window,noverlap,nfft,FSamp);
end
band=[0 70];
band_s=round(band/fRes)+1;
%% classes
  class_0=find(sequence==0);
  PSD_0=PSD(:,class_0);
  class_1=find(sequence==1);
  PSD_1=PSD(:,class_1);
  class_2=find(sequence==2);
  PSD_2=PSD(:,class_2);
  class_3=find(sequence==3);
  PSD_3=PSD(:,class_3);

%% PSD Average
 PSD_AV_0=mean(PSD_0,2);
 PSD_AV_1=mean(PSD_1,2);
 PSD_AV_2=mean(PSD_2,2);
 PSD_AV_3=mean(PSD_3,2);
 PSD_alldata=cat(2,PSD_AV_0,PSD_AV_1,PSD_AV_2,PSD_AV_3);
 for class=1:size(PSD_alldata,2)
     max_value=find(PSD_alldata(:,class)==max(PSD_alldata(:,class)));
     flick_freq(class)=freq(max_value);
 end
 
    
    
%% Plot
lim_AV_EEG=max(abs(EEG),[],'all');
fig_1=figure;
%% EEG data Plot
t=0:1/FSamp:size(EEG,1)/FSamp-1/FSamp;
plot(t,EEG)
x=xlabel('Time [s]');
y=ylabel('Amplitude');
ylim([-lim_AV_EEG,lim_AV_EEG])
xlim([0,max(t)])
set(x, 'Interpreter','latex','fontsize',10)
set(y, 'Interpreter','latex','fontsize',10)
clear title
 % Saving section
title_fig1= 'EEG recording-traing';
title_sup1=suptitle(strrep(title_fig1, '_', '-'));
set(title_sup1, 'Interpreter','latex','fontsize',15)
set(fig_1, 'Position', get(0, 'Screensize'));
saveas(fig_1,title_fig1 , 'png')
clear title

    %% Plot PSD
    lim_AV_PSD=max(abs(PSD_alldata),[],'all');
    fig_2=figure;
    for class=1:size(PSD_alldata,2)
        subplot(1,4,class)
        plot(freq(band_s(1):band_s(2)),PSD_alldata(band_s(1):band_s(2),class))
        x=xlabel('frequency [Hz]');
        y=ylabel('PSD');      
        ylim([0, lim_AV_PSD])
        xlim(band)
        title=title(strcat('class_',num2str(class-1),',max freq:',num2str(flick_freq(class)),'Hz'));
        set(title, 'Interpreter','latex','fontsize',12)
        set(x, 'Interpreter','latex','fontsize',10)
        set(y, 'Interpreter','latex','fontsize',10)
        clear title
    end
    % Saving section
    title_fig2= 'PSD-training';
    title_sup2=suptitle(strrep(title_fig2, '_', '-'));
    set(title_sup2, 'Interpreter','latex','fontsize',15)
    set(fig_2, 'Position', get(0, 'Screensize'));
    saveas(fig_2,title_fig2, 'png')
    