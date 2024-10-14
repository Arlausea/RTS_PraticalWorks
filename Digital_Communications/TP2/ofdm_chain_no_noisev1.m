function [BER, SER] = ofdm_chain_no_noisev1(Nc, h, Npr, M, K, mPoints, mLabels, g0)
% Simulates OFDM communication chain without additive noise.
% Nc: number of subcarriers
% h: channel impulse response
% Npr: cyclic prefix length
% M: M-QAM modulation order
% K: number of OFDM blocks
% mPoints: M-QAM constellation points
% mLabels: Gray labels for M-QAM
% g0: Gain for M-QAM modulation

Ns = (Nc / 2) - 1; % Number of QAM symbols per block
bits_per_symbol = log2(M); % Number of bits per QAM symbol

% Generate random bits
num_bits = Ns * bits_per_symbol; %Add k
bits = randi([0 1], Nc, num_bits);
disp(['Size of bits: ', num2str(size(bits))]);
bits3 = zeros(Nc,Ns);
for i = 1:Nc
    q=bits(i,:);
    a=reshape(q,[], Ns)';
    % disp(a);
    bits3(i,:)=bi2de(a,bits_per_symbol,'left-msb');
end
bits3
% Modulate using custom M-QAM modulation (modulate_MQAM)
symbols = zeros(Nc,Ns);
for k=1:Nc
    symbols(k,:)=modulate_MQAM(bits(k,:),mPoints,mLabels,M,g0);

end
% symbols = modulate_MQAM(bits3, mPoints, mLabels, M, g0)

% Apply Hermitian Symmetry directly on the serial symbols
hermitian_symbols_serial = zeros(Nc , 2*Ns+2);
symbol_idx = 1;

for k = 1:Nc
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
hermitian_symbols_parallel = reshape(hermitian_symbols_serial, Nc, []);

% Apply IFFT
time_domain_data = apply_ifft(hermitian_symbols_parallel);
disp('Time domain data (first OFDM block):');
disp(time_domain_data(:, 1)); % Display the first OFDM block post IFFT

% Add Cyclic Prefix
time_domain_with_cp = add_cyclic_prefix(time_domain_data, Npr);
disp('Time domain data with CP (first OFDM block):');
disp(time_domain_with_cp(:, 1)); % Display the first OFDM block after adding cyclic prefix

% Channel Filtering (no noise)
received_with_cp = zeros(size(time_domain_with_cp)); % Initialize received_with_cp
for k = 1:Nc
    received_with_cp(:, k) = conv(time_domain_with_cp(:, k), h(:), 'same'); % Ensure full block filtering
end
disp('Received with cyclic prefix (first OFDM block):');
% received_with_cp=received_with_cp(1:Nc+Npr);
disp(received_with_cp(:, 1)); % Display the first OFDM block after channel filtering

% Remove Cyclic Prefix
received_no_cp = remove_cyclic_prefix(received_with_cp, Npr);
disp('Received no cyclic prefix (first OFDM block):');
disp(received_no_cp(:, 1)); % Display the first OFDM block after removing the cyclic prefix

% Apply FFT
received_freq_domain = fft(received_no_cp, Nc, 1); % FFT across each OFDM block
disp('Received frequency domain data (first OFDM block):');
disp(received_freq_domain(:, 1)); % Display the first OFDM block post FFT
disp(['Size of received_freq_domain: ', num2str(size(received_freq_domain))]);

% Convert received data from frequency domain from parallel to serial
received_serial = reshape(received_freq_domain, Nc, []); % Convert the received data to serial
disp(['Size of received_serial: ', num2str(size(received_serial))]);

% Apply Zero Forcing equalization directly on the serial data
H = fft(h, Nc);
% H_serial = repmat(H.', 1, Nc) % Extend the channel response to match all serial data
equalized_serial = received_serial ./ H; % Zero Forcing Equalization


% Remove Hermitian symmetry directly from the serial data
Nc_half = (Nc / 2); % Nc/2 corresponds to the Hermitian part of the data
num_elements_per_block = Nc; % Number of elements per block

% Remove the elements corresponding to the Hermitian symmetry
equalized_serial_no_hermitian = []; % Initialize an empty vector to store data without Hermitian part
for block_idx = 1:Nc
    % Extract a block of the signal
    start_idx = (block_idx-1) * num_elements_per_block + 1;
    end_idx = start_idx + num_elements_per_block - 1;
    block = equalized_serial(start_idx:end_idx);
    % Remove the first subcarrier (DC) and symmetric parts
    block_no_hermitian = block(2:Nc_half); % Keep only the non-symmetric part
    % Add this processed block to the final signal without symmetry
    equalized_serial_no_hermitian = [equalized_serial_no_hermitian; block_no_hermitian];
end


% Now the data is equalized and the Hermitian symmetry is removed, all in serial
% Demodulate using custom M-QAM demodulation (demodulate_MQAM_with_closest)
[demodulated_bits, closest_points] = demodulate_MQAM_with_closest(equalized_serial_no_hermitian, mPoints, mLabels);

% Ensure the number of demodulated bits matches the original number of bits
demodulated_bits = demodulated_bits(1:num_bits); % Trim if necessary

% Calculate BER and SER
num_bit_errors = sum(bits ~= demodulated_bits);
BER = num_bit_errors / num_bits;
some_threshold = 1e-3;
num_symbol_errors = sum(abs(symbols - closest_points) > some_threshold);
SER = num_symbol_errors / ((K * Ns) * log2(M));

end