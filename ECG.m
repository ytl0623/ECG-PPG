clear
clc
close all

t = 100 :500 ;
load('ECG2.txt') ;
half = ECG2(t) ;

% [qrs_amp_raw,qrs_i_raw,delay]=pan_tompkin(half,62) ;

% Load the ECG signal and apply the Pan-Tompkins method
ecg = half ;
fs = 45; % Sampling frequency (Hz)

% Apply a bandpass filter to the ECG signal
fc_low = 5; % Low cutoff frequency (Hz)
fc_high = 15; % High cutoff frequency (Hz)
filt = designfilt('bandpassiir','FilterOrder',2, ...
    'HalfPowerFrequency1',fc_low,'HalfPowerFrequency2',fc_high, ...
    'SampleRate',fs);
ecg_filtered = filter(filt, ecg);

% Differentiate, square, and smooth the filtered ECG signal
ecg_diff = diff(ecg_filtered);
ecg_squared = ecg_diff .^ 2;
ma_window = 0.15 * fs; % Moving average window (samples)
ecg_smoothed = movmean(ecg_squared, ma_window);

% Find the QRS complex peaks and R-peaks
[qrs_peaks, qrs_locs] = findpeaks(ecg_smoothed, 'MinPeakDistance', 0.3 * fs);
r_peak_locs = zeros(size(qrs_locs));
r_window = 0.05 * fs; % R-peak search window (samples)
for i = 1:length(qrs_locs)
    [~, max_loc] = max(ecg_filtered(qrs_locs(i)-r_window:qrs_locs(i)+r_window));
    r_peak_locs(i) = qrs_locs(i) - r_window - 1 + max_loc;
end

% Find the P-peaks and T-peaks
p_window = 0.1 * fs; % P-peak search window (samples)
t_window = 0.4 * fs; % T-peak search window (samples)
p_peak_locs = zeros(size(r_peak_locs));
t_peak_locs = zeros(size(r_peak_locs));
for i = 1:length(r_peak_locs)-1
    [~, max_loc] = max(ecg_filtered(r_peak_locs(i)-p_window:r_peak_locs(i)));
    p_peak_locs(i) = r_peak_locs(i) - p_window - 1 + max_loc;
    [~, max_loc] = max(ecg_filtered(r_peak_locs(i):r_peak_locs(i)+t_window));
    t_peak_locs(i) = r_peak_locs(i) - 1 + max_loc;
end

p_peak_locs = round(p_peak_locs(1:20));
t_peak_locs = round(t_peak_locs(1:20));
r_peak_locs = round(r_peak_locs(1:20));

% Plot the ECG signal and the detected PQRST waves
figure;
t= 1:401;
t= t./45;
plot(t, ecg, 'k');
hold on;
plot(t(p_peak_locs), ecg(p_peak_locs), 'r*');
plot(t(t_peak_locs), ecg(t_peak_locs), 'g*');
plot(t(r_peak_locs), ecg(r_peak_locs), 'b*');
xlabel('Time (s)');
ylabel('Amplitude');
legend('ECG signal', 'P-peaks', 'T-peaks', 'R-peaks');


























