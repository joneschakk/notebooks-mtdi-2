function [X] = phasor_calculation_non_recursive(Nw,amp,phase,f0,N)


%% Update the phasors every dt with the non-recursive formula
%% algorithm of non-recursive phasor calculation
 % the phasor is calculated a first time using all the samples available in
 % the first window

%f0=50;
% period of the signal
T0=1/f0;
%N=24;                       %samples per period      
fs=f0*N;                     %Sampling frequency. Tips:
% 1- Nyquist criteria
% 2- what can you expect from a good AD converter
% 3- synchronous sampling)                     
%Nw = 3;                    % number of observation windows
Nt=N*Nw;                      %total number of samples
dt=1/fs; 
t=dt*[0:Nt-1];  % generation of time domain 
% generate the signal x with maximum amplitude 100, frequency f0 and phase angle +90° with
% respect to a cosine waveform
x = amp*cos(2*pi*f0*t+phase);                    
%x is the signal over Nw cycles

X = zeros(1,Nw); % inizialization of phasors
th = 2*pi/N;
  
for k = 1:Nw
    
    X = 0;
    for n=0:N-1
        X = X +(sqrt(2)/N)*(x(k+n)*exp(-1i*n*th));     %phasor calculation
    end
    

end





