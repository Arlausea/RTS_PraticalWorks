% Perform IFFT (Time Domain Conversion)
function time_domain_data = apply_ifft(freq_domain_data)
    % Perform IFFT for each OFDM block (along the columns)
    time_domain_data = ifft(freq_domain_data);
end
