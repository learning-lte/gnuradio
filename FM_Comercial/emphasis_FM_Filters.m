% Esta es una aproximación a los filtros de preenfasis y deenfasis usados en la transmision de
% audio.
% Una versión más sofisticada se puede encontrar en
% https://github.com/gnuradio/gnuradio/blob/master/gr-analog/python/analog/fm_emph.py
close all
clc
clear all


fs=44.1e3;
tau=75e-6;

% De-Enphasis
nums=[1];
dens=[tau,1];
Hs=tf(nums,dens)
Hz=c2d(Hs,1/fs)
figure('name','De-emphasis Continuous/Discrete','NumberTitle','off')
h=bodeplot(Hs,Hz,{0,5*2*pi*fs});
setoptions(h,'FreqUnits','Hz','Grid','on'),legend('H(s)','H[z]')

% Pre-Enphasis
alpha=1/(1+tau*fs);
fn=(1/tau)/(pi*fs); % Frecuencia normalizada estilo Matlab (x PI [rad/sample])
                    % https://www.mathworks.com/matlabcentral/answers/258846-what-is-actually-normalized-frequency
numz=[alpha];
denz=[1,-(1-alpha)];
HzDSP=filt(numz,denz,1/fs)
K=1/abs(numz/(denz(1)+denz(2)*1i*(.5^-1))); % La ganancia que debe aplicarse al
                                            % filtro HP es el inverso del
                                            % valor de la respuesta del filtro
                                            % LP a la frecuencia de Nyquist 
                                            % (0.5 en unidades normalizadas)
K=K/(1+0.125*exp(-11.94*fn));  % Correccion numérica (no se a que se debe el desajuste)
[numHP,denHP]=iirlp2hp(numz,denz,fn,(0.5-fn));
HzHP=filt(K.*numHP,denHP,1/fs)
h=fvtool(HzDSP.num{1,1},HzDSP.den{1,1},HzHP.num{1,1},HzHP.den{1,1},'Fs',fs);
h.FrequencyScale='Log';
%h.NormalizedFrequency='on';
