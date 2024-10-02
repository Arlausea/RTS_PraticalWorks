% Perform FFT (Frequency Domain Conversion)
function freq_domain_data = apply_fft(time_domain_data)
    % Perform FFT for each OFDM block (along the columns)
    freq_domain_data = fft(time_domain_data);
end
