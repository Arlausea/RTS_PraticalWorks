function [BER, SER] = ofdm_chain_no_noise(Nc, h, Npr, M, K, mPoints, mLabels, g0)
    % Simulates OFDM communication chain without additive noise.
    % Nc: number of subcarriers
    % h: channel impulse response
    % Npr: cyclic prefix length
    % M: M-QAM modulation order
    % K: number of OFDM blocks
    % mPoints: M-QAM constellation points
    % mLabels: Gray labels for M-QAM
    % g0: Gain for M-QAM modulation
    
    Ns = (Nc / 2) - 1;  % Number of QAM symbols per block
    bits_per_symbol = log2(M);  % Number of bits per QAM symbol

    % Generate random bits
    num_bits = K * Ns * bits_per_symbol;
    bits = randi([0 1], num_bits, 1);

    % Modulate using custom M-QAM modulation (modulate_MQAM)
    symbols = modulate_MQAM(bits, mPoints, mLabels, M, g0);

    % Apply Hermitian Symmetry directly on the serial symbols
    hermitian_symbols_serial = zeros(Nc * K, 1);
    symbol_idx = 1;
    for k = 1:K
        % Extract Ns symbols for the current OFDM block
        current_block_symbols = symbols(symbol_idx:symbol_idx+Ns-1);
        
        % Apply Hermitian symmetry to the current block
        hermitian_symbols_serial((k-1)*Nc+1:k*Nc) = apply_hermitian_symmetry(current_block_symbols, Ns);
        
        % Update symbol index
        symbol_idx = symbol_idx + Ns;
    end
    
    % Print first 10 values after Hermitian symmetry for the first OFDM block
    disp('Hermitian Symmetric Vector (First 10 values of first OFDM block):');
    disp(hermitian_symbols_serial(1:10));

    % Reshape the hermitian_symbols_serial into Nc x K matrix for parallel processing
    hermitian_symbols_parallel = reshape(hermitian_symbols_serial, Nc, K);

    % Apply IFFT
    time_domain_data = apply_ifft(hermitian_symbols_parallel);

    % Add Cyclic Prefix
    time_domain_with_cp = add_cyclic_prefix(time_domain_data, Npr);

    % Channel Filtering (no noise)
    H = fft(h, Nc);
    received_with_cp = conv2(time_domain_with_cp, h(:), 'same');
    

    % conv() Nc +  Npr + L -1
    % received_with_cp = received_with_cp(1:Nc+Npr,1)

    % Remove Cyclic Prefix
    received_no_cp = remove_cyclic_prefix(received_with_cp, Npr);

    % Apply FFT
    received_freq_domain = apply_fft(received_no_cp);
    disp(received_freq_domain(:,1));
    %  Convert received frequency domain data from parallel to serial
    received_serial = parallel_to_serial(received_freq_domain);  % Convert received data to serial

    % Check the size of received_serial
    expected_size = Nc * K;  % Nc subcarriers for K blocks
    if numel(received_serial) ~= expected_size
        error('The number of elements in received_serial (%d) does not correspond to the product of Nc and K (%d)', ...
            numel(received_serial), expected_size);
    end

    % Apply Zero Forcing equalisation directly to serial data
    H_serial = repmat(H.', K, 1);  % Extend the channel response to match all serial data
    equalized_serial = received_serial ./ H_serial;  % Zero Forcing equalization

    % Suppress Hermitian symmetry directly on serial data
    % Nc_half corresponds to the index of (Ns + 1) after symmetries have been removed
    Nc_half = (Nc / 2);  % Nc/2 corresponds to the Hermitian part of the data
    num_elements_per_block = Nc;  % Number of elements per block

    %  Delete elements corresponding to Hermitian symmetry
    equalized_serial_no_hermitian = [];  % Initialise an empty vector to store non-Hermitian data
    for block_idx = 1:K
        % Extract a block from the signal
        start_idx = (block_idx-1) * num_elements_per_block + 1;
        end_idx = start_idx + num_elements_per_block - 1;
        block = equalized_serial(start_idx:end_idx);

        % Remove the first subcarrier (DC) and the symmetrical parts
        block_no_hermitian = block(2:Nc_half);  % Keep only the non-symmetrical part

        % Add this processed block to the final signal without symmetry
        equalized_serial_no_hermitian = [equalized_serial_no_hermitian; block_no_hermitian];
    end

    % Now the data is equalized and the Hermitian symmetry is removed, all in series


    % Demodulate using custom M-QAM demodulation (demodulate_MQAM_with_closest)
    [demodulated_bits, closest_points] = demodulate_MQAM_with_closest(equalized_serial_no_hermitian, mPoints, mLabels);

    % Ensure the number of demodulated bits matches the original number of bits
    demodulated_bits = demodulated_bits(1:num_bits);  % Trim if necessary

    % Calculate BER and SER
    num_bit_errors = sum(bits ~= demodulated_bits);
    BER = num_bit_errors / num_bits;

    some_threshold = 1e-3;
    num_symbol_errors = sum(abs(symbols - closest_points) > some_threshold);
    SER = num_symbol_errors / ((K * Ns) * log2(M));
end

