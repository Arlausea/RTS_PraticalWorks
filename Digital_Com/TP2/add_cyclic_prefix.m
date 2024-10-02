% Add Cyclic Prefix
function data_with_cp = add_cyclic_prefix(data, Npr)
    % Adds cyclic prefix to each OFDM symbol
    data_with_cp = [data(end-Npr+1:end, :); data];  % Prefix is last Npr samples
end
