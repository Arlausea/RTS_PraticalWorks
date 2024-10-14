function symbols = modulate_MQAM(bits, mPoints, mLabels, M, g0)
    % Modulation M-QAM avec gain g(0)
    bits_per_symbol = log2(M);
    num_symbols = length(bits) / bits_per_symbol;

    symbols = zeros(num_symbols, 1);
    
    for i = 1:num_symbols
        % Extraire les bits pour un symbole en tant que chaîne de caractères binaire
        bit_group = bits((i-1)*bits_per_symbol + 1:i*bits_per_symbol)';
        bit_string = num2str(bit_group(:)', '%d');  % Convertir le groupe de bits en chaîne binaire

        % Trouver les coordonnées du symbole correspondant dans mLabels
        [row, col] = find(strcmp(mLabels, bit_string));  % Recherche dans mLabels (utiliser strcmp pour comparaison de strings)

        % Moduler avec le gain g(0)
        symbols(i) = g0 * mPoints(row, col);
    end
end
