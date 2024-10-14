% Remove Cyclic Prefix
function data_without_cp = remove_cyclic_prefix(data_with_cp, Npr)
    % Removes cyclic prefix from each OFDM symbol
    data_without_cp = data_with_cp(Npr+1:end, :);  % Remove first Npr samples
end
