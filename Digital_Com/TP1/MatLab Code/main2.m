% Appel de la fonction generate_MQAM_constellation avec M = 4
M=4;
[MPoints, MLabels] = generate_MQAM_constellation(M);

% Affichage des points de la constellation
disp('Points de la constellation (MQAM):');
disp(MPoints);

% Affichage des étiquettes en Gray
disp('Étiquettes Gray (en décimal):');
disp(MLabels);
visualize_MQAM_constellation(M, MPoints, MLabels)