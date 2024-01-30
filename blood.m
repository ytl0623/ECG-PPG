clear
clc
close all

t = 100 :500 ;
load('SPO2.txt') ;
half = SPO2(t) ;

% Load the PPG signal and sampling frequency
ppg = half ;
fs = 100; % Sampling frequency (Hz)

% Bandpass filter the PPG signal
fc_low = 0.5; % Low cutoff frequency (Hz)
fc_high = 8; % High cutoff frequency (Hz)
filt = designfilt('bandpassiir','FilterOrder',2, ...
    'HalfPowerFrequency1',fc_low,'HalfPowerFrequency2',fc_high, ...
    'SampleRate',fs);
ppg_filtered = filter(filt, ppg);

% Find the peaks and valleys of the filtered PPG signal
[peaks, peak_locs] = findpeaks(ppg_filtered);
[valleys, valley_locs] = findpeaks(-ppg_filtered);

% Calculate the mean pulse interval
pulse_intervals = diff(peak_locs) / fs; % Pulse interval in seconds
mean_pulse_interval = mean(pulse_intervals);

% Calculate the systolic blood pressure (SBP) and diastolic blood pressure (DBP)
sbp = 0.9 * peaks;
dbp = 0.55 * peaks + 0.45 * valleys;

% Smooth the SBP and DBP signals using a moving average filter
ma_window = 5; % Moving average window (samples)
sbp_smoothed = movmean(sbp, ma_window);
dbp_smoothed = movmean(dbp, ma_window);

% Plot the PPG signal and the SBP and DBP estimates
t = (1:length(ppg)) / fs;
figure;
plot(t, ppg, 'k');
hold on;
plot(t(peak_locs), peaks, 'r*', 'MarkerSize', 10);
plot(t(valley_locs), valleys, 'b*', 'MarkerSize', 10);
plot(t, sbp_smoothed, 'r', 'LineWidth', 2);
plot(t, dbp_smoothed, 'b', 'LineWidth', 2);
xlabel('Time (s)');
ylabel('Amplitude');
legend('PPG signal', 'Peaks', 'Valleys', 'SBP', 'DBP');
