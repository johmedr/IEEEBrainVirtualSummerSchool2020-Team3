%% Pre-processing flickering checkerboard

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
subjects={'BAHE','FAAL'};
%% Output directory
dirname='Picture'; 
outputpath_dir=fullfile(path,dirname);
if ~exist(outputpath_dir,'dir')
    mkdir(outputpath_dir);
end

for subj=1:length(subjects)
%% loading data
    filename=strcat(subjects{subj},'_2020-08-25.wav');
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
   
    %% Compute PSD
    win_width=FSamp;
    window=hamming(round(win_width));
    fRes=.3;
    noverlap=0;
    nfft=round(FSamp/fRes);
    [PSD,freq]=pwelch(EEG,window,noverlap,nfft,FSamp);
    max_value=find(PSD==max(PSD));
    flick_freq=freq(max_value);
    band=[0 70];
    band_s=round(band/fRes)+1;
    
    
    
    
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
    title_fig1=strcat('EEG recording_',subjects{subj});
    title_sup1=suptitle(strrep(title_fig1, '_', '-'));
    set(title_sup1, 'Interpreter','latex','fontsize',15)
    set(fig_1, 'Position', get(0, 'Screensize'));
    saveas(fig_1,fullfile(outputpath_dir,title_fig1) , 'png')
    clear title

    %% Plot PSD
    lim_AV_PSD=max(abs(PSD),[],'all');
    fig_2=figure;
    plot(freq(band_s(1):band_s(2)),PSD(band_s(1):band_s(2)))
    x=xlabel('frequency [Hz]');
    y=ylabel('PSD');      
    ylim([0, lim_AV_PSD])
    set(x, 'Interpreter','latex','fontsize',10)
    set(y, 'Interpreter','latex','fontsize',10)
    % Saving section
    title_fig2= strcat('PSD_',subjects{subj},'-max_freq-',num2str(round(flick_freq)),'Hz');
    title_sup2=suptitle(strrep(title_fig2, '_', '-'));
    set(title_sup2, 'Interpreter','latex','fontsize',15)
    set(fig_2, 'Position', get(0, 'Screensize'));
    saveas(fig_2,fullfile(outputpath_dir,title_fig2), 'png')
    %%
    clear EEG
    clear PSD
    clear title_fig1
    clear tigle_fig2
    end