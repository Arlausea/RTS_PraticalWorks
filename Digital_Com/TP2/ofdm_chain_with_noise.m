function [BER, SER, received_symbols] = ofdm_chain_with_noise(Nc, h, Npr, M, K, mPoints, mLabels, g0, SNR)
    % Simulates OFDM chain with additive noise.
    
    Ns = (Nc / 2) - 1;  % Number of QAM symbols per block
    bits_per_symbol = log2(M);  % Number of bits per QAM symbol
    num_bits = K * Ns * bits_per_symbol;
    
    % Generate random bits and modulate
    bits = randi([0 1], num_bits, 1);
    symbols = modulate_MQAM(bits, mPoints, mLabels, M, g0);
    symbols_parallel = serial_to_parallel(symbols, Ns);
    
    % Apply Hermitian Symmetry
    hermitian_symbols = zeros(Nc, K);
    for k = 1:K
        hermitian_symbols(:, k) = apply_hermitian_symmetry(symbols_parallel(:, k), Ns);
    end

    % IFFT and add cyclic prefix
    time_domain_data = apply_ifft(hermitian_symbols);
    time_domain_with_cp = add_cyclic_prefix(time_domain_data, Npr);
    
    % Channel Filtering (convolution with h)
    H = fft(h, Nc);
    received_with_cp = conv2(time_domain_with_cp, h(:), 'same');
    
    % Add noise in time domain (AWGN)
    noisy_received_with_cp = awgn(received_with_cp, SNR, 'measured');
    
    % Remove Cyclic Prefix and apply FFT
    received_no_cp = remove_cyclic_prefix(noisy_received_with_cp, Npr);
    received_freq_domain = apply_fft(received_no_cp);
    
    % Equalization (Zero Forcing)
    equalized_data = received_freq_domain ./ H.';
    demod_symbols = equalized_data(2:Ns+1, :);
    
    % Parallel to Serial
    received_symbols = parallel_to_serial(demod_symbols);
    
    % Demodulate and calculate BER and SER
    [demodulated_bits, closest_points] = demodulate_MQAM_with_closest(received_symbols, mPoints, mLabels);
    num_bit_errors = sum(bits ~= demodulated_bits);
    BER = num_bit_errors / num_bits;
    
    some_threshold = 1e-3;
    num_symbol_errors = sum(abs(symbols - closest_points) > some_threshold);
    SER = num_symbol_errors / (K * Ns);
end
