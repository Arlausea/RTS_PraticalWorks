function [BER, SER] = ofdm_chain_with_noise(Nc, h, Npr, M, K, mPoints, mLabels, g0, EbN0_dB)
    Ns = (Nc / 2) - 1;  % Number of QAM symbols per block
    bits_per_symbol = log2(M);  % Number of bits per QAM symbol
    num_bits = K * Ns * bits_per_symbol;  % Total number of bits
    bits = randi([0 1], num_bits, 1);  % Generate random bits

    % Modulate using custom M-QAM modulation (modulate_MQAM)
    symbols = modulate_MQAM(bits, mPoints, mLabels, M, g0);

    % Apply Hermitian Symmetry directly on the serial symbols
    hermitian_symbols_serial = zeros(Nc * K, 1);
    symbol_idx = 1;
    for k = 1:K
        current_block_symbols = symbols(symbol_idx:symbol_idx+Ns-1);
        hermitian_symbols_serial((k-1)*Nc+1:k*Nc) = apply_hermitian_symmetry(current_block_symbols, Ns);
        symbol_idx = symbol_idx + Ns;
    end

    hermitian_symbols_parallel = reshape(hermitian_symbols_serial, Nc, K);
    time_domain_data = apply_ifft(hermitian_symbols_parallel);
    time_domain_with_cp = add_cyclic_prefix(time_domain_data, Npr);

    % Channel Filtering
    H = fft(h, Nc);
    received_with_cp = conv2(time_domain_with_cp, h(:), 'same');
    received_no_cp = remove_cyclic_prefix(received_with_cp, Npr);
    received_freq_domain = apply_fft(received_no_cp);

    % Add noise based on SNR
    EbN0 = 10^(EbN0_dB / 10);  % Convert dB to linear scale
    noise_variance = 1 / (EbN0 * bits_per_symbol);  % Noise variance based on normalized SNR
    noise = sqrt(noise_variance / 2) * (randn(size(received_freq_domain)) + 1i * randn(size(received_freq_domain)));
    received_freq_domain_noisy = received_freq_domain + noise;

    % Parallel to serial conversion
    received_serial = parallel_to_serial(received_freq_domain_noisy);

    % Equalization and removal of Hermitian symmetry
    received_serial_matrix = reshape(received_serial, Nc, K);
    equalized_data = zeros(size(received_serial_matrix));
    for k = 1:K
        equalized_data(:, k) = received_serial_matrix(:, k) ./ H.';
    end
    equalized_data_no_hermitian = equalized_data(2:Ns+1, :);
    equalized_serial = parallel_to_serial(equalized_data_no_hermitian);

    % Demodulate
    [demodulated_bits, closest_points] = demodulate_MQAM_with_closest(equalized_serial, mPoints, mLabels);
    demodulated_bits = demodulated_bits(1:num_bits);  % Ensure correct bit length

    % Calculate BER and SER
    num_bit_errors = sum(bits ~= demodulated_bits);
    BER = num_bit_errors / num_bits;

    some_threshold = 1e-3;
    num_symbol_errors = sum(abs(symbols - closest_points) > some_threshold);
    SER = num_symbol_errors / (K * Ns);

end
