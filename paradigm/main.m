%% Main script for training phase
% 2 classes: 1 flickering freq. 7.5Hz, 2 flickering freq. 12Hz
clear all
clc
close all

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Input
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Parameters.PreProcess.LF_cutoff=5;
Parameters.PreProcess.HF_cutoff=25;
Parameters.PreProcess.Notch_cutoff=[49 51]; 
Parameters.PreProcess.filter_order=4;
EEG_thr=100; % mircoV
num_trials = 28;
% Output directory
path='C:\Users\HP\Desktop\PhD\IEEEbrain_SummerSchool\BYB';
dirname='Picture_training'; 
outputpath_dir=fullfile(path,dirname);
if ~exist(outputpath_dir,'dir')
    mkdir(outputpath_dir);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% import .gdf file
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
data_folder = 'Data';
filename = '26082020_BYB_01.gdf';


[signal,H] = sload(fullfile(path,data_folder,filename), 1);
fs = H.SampleRate; %Hz
time = 0:1/fs:1/fs*(size(signal,1)-1);

fig_1=figure;
plot(time/60,signal-mean(signal))
xlim([0 max(time/60)])
y=ylabel('Amplitude');
x=xlabel('Time [min]');
set(x, 'Interpreter','latex','fontsize',10)
set(y, 'Interpreter','latex','fontsize',10)
title_fig= 'raw EEG-training-MEJO';
title=title(strrep(title_fig, '_', '-'));
set(title, 'Interpreter','latex','fontsize',15)
% set(fig_1, 'Position', get(0, 'Screensize'));
saveas(fig_1,fullfile(outputpath_dir,title_fig), 'png')
clear title

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Pre-processing
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Notch filter
[b_notch,a_notch]=butter(Parameters.PreProcess.filter_order/2,Parameters.PreProcess.Notch_cutoff/(fs/2),'stop');% filtro notch di ordine 4 
signal=filtfilt(b_notch,a_notch,double(signal));            

% Band-pass filter [5-25] Hz zero-phase Butterworth
d= designfilt('bandpassiir','FilterOrder',Parameters.PreProcess.filter_order, ...
    'HalfPowerFrequency1',Parameters.PreProcess.LF_cutoff,'HalfPowerFrequency2',Parameters.PreProcess.HF_cutoff, ...
    'SampleRate',fs,'DesignMethod','butter');

 signal= filtfilt(d,double(signal));

%% plot used filter
% figure
% fvtool(d)
% xlim([0 50])
% ylim([-20 0])
% hold on
% stem(7.5,-20,'g')
% stem(12,-20,'k')
% stem(15,-20,'-.g')
% stem(12*2,-20,'-.k')
% legend('Filter response','7.5 Hz stimulus signal','12 Hz stimulus signal')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% obtention and representation of the classes 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
markers_index = H.EVENT.POS;
markers_signal_left = abs(mean(signal(:,1))*ones(size(signal,1),1));
markers_signal_right =abs(mean(signal(:,1))*ones(size(signal,1),1));
markers_class = H.EVENT.TYP;
label_vector = ones(num_trials,1);
label_indices = ones(num_trials,1);

m=1;
for i=1:size(markers_index,1)
    
    if (markers_class(i)==33025)
        markers_signal_left(markers_index(i))=10e5*markers_signal_left(1)-50;  
        label_vector(m)=1; % class 1
        label_indices(m)=markers_index(i);
        m=m+1;
    elseif (markers_class(i)==33026)
        markers_signal_right(markers_index(i))=10e5*markers_signal_right(1)-50; 
        label_vector(m)=2; % class 2
        label_indices(m)=markers_index(i);
        m=m+1;
    end    
   
end

 
% Plot
fig_2=figure;
plot(time/60,signal)
xlim([0 max(time/60)])
hold on
plot(time/60,markers_signal_left(),'g')
plot(time/60,markers_signal_right(),'k')
legend=legend('class1:left','class2:right','Location','southeast');
y=ylabel('Amplitude');
x=xlabel('Time [min]');
set(x, 'Interpreter','latex','fontsize',10)
set(y, 'Interpreter','latex','fontsize',10)
set(legend, 'Interpreter','latex','fontsize',10)
title_fig= 'EEG_and_markers-training-MEJO';
title=title(strrep(title_fig, '_', '-'));
set(title, 'Interpreter','latex','fontsize',15)
set(fig_2, 'Position', get(0, 'Screensize'));
saveas(fig_2,fullfile(outputpath_dir,title_fig), 'png')
clear title
clear legend


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% data epoching 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% load data
calib_data = signal';
pos_cues = label_indices';

