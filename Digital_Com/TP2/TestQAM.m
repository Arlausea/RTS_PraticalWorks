clear all; close all; clc;

% Parameters
M = 16;  % M-QAM order
g0 = 1;  % Gain for modulation
num_bits = 1000;  % Number of bits for test
bits_per_symbol = log2(M);

% Generate random bits
bits = randi([0 1], num_bits, 1);

% Generate the QAM constellation and Gray labels
[mPoints, mLabels] = generate_MQAM_constellation(M);

% Modulate using custom M-QAM modulation (modulate_MQAM)
symbols = modulate_MQAM(bits, mPoints, mLabels, M, g0);

% No channel (perfect transmission), demodulate back to bits
[demodulated_bits, ~] = demodulate_MQAM_with_closest(symbols, mPoints, mLabels);

% Calculate the number of bit errors
num_bit_errors = sum(bits ~= demodulated_bits);
fprintf('Bit errors: %d\n', num_bit_errors);

if num_bit_errors == 0
    disp('Modulation and demodulation are working perfectly.');
else
    disp('There is an issue with modulation or demodulation.');
end
