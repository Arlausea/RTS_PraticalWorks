function [mPoints, mLabels] = generate_MQAM_constellation(M)
    % Vérifie si M est une puissance de 4 (car M-QAM est une constellation carrée)
    if mod(log2(M), 2) ~= 0
        error('M doit être une puissance de 4 (ex: 4, 16, 64, 256)');
    end

    % Taille de la matrice √M x √M
    sqrtM = sqrt(M);

    % Génération des niveaux possibles pour les parties réelles et imaginaires
    levels = -(sqrtM-1):2:(sqrtM-1);

    % Matrices pour stocker les points complexes et les étiquettes Gray
    mPoints = zeros(sqrtM, sqrtM);  % Pour les symboles complexes
    mLabels = strings(sqrtM, sqrtM);  % Pour les étiquettes Gray (en chaînes de caractères)

    % Remplir les matrices avec les points complexes et les étiquettes Gray
    for i = 1:sqrtM
        for j = 1:sqrtM
            % Symboles complexes: combinaison des parties réelles et imaginaires
            mPoints(i,j) = levels(i) + 1i*levels(j);
            
            % Étiquetage Gray pour la partie réelle et imaginaire
            gray_real = bitxor(i-1, floor((i-1)/2));
            gray_imag = bitxor(j-1, floor((j-1)/2));

            % Fusionner les bits Gray réels et imaginaires en un seul code binaire
            gray_code_real = dec2bin(gray_real, log2(sqrtM));
            gray_code_imag = dec2bin(gray_imag, log2(sqrtM));

            % Stocker l'étiquette Gray en tant que chaîne de caractères
            mLabels(i,j) = strcat(gray_code_real, gray_code_imag);
        end
    end
end