% epoching_result size(1,4000,20)
epoch_seconds = 4; % 4 sec. each epoch
srate = H.SampleRate;
nTrials = num_trials;
epoching_result = zeros(epoch_seconds*srate,nTrials);

trials=[0 0];
for trial_n=1:1:nTrials
    nfreq = label_vector(trial_n,1);
   if (nfreq==1) % 7.5 Hz
        trials = trials + [1 0];
    elseif (nfreq==2) % 12 Hz
        trials = trials + [0 1];
   end
   
   begin_epoch(trial_n) = pos_cues(1,trial_n) + 1*srate; % 1 sec after marker
   end_epoch(trial_n) = min([pos_cues(1,trial_n) + 1*srate + epoch_seconds*srate-1,size(calib_data,2)]);
   len = end_epoch(trial_n)-begin_epoch(trial_n)+1;
   epoching_result(1:len,trial_n) = calib_data(begin_epoch(trial_n):end_epoch(trial_n));
            
   % searching for artifacts
    artifact = 0;
    if ~isempty(find(abs(epoching_result(:,trial_n)> EEG_thr)))
            epoching_result(:,trial_n)=[];
            artifact = 1;
    end 
 
         
         if artifact==1
            disp(['artifact!!!!!!!!!!!!!!!!!', num2str(trial_n) ])
