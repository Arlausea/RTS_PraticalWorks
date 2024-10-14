function [demodulated_bits, closest_points] = demodulate_MQAM_with_closest(received_symbols, mPoints, mLabels)
    % Démodulation M-QAM et trouver les points les plus proches
    num_symbols = length(received_symbols);
    bits_per_symbol = log2(numel(mPoints));

    % Initialiser un tableau pour stocker les bits sous forme numérique
    demodulated_bits = zeros(num_symbols * bits_per_symbol, 1);  % Stockage des bits sous forme numérique
    closest_points = zeros(num_symbols, 1);  % Stockage des points les plus proches

    % Index pour remplir demodulated_bits
    bit_idx = 1;

    for i = 1:num_symbols
        % Trouver le point de la constellation le plus proche
        distances = abs(received_symbols(i) - mPoints(:));
        [~, min_index] = min(distances);

        % Récupérer l'étiquette Gray du point le plus proche (sous forme de chaîne de caractères)
        gray_label = mLabels{min_index};  % mLabels doit être un cell array contenant des strings

        % Stocker le point de la constellation le plus proche
        closest_points(i) = mPoints(min_index);

        % Convertir l'étiquette Gray (string) en tableau numérique (bits)
        bits = double(gray_label) - '0';  % Convertir la chaîne de caractères binaire en tableau numérique

        % Stocker les bits dans demodulated_bits
        demodulated_bits(bit_idx:bit_idx + bits_per_symbol - 1) = bits;

        % Mettre à jour l'index pour les bits
        bit_idx = bit_idx + bits_per_symbol;
    end
end
