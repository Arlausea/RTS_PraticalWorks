% Parameters
M = 16;  % 16-QAM
g0 = 1;  % Gain for modulation
Nc = 128;  % Number of subcarriers
Npr = 16;  % Cyclic prefix length
K = 1000;  % Number of OFDM blocks
h = [0.06, 0.72, 0.54, 0.36, 0.18, 0.114, 0.078, 0.054, 0.033, 0.018, 0.012];  % Channel
EbN0_dB_range = 0:12;  % Range of Eb/N0 in dB

% Generate the M-QAM constellation and Gray labels
[mPoints, mLabels] = generate_MQAM_constellation(M);

% Initialize BER and SER arrays
BER = zeros(size(EbN0_dB_range));
SER = zeros(size(EbN0_dB_range));

% Loop over different Eb/N0 values
for i = 1:length(EbN0_dB_range)
    EbN0_dB = EbN0_dB_range(i);
    [BER(i), SER(i)] = ofdm_chain_with_noise(Nc, h, Npr, M, K, mPoints, mLabels, g0, EbN0_dB);
end

% Plot the results
figure;
subplot(2,1,1);
semilogy(EbN0_dB_range, BER, '-o');  % BER with log scale on y-axis
xlabel('E_b/N_0 (dB)');
ylabel('Bit Error Rate (BER)');
title('BER vs E_b/N_0');
grid on;

subplot(2,1,2);
semilogy(EbN0_dB_range, SER, '-o');  % SER with log scale on y-axis
xlabel('E_b/N_0 (dB)');
ylabel('Symbol Error Rate (SER)');
title('SER vs E_b/N_0');
grid on;