%             figure
%             plot(epoching_result(channel,:,trial_n)')
%             epoching_result(channel,:,trial_n)=0;
         end
     
end

fig_3=figure;
t_tr= 0:1/fs:1/fs*(size(epoching_result,1)-1);
plot(t_tr,epoching_result(:,14)')
y=ylabel('Amplitude');
x=xlabel('Time [s]');
xlim([0,max(t_tr)])
set(x, 'Interpreter','latex','fontsize',10)
set(y, 'Interpreter','latex','fontsize',10)
title_fig= 'Single trial class 2-12Hz-training-MEJO';
title=title(strrep(title_fig, '_', '-'));
set(title, 'Interpreter','latex','fontsize',15)
saveas(fig_3,fullfile(outputpath_dir,title_fig), 'png')
clear title

fig_4=figure;
plot(t_tr,epoching_result(:,12)')
y=ylabel('Amplitude');
x=xlabel('Time [s]');
xlim([0,max(t_tr)])
set(x, 'Interpreter','latex','fontsize',10)
set(y, 'Interpreter','latex','fontsize',10)
title_fig= 'Single trial class 1-7,5Hz-training-MEJO';
title=title(strrep(title_fig, '_', '-'));
set(title, 'Interpreter','latex','fontsize',15)
saveas(fig_4,fullfile(outputpath_dir,title_fig), 'png')
clear title

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Power Spectral Density
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
band=[0 70];
win_width=fs;
window=hamming(round(win_width));
fRes=.3;
noverlap=0;
nfft=round(fs/fRes);
for ep=1:size(epoching_result,2)
    [PSD(:,ep),freq]=pwelch(epoching_result(:,ep),window,noverlap,nfft,fs);
end
band_s=round(band/fRes)+1;
PSD=PSD(band_s(1):band_s(2),:);
freq=freq(band_s(1):band_s(2));
%% PSD Average
 PSD_class1=PSD(:,find(label_vector==1));
 PSD_class2=PSD(:,find(label_vector==2));
 PSD_AV_class1=mean(PSD_class1,2);
 PSD_AV_class2=mean(PSD_class2,2);

 PSD_alldata=cat(2,PSD_AV_class1,PSD_AV_class2);
 for class=1:size(PSD_alldata,2)
     max_value=find(PSD_alldata(:,class)==max(PSD_alldata(:,class)));
     flick_freq(class)=freq(max_value);
 end
 
lim_AV_PSD=max(abs(PSD_alldata),[],'all');
fig_5=figure;
for class=1:size(PSD_alldata,2)
    subplot(1,2,class)
    plot(freq,PSD_alldata(:,class))
    x=xlabel('Frequency [Hz]');
    y=ylabel('PSD');      
    ylim([0, lim_AV_PSD])
    xlim(band)
    title=title(strcat('class_',num2str(class),',max freq:',num2str(flick_freq(class)),'Hz'));
    set(title, 'Interpreter','latex','fontsize',12)
    set(x, 'Interpreter','latex','fontsize',10)
    set(y, 'Interpreter','latex','fontsize',10)
    clear title
end
    % Saving section
    title_fig= 'PSD-AV-training-MEJO';
    title_sup5=suptitle(strrep(title_fig, '_', '-'));
    set(title_sup5, 'Interpreter','latex','fontsize',15)
    set(fig_5, 'Position', get(0, 'Screensize'));
    saveas(fig_5,fullfile(outputpath_dir,title_fig), 'png')
    
    
fig_6=figure;
plot(freq,PSD(:,14)')
y=ylabel('PSD');
x=xlabel('Frequency [Hz]');
xlim(band)
set(x, 'Interpreter','latex','fontsize',10)
set(y, 'Interpreter','latex','fontsize',10)
title_fig= 'PSD Single trial class 2-12Hz-training-MEJO';
title=title(strrep(title_fig, '_', '-'));
set(title, 'Interpreter','latex','fontsize',15)
saveas(fig_6,fullfile(outputpath_dir,title_fig), 'png')
clear title

fig_7=figure;
plot(freq,PSD(:,12)')
y=ylabel('PSD');
x=xlabel('Frequency [Hz]');
xlim(band)
set(x, 'Interpreter','latex','fontsize',10)
set(y, 'Interpreter','latex','fontsize',10)
title_fig= 'PSD Single trial class 1-7,5Hz-training-MEJO';
title=title(strrep(title_fig, '_', '-'));
set(title, 'Interpreter','latex','fontsize',15)
saveas(fig_7,fullfile(outputpath_dir,title_fig), 'png')
clear title

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %% time-frequency representation
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% close all
% trial_class1=12;
% trial_class2=14;
% 
% x_class1=epoching_result(:,trial_class1);
% figure
% hold on
% [s,f,t,p] = spectrogram(x_class1,256,250,256,fs,'yaxis');
% spectrogram(x_class1,256,250,256,fs,'yaxis')
% [q,nd] = max(10*log10(p));
% h=colorbar;
% z=ylabel(h,'Magnitude');
% view(2)
% ylim([0 50])
% hold off
% 
% y=ylabel('Frequency [Hz]');
% x=xlabel('Time[s]');
% set(x, 'Interpreter','latex','fontsize',10)
% set(y, 'Interpreter','latex','fontsize',10)
% set(z, 'Interpreter','latex','fontsize',10)
% title_fig= 'Spectrogram Single trial class 1-7,5Hz-training-MEJO';
% title=title(strrep(title_fig, '_', '-'));
% set(title, 'Interpreter','latex','fontsize',15)
% saveas(gcf,fullfile(outputpath_dir,title_fig), 'png')
% clear title
% 
% x_class2=epoching_result(:,trial_class2);
% figure
% hold on
% [s,f,t,p] = spectrogram(x_class2,256,250,256,fs,'yaxis');
% spectrogram(x_class2,256,250,256,fs,'yaxis')
% [q,nd] = max(10*log10(p));
% h=colorbar;
% z=ylabel(h,'Magnitude');
% view(2)
% ylim([0 50])
% hold off
% y=ylabel('Frequency [Hz]');
% x=xlabel('Time[s]');
% set(x, 'Interpreter','latex','fontsize',10)
% set(y, 'Interpreter','latex','fontsize',10)
% set(z, 'Interpreter','latex','fontsize',10)
% title_fig= 'Spectrogram Single trial class 2-12Hz-training-MEJO';
% title=title(strrep(title_fig, '_', '-'));
% set(title, 'Interpreter','latex','fontsize',15)
% saveas(gcf,fullfile(outputpath_dir,title_fig), 'png')
% clear title
% % title({freq_ideal,' channel ',i})
% 

%% Initialize parameters
Fs=fs;                                  % sampling rate
t_length=floor(size(epoching_result,1)/Fs);         % data length (4 s)
TW=1:1:t_length;
TW_p=round(TW*Fs);
n_ep=14;                                % number of used epochs
sti_f=[7.5 12];             % stimulus frequencies 7.5, 12 Hz
n_sti=length(sti_f);                     % number of stimulus frequencies
n_correct=zeros(1,length(TW));


% %% Feature Matrix
% FeatureMatrix=epoching_result';
% Regressor=label_vector;
% dataInput=[FeatureMatrix,Regressor];

%% Load SSVEP data
%load SSVEPdata
epochs_class1=epoching_result(:,find(label_vector==1));
epochs_class2=epoching_result(:,find(label_vector==2));
data_input_cca = cat(3,epochs_class1,epochs_class2);
SSVEPdata=zeros(1,size(data_input_cca,1),size(data_input_cca,2),size(data_input_cca,3));
SSVEPdata(1,:,:,:)=data_input_cca;

% Data description:
% 1 channels x 4000 points x 20 trials x 2 stimulus frequencies

%% CCA for SSVEP recognition
% Construct reference signals of sine-cosine waves
N=2;    % number of harmonics

% refsig(f, S, T, N)
% f-- the fundermental frequency
% S-- the sampling rate
% T-- the number of sampling points
% N-- the number of harmonics
ref1=refsig(sti_f(1),Fs,t_length*Fs,N);
ref2=refsig(sti_f(2),Fs,t_length*Fs,N);

figure
hold on
[spectrum,freq] = spectrumCalculator(ref1,Fs);
plot(freq,spectrum)
[spectrum,freq] = spectrumCalculator(ref2,Fs);
plot(freq,spectrum)
legend('ref1','ref2')
    

%% CCA
m=1;

% Recognition
for ep=1:n_ep
    for tw_length=1:1:t_length       % time window length:  1s:1s:4s
        fprintf('CCA Processing... TW %fs, No.crossvalidation %d \n',TW(tw_length),ep);
        for j=1:2
            [wx1,wy1,r1]=cca(SSVEPdata(:,1:TW_p(tw_length),ep,j),ref1(:,1:TW_p(tw_length)));
            [wx2,wy2,r2]=cca(SSVEPdata(:,1:TW_p(tw_length),ep,j),ref2(:,1:TW_p(tw_length)));
            
            [v,idx]=max([max(r1),max(r2)]);
            correlations(ep,tw_length,j)=v;
            correlations_indices(ep,tw_length,j)=idx;
            if idx==j
                n_correct(1,tw_length)=n_correct(1,tw_length)+1;
            end
        end
    end
end

% 
%% confussion matrix calculation
window_size=4; % sec
ab=[correlations_indices(:,window_size,1);...
    correlations_indices(:,window_size,2)];
a=reshape(ab', [], 1);

b=[ones(n_ep*1,1);2*ones(n_ep*1,1)];

confusion = confusionmat(b,a)*100/n_ep;

%% Plot accuracy
figure
accuracy=100*n_correct/n_sti/n_ep;
plot(TW,accuracy,'b-*','LineWidth',1);

x=xlabel('Time window length (s)');
y=ylabel('Accuracy (%)');
grid;
xlim([0.75 tw_length]);
ylim([0 100]);
set(gca,'xtick',1:tw_length,'xticklabel',1:tw_length);
title_fig='\bf CCA for SSVEP Recognition-MEJO';
h=legend({'CCA'});
set(h,'Location','SouthEast');
set(h, 'Interpreter','latex','fontsize',10)
set(x, 'Interpreter','latex','fontsize',10)
set(y, 'Interpreter','latex','fontsize',10)
title=title(strrep(title_fig, '_', '-'));
set(title, 'Interpreter','latex','fontsize',12)
saveas(gcf,fullfile(outputpath_dir,title_fig), 'png')
clear title
size (SSVEPdata)
