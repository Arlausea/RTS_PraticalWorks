clear all;close all;clc;format short g
% Parameters
M = 16;  % 16-QAM
g0 = 1;  % Gain for modulation
Nc = 128;  % Number of subcarriers
K = 1000;  % Number of OFDM blocks
h = [1];  % Channel
EbN0_dB_range = 0:12;  % Range of Eb/N0 in dB
Npr_values = [0, 2, 4, 8, 16];  % Different cyclic prefix lengths

% Generate the M-QAM constellation and Gray labels
[mPoints, mLabels] = generate_MQAM_constellation(M);

% Initialize BER storage for each Npr
BER_all_Npr = zeros(length(EbN0_dB_range), length(Npr_values));

% Loop over different cyclic prefix lengths
for np = 1:length(Npr_values)
    Npr = Npr_values(np);  % Current cyclic prefix length
    
    % Loop over different Eb/N0 values
    for i = 1:length(EbN0_dB_range)
        EbN0_dB = EbN0_dB_range(i);
        [BER_all_Npr(i, np), ~] = ofdm_chain_with_noise(Nc, h, Npr, M, K, mPoints, mLabels, g0, EbN0_dB);
    end
end

% Plot the BER for different cyclic prefix lengths
figure;
hold on;
for np = 1:length(Npr_values)
    semilogy(EbN0_dB_range, BER_all_Npr(:, np), '-o', 'DisplayName', ['N_{pr} = ' num2str(Npr_values(np))]);
end
xlabel('E_b/N_0 (dB)');
ylabel('Bit Error Rate (BER)');
title('BER vs E_b/N_0 for Different Cyclic Prefix Lengths');
legend show;
grid on;
hold off;
