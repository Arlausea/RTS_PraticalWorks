% Parameters
M = 16;  % 16-QAM
g0 = 1;  % Gain for modulation
Nc = 30;  % Number of subcarriers
Npr = 16;  % Cyclic prefix length
K = 10;  % Number of OFDM blocks
h =  [0.06, 0.72, 0.54, 0.36, 0.18, 0.114, 0.078, 0.054, 0.033, 0.018, 0.012];  % Channel

% Generate the M-QAM constellation and Gray labels
[mPoints, mLabels] = generate_MQAM_constellation(M);

% Run the OFDM chain simulation without noise (Checkpoint 1)
[BER, SER] = ofdm_chain_no_noise(Nc, h, Npr, M, K, mPoints, mLabels, g0);

% Display results
fprintf('Bit Error Rate (BER): %e\n', BER);
fprintf('Symbol Error Rate (SER): %e\n', SER);
