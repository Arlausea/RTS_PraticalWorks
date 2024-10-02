function [demodulated_bits, closest_points] = demodulate_MQAM_with_closest(received_symbols, mPoints, mLabels)
    % Démodulation M-QAM en trouvant les points les plus proches avec étiquetage Gray
    num_symbols = length(received_symbols);
    bits_per_symbol = log2(numel(mPoints));

    % Initialiser un tableau pour stocker les bits démodulés sous forme numérique
    demodulated_bits = zeros(num_symbols * bits_per_symbol, 1);  % Stockage des bits
    closest_points = zeros(num_symbols, 1);  % Stockage des points les plus proches

    % Index pour remplir demodulated_bits
    bit_idx = 1;

    for i = 1:num_symbols
        % Trouver le point de la constellation le plus proche du symbole reçu
        distances = abs(received_symbols(i) - mPoints(:));  % Distance euclidienne entre chaque symbole reçu et chaque point de la constellation
        [~, min_index] = min(distances);  % Indice du point le plus proche

        % Récupérer l'étiquette Gray du point le plus proche (sous forme de chaîne de caractères)
        gray_label = mLabels{min_index};  % mLabels doit être un cell array contenant des strings

        % Stocker le point de la constellation le plus proche
        closest_points(i) = mPoints(min_index);

        % Convertir l'étiquette Gray (chaîne) en tableau numérique (bits)
        bits = double(gray_label) - '0';  % Convertir la chaîne binaire en tableau de bits (0 et 1)

        % Stocker les bits dans demodulated_bits
        demodulated_bits(bit_idx:bit_idx + bits_per_symbol - 1) = bits;

        % Mettre à jour l'index pour les bits suivants
        bit_idx = bit_idx + bits_per_symbol;
    end
end
