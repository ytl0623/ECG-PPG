clear
clc
close all

t = 3480:4940 ;
load('SPO2.txt') ;
half = SPO2(t) ;

%A point
TF_A = islocalmin(half, 'MinSeparation', 40);
% plot(t,half,t(TF_A),half(TF_A),'r*')

%B point
% TF_B = islocalmax (half, 'MinSeparation', 30);
% plot(t,half,t(TF_B),half(TF_B),'r*')

%B, C point
%Preprocess
for k = 1:length(half)-1
    if half(k) == half(k+1)
        half(k+1) = half(k+1) + 0.01 ;
    end
end

TF_BC = islocalmax(half, 'MinSeparation', 10);
% plot(t,half,t(TF_BC),half(TF_BC),'r*')

%Split B from BC
TF_B = TF_BC ;
count = 0 ;
for k = 1:length(TF_B)-1
    if TF_B(k) == 1 && count > 0
        TF_B(k) = 0 ;
        count = 0 ;
    elseif TF_B(k) == 1
        count = count + 1 ;
    end
end

%Split C from B, BC
TF_C = TF_BC ;
for k = 1:length(TF_B)-1
    if TF_B(k) == TF_BC(k)
        TF_C(k) = 0 ;
    else
        TF_C(k) = 1 ;
    end
end

%plot
t = t./62 ;
hold on
plot(t,half)
plot(t(TF_A),half(TF_A),'r*')
plot(t(TF_B),half(TF_B),'ro')
plot(t(TF_C),half(TF_C),'rx')

legend('Original', 'A', 'B', 'C', 'Location', 'northwest') ;
xlabel('Time (sec)') ;
ylabel('PPG (mv)') ;

%Cal. SI
loc_B = find(TF_B==1) ;
loc_C = find(TF_C==1) ;

T_DVP = loc_C - loc_B ;
mean_T_DVP = sum(T_DVP) / 30 ;

SI = 1.66 / mean_T_DVP

%Cal. RI
loc_A = find(TF_A==1) ;
pulse_A = half(loc_A) ;
pulse_B = half(loc_B) ;
pulse_C = half(loc_C) ;

pulse_UP = pulse_B - pulse_A ;
pulse_DOWN = pulse_C - pulse_A ;

mean_pulse_UP = sum(pulse_UP) / 30 ;
mean_pulse_DOWN = sum(pulse_DOWN) / 30 ;

RI = ( mean_pulse_DOWN / mean_pulse_UP ) * 100


















