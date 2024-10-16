% Parameters
M = 16;  % 16-QAM
g0 = 1;  % Gain for modulation
Nc = 128;  % Number of subcarriers
Npr = 16;  % Cyclic prefix length
K = 1000;  % Number of OFDM blocks
h =  [1];  % Channel

% Generate the M-QAM constellation and Gray labels
[mPoints, mLabels] = generate_MQAM_constellation(M);

% Run the OFDM chain simulation without noise (Checkpoint 1)
[BER, SER] = ofdm_chain_no_noise(Nc, h, Npr, M, K, mPoints, mLabels, g0);

% Display results
fprintf('Bit Error Rate (BER): %e\n', BER);
fprintf('Symbol Error Rate (SER): %e\n', SER);
