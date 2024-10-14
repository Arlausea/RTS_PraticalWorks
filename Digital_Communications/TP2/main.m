% Générer la constellation M-QAM et les étiquettes Gray
M = 64;
g0 = 1;
[mPoints, mLabels] = generate_MQAM_constellation(M);
visualize_MQAM_constellation(M, mPoints, mLabels)

% Simulation avec des bits aléatoires
num_bits = 1e5+8;
bits_per_symbol = log2(M);
num_symbols = num_bits / bits_per_symbol;
bits = randi([0 1], num_bits, 1);
disp(bits')

% Modulation
symbols = modulate_MQAM(bits, mPoints, mLabels, M, g0);
disp(symbols')

% Ajout de bruit AWGN
SNR_dB = 16;
received_symbols = awgn(symbols, SNR_dB, 'measured');

% Démodulation et décision
[demodulated_bits, closest_points] = demodulate_MQAM_with_closest(received_symbols, mPoints, mLabels);
disp(demodulated_bits')

% Visualisation avec les étiquettes Gray et les lignes de connexion
visualize_constellation_and_received(mPoints, mLabels, received_symbols, closest_points);