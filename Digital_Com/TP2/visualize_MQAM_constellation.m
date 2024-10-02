function visualize_MQAM_constellation(M, mPoints, mLabels)
    % M : taille de la constellation (nombre de points M-QAM)
    % mPoints : matrice contenant les symboles complexes de taille sqrt(M) x sqrt(M)
    % mLabels : matrice contenant les étiquettes Gray (en binaire) de taille sqrt(M) x sqrt(M)

    % Extraire les parties réelles et imaginaires des points de la constellation
    x = real(mPoints(:)); % Partie réelle
    y = imag(mPoints(:)); % Partie imaginaire
    z = mLabels(:);       % Étiquettes Gray (en binaire, déjà sous forme de chaînes)

    % Créer une nouvelle figure
    figure;

    % Tracer les points de la constellation
    scatter(x, y, 50, 'b*'); % 'b*' : bleu avec des astérisques comme marqueurs
    axis([-sqrt(M) sqrt(M) -sqrt(M) sqrt(M)]); % Ajuster les axes selon M

    % Ajouter les étiquettes Gray (en binaire) à côté des points
    for k = 1:M
        % z(k) contient déjà les étiquettes Gray en binaire sous forme de chaînes
        text(x(k) - 0.6, y(k) + 0.3, z(k), 'Color', [1 0 0]); % Rouge pour les étiquettes
    end

    % Ajouter un titre et les labels des axes
    title(['Gray Coding for ' num2str(M) '-QAM']);
    xlabel('I (Partie réelle)');
    ylabel('Q (Partie imaginaire)');

    % Activer la grille
    grid on;
end