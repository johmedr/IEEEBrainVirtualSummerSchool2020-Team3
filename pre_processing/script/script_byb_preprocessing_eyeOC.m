%% Pre-processing eyes close & eyes open

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
filename='TEAL_2020-08-24_11.51.01.wav';
[data,FSamp]=audioread(fullfile(path,data_folder,filename));
EEG=downsample(data,10)*1000;
FSamp=FSamp/10;

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
closed_eye=60*FSamp; % first minute
open_eye=121*FSamp; % second minute
EEG_close=EEG(1:closed_eye);
EEG_open=EEG(closed_eye+FSamp+1: open_eye);
EEG_alldata=cat(2,EEG_close,EEG_open);
EEG_label={'EEG_eyes_close', 'EEG_eyes_open'};

%% Compute PSD
win_width=FSamp;
window=hamming(round(win_width));
fRes=.3;
noverlap=0;
nfft=round(FSamp/fRes);
[PSD_close,freq]=pwelch(EEG_close,window,noverlap,nfft,FSamp);
[PSD_open,freq]=pwelch(EEG_open,window,noverlap,nfft,FSamp);
max_value_open=find(PSD_open==max(PSD_open));
flick_freq_open=freq(max_value_open);
max_value_close=find(PSD_close==max(PSD_close));
flick_freq_close=freq(max_value_close);
band=[0 70];
band_s=round(band/fRes)+1;
PSD_alldata=cat(2,PSD_close,PSD_open);
PSD_label={'PSD_eyes_close', 'PSD_eyes_open'};
flick_freq_alldata=cat(2,flick_freq_close,flick_freq_open);


    
%% Plot
lim_AV_EEG=max(abs(EEG_alldata),[],'all');
fig_1=figure;
for run_index=1:size(EEG_alldata,2)
    %% EEG data Plot
    t=0:1/FSamp:size(EEG_alldata,1)/FSamp-1/FSamp;
    subplot(1,2,run_index);
    plot(t,EEG_alldata(:,run_index))
    x=xlabel('Time [s]');
    y=ylabel('Amplitude');
    ylim([-lim_AV_EEG,lim_AV_EEG])
    title=title(EEG_label{run_index});
    set(title, 'Interpreter','latex','fontsize',12)
    set(x, 'Interpreter','latex','fontsize',10)
    set(y, 'Interpreter','latex','fontsize',10)
    clear title
end
 % Saving section
title_fig1= 'EEG recording';
title_sup1=suptitle(strrep(title_fig1, '_', '-'));
set(title_sup1, 'Interpreter','latex','fontsize',15)
set(fig_1, 'Position', get(0, 'Screensize'));
saveas(fig_1,fullfile(outputpath_dir,title_fig1), 'png')
clear title

%% Plot PSD
lim_AV_PSD=max(abs(PSD_alldata),[],'all');
fig_2=figure;
    for run_index=1:size(PSD_alldata,2)
        subplot(1,2,run_index)
        plot(freq(band_s(1):band_s(2)),PSD_alldata(band_s(1):band_s(2),run_index))
        x=xlabel('frequency [Hz]');
        y=ylabel('PSD');      
        ylim([0, lim_AV_PSD])
        title=title(strcat(PSD_label{run_index}, ',max freq=', num2str(flick_freq_alldata(run_index)),'Hz'));
        set(title, 'Interpreter','latex','fontsize',12)
        set(x, 'Interpreter','latex','fontsize',10)
        set(y, 'Interpreter','latex','fontsize',10)
        clear title
    end
%% Saving section
title_fig2= 'PSD';
title_sup2=suptitle(strrep(title_fig2, '_', '-'));
set(title_sup2, 'Interpreter','latex','fontsize',15)
set(fig_2, 'Position', get(0, 'Screensize'));
saveas(fig_2,fullfile(outputpath_dir,title_fig2), 'png')
