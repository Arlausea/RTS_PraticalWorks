clear all;close all;clc;format short g

% Paramètres
M = 4;                    % Taille de la constellation
g0 = 1;                    % Gain de modulation
num_bits = 1e7+8;             % Nombre de bits
bits_per_symbol = log2(M);  % Nombre de bits par symbole
num_symbols = num_bits / bits_per_symbol;

% Générer la constellation et les étiquettes Gray
[mPoints, mLabels] = generate_MQAM_constellation(M);

% Initialiser les tableaux de résultats
SNR_dB_range = 0:13;  % Intervalle de Eb/N0 en dB
Pb_estimated = zeros(length(SNR_dB_range), 1);
Ps_estimated = zeros(length(SNR_dB_range), 1);

% Boucle sur chaque valeur de SNR en dB
for idx = 1:length(SNR_dB_range)
    % Calcul de SNR en linéaire
    SNR_dB = SNR_dB_range(idx) + 10*log10(log2(M));
    SNR = 10^(SNR_dB / 10);  % Conversion de dB à linéaire
    
    % Générer des bits aléatoires
    bits = randi([0 1], num_bits, 1);
    
    % Modulation
    symbols = modulate_MQAM(bits, mPoints, mLabels, M, g0);
    
    % Ajouter du bruit AWGN
    received_symbols = awgn(symbols, SNR_dB, 'measured');
    
    % Démodulation
    [demodulated_bits, closest_points] = demodulate_MQAM_with_closest(received_symbols, mPoints, mLabels);
    
    % Calcul du nombre d'erreurs
    some_threshold = 1e-10;
    num_bit_errors = sum(bits ~= demodulated_bits);
    num_symbol_errors = sum(abs(symbols - closest_points) > some_threshold);
    
    % Estimation des probabilités d'erreur
    Pb_estimated(idx) = num_bit_errors / num_bits;
    Ps_estimated(idx) = num_symbol_errors / num_symbols;
    % [Pb_theoretical,Ps_theoretical]= berawgn(SNR_dB_range,'qam',M);
    Ps_theoretical = 4*(1 - (1/sqrt(M))) * qfunc(sqrt(3*log2(M) / (M-1) * (10.^(SNR_dB_range / 10))));
    Pb_theoretical = 4*(1 - (1/sqrt(M))) * qfunc(sqrt(3*log2(M) / (M-1) * (10.^(SNR_dB_range / 10))))/log2(M);
end

% Tracer les courbes estimées et théoriques
figure;
semilogy(SNR_dB_range, Pb_estimated, 'b-o', 'DisplayName', 'P_b (estimé)');
hold on;
semilogy(SNR_dB_range, Ps_estimated, 'r-o', 'DisplayName', 'P_s (estimé)');
semilogy(SNR_dB_range, Ps_theoretical, 'r--', 'DisplayName', 'P_s (théorique)');
semilogy(SNR_dB_range, Pb_theoretical, 'b--', 'DisplayName', 'P_b (théorique)');

% Ajustements de la figure
xlabel('E_b/N_0 (dB)');
ylabel('Probabilité d''erreur');
title(['Probability of binary and symbolic error as a function of E_b/N_0 for a ',num2str(M),'-QAM']);
legend('show');
grid on;
