function visualize_constellation_and_received(mPoints, mLabels, received_symbols, closest_points)
    % Visualiser la constellation M-QAM avec étiquettes Gray, symboles reçus, points proches,
    % et tracer des lignes de connexion entre les symboles reçus et les points les plus proches.

    % Extraire les parties réelles et imaginaires des points de la constellation
    x = real(mPoints(:)); % Partie réelle
    y = imag(mPoints(:)); % Partie imaginaire
    z = mLabels(:);       % Étiquettes Gray (en binaire, sous forme de chaînes)

    % Calculer la taille de la constellation (M)
    M = numel(mPoints);

    % Créer une nouvelle figure
    figure;

    % Tracer les points de la constellation
    scatter(x, y, 50, 'b*'); % Points de la constellation en bleu
    hold on;
    axis([-sqrt(M) sqrt(M) -sqrt(M) sqrt(M)]); % Ajuster les axes en fonction de M

    % Ajouter les étiquettes Gray à côté des points
    for k = 1:M
        text(x(k) - 0.6, y(k) + 0.3, z(k), 'Color', [1 0 0]); % Étiquettes en rouge
    end

    % Afficher les symboles reçus
    scatter(real(received_symbols), imag(received_symbols), 50, 'rx');  % Symboles reçus en rouge

    % Afficher les points les plus proches
    scatter(real(closest_points), imag(closest_points), 50, 'go');  % Points les plus proches en vert

    % Tracer des lignes reliant chaque symbole reçu à son point le plus proche
    for i = 1:length(received_symbols)
        % Coordonnées du symbole reçu
        x_received = real(received_symbols(i));
        y_received = imag(received_symbols(i));
        
        % Coordonnées du point le plus proche
        x_closest = real(closest_points(i));
        y_closest = imag(closest_points(i));
        
        % Tracer une ligne entre le symbole reçu et le point le plus proche
        plot([x_received, x_closest], [y_received, y_closest], 'k--');  % Ligne en pointillés noirs
    end

    % Paramètres du graphique
    title('Constellation M-QAM avec les Symboles Reçus et Lignes de Connexion');
    xlabel('Partie Réelle');
    ylabel('Partie Imaginaire');
    legend('Constellation', 'Symboles Reçus', 'Points Les Plus Proches', 'Lignes de Connexion');
    grid on;
    axis equal;
    hold off;
end

