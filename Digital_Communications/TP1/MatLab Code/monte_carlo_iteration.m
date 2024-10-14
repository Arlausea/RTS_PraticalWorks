function [Ps, Pb] = monte_carlo_iteration(num_symbols)
    % Monte Carlo pour une seule valeur de SNR
    % M : Taille de la constellation
    % mPoints : Points de la constellation M-QAM
    % mLabels : Étiquettes Gray
    % SNR_dB : Valeur de SNR en dB
    % num_symbols : Nombre de symboles à simuler

    % Calcul du taux d'erreur de symbole P_s
    num_symbol_errors = sum(symbols ~= closest_points);   Ps = num_symbol_errors / num_symbols;
    
    % Calcul du taux d'erreur binaire P_b
    num_bit_errors = sum(bits ~= demodulated_bits);
    Pb = num_bit_errors / (num_symbols * bits_per_symbol);
end