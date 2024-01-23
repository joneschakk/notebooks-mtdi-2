function [ Xb ] = phasor_calculation_recursive( Nw,amp,phase,f,N,f0 )
%PHASOR_CALCULATION_RECURSIVE Summary of this function goes here
%   Detailed explanation goes here
%% Update the phasors every dt with the recursive formula
%% algorithm of recursive phasor calculation
%f0=50;
% period of the signal
  

Nt=N*Nw;                    % total number of samples

fs=f0*N;                     % Sampling frequency.
dt=1/fs;                                              
t=dt*[0:Nt-1];               % generation of time domain 

fs1 = N*f;
dt1 = 1/fs1;
t1 = dt1*[0:Nt-1];

x = amp*cos(2*pi*f*t+phase);   
x1 = amp*cos(2*pi*f*t1+phase);


X(1)=0; % inizialization of phasors
Xa_1(1) = 0;
Xa_2(1) = 0;
 
th = 2*pi/N;


df=f-f0;
w0=2*pi*f0;
dw=2*pi*df;
w=w0+dw;

% generate the signal x with maximum amplitude 100 *sqrt(2), frequency f0 and phase angle +90° with
% respect to a cosine waveform 



if dw==0
       P=1;
       Q=0;
else
    P=(sin(N*(w-w0)*dt/2))/(N*sin((w-w0)*dt/2))*exp(1i*(N-1)*(w-w0)*dt/2);
    Q=(sin(N*(w+w0)*dt/2))/(N*sin((w+w0)*dt/2))*exp(-1i*(N-1)*(w+w0)*dt/2);
end


 %first phasor : apply DFT to the samples of the first window to get the
 %phasor
for n=0:N-1
    X(1)=X(1)+(sqrt(2)/N)*x1(n+1)*exp(-1i*n*th);             %phasor calculation
end

for k=2:Nw
    X(k) = X(k-1)+(sqrt(2)/N)*(x1(N+k-1)-x1(k-1))*exp(-1i*k*th);
end

for k = 1:Nw
    Xb(1,k)=P*X(k)*exp(1i*k*(w-w0)*dt)+ Q*X(k)'*exp(-1i*k*(w+w0)*dt);
end

%Phasor calculated of the off nominal frequency signal assuming (a_1)off
%nominal sampling & (a_2) nominal sampling rates
for n=0:N-1
    Xa_1(1)=Xa_1(1)+(sqrt(2)/N)*x(n+1)*exp(-1i*n*th);             %phasor calculation
end

for k=2:Nw
    Xa_1(k) = Xa_1(k-1)+(sqrt(2)/N)*(x(N+k-1)-x(k-1))*exp(-1i*k*th);
end

for n=0:N-1
    Xa_2(1)=Xa_2(1)+(sqrt(2)/N)*x1(n+1)*exp(-1i*n*th);             %phasor calculation
end

for k=2:Nw
    Xa_2(k) = Xa_2(k-1)+(sqrt(2)/N)*(x1(N+k-1)-x1(k-1))*exp(-1i*k*th);
end

maga_1 = abs(Xa_1(Nw));
maga_2 = abs(Xa_2(Nw));
phasea_1 = rad2deg(angle(Xa_1(Nw)));
phasea_2 = rad2deg(angle(Xa_2(Nw)));
magb = abs(Xb(1,Nw));
phaseb = rad2deg(angle(Xb(1,Nw)));





