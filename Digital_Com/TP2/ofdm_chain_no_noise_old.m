% Main OFDM simulation with Hermitian symmetry, no noise (Checkpoint 1)
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

    % Serial to Parallel conversion
    symbols_parallel = serial_to_parallel(symbols, Ns);

    % Apply Hermitian Symmetry
    hermitian_symbols = zeros(Nc, K);
    for k = 1:K
        hermitian_symbols(:, k) = apply_hermitian_symmetry(symbols_parallel(:, k), Ns);
    end

    % Print first 10 values of the first OFDM block after Hermitian symmetry
    disp('Hermitian Symmetric Vector (First 10 values of first OFDM block):');
    disp(hermitian_symbols(1:10, 1));  % Display first 10 values of the first block

    % Apply IFFT
    time_domain_data = apply_ifft(hermitian_symbols);

    % Add Cyclic Prefix
    time_domain_with_cp = add_cyclic_prefix(time_domain_data, Npr);

    % Channel Filtering (no noise)
    H = fft(h, Nc);
    received_with_cp = conv2(time_domain_with_cp, h(:), 'same');

    % Remove Cyclic Prefix
    received_no_cp = remove_cyclic_prefix(received_with_cp, Npr);

    % Apply FFT
    received_freq_domain = apply_fft(received_no_cp);

    % Equalization (Zero Forcing)
    equalized_data = received_freq_domain ./ H.';

    % Remove Hermitian symmetry and demodulate
    demod_symbols = equalized_data(2:Ns+1, :);

    % Parallel to Serial conversion
    received_serial = parallel_to_serial(demod_symbols);

    % Demodulate using custom M-QAM demodulation (demodulate_MQAM_with_closest)
    [demodulated_bits, closest_points] = demodulate_MQAM_with_closest(received_serial, mPoints, mLabels);

    % Ensure the number of demodulated bits matches the original number of bits
    demodulated_bits = demodulated_bits(1:num_bits);  % Trim if necessary

    % Calculate BER and SER
    num_bit_errors = sum(bits ~= demodulated_bits);
    BER = num_bit_errors / num_bits;

    some_threshold = 1e-3;
    num_symbol_errors = sum(abs(symbols - closest_points) > some_threshold);
    SER = num_symbol_errors / ((K * Ns)*log2(M));
    % Print original transmitted symbols
    disp('Original Symbols (First 10):');
    disp(symbols_parallel(:, 1));
    disp('Equalized Symbols (First 10):');
    disp(demod_symbols(1:10, 1));
end

