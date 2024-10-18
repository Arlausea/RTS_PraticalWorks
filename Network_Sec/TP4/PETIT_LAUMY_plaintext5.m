clear all
clc
%%%%%%%%%%%%%%%%%%%% initializations %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
block_len = 16; % Length of an AES block in bytes
key_ascii1 = 'This is just fun'; % Key 1 (16-byte) for encryption
key_ascii2 = 'Isoloveblueskies'; % Key 2 (16-byte) for final MAC
key1 = double(key_ascii1); % Convert to numeric
key2 = double(key_ascii2); % Convert to numeric

plaintext_ascii = 'embezzled pizzalike buzzwords'; % Original plaintext

%%%%%%%%%%%%%%%%%%%%%%%% Add padding to the plaintext %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
len = length(plaintext_ascii); % Length of the plaintext
pad_len = block_len - rem(len, block_len); % Length of padding in bytes
padded_plaintext = double([plaintext_ascii, repmat(pad_len, 1, pad_len)]); % Apply padding
num_chain = length(padded_plaintext) / block_len; % Number of blocks

%%%%%%%%%%%%%%%%%%%% CBC-MAC on the Plaintext %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
key1_mac = double('ThisIsASecretKey'); % Key 1 for intermediate CBC encryption (MAC)
key2_mac = double('AnotherSecretKey'); % Key 2 for final MAC generation (MAC)

% Length of the CBC chain (number of blocks)
num_chain_plaintext = length(padded_plaintext) / block_len;

% CBC-MAC Computation on the original plaintext
IV_mac = zeros(1, block_len); % Start with an IV of zeros for CBC-MAC
previous_block_mac = IV_mac; % Initialize previous block with IV

for i = 1:num_chain_plaintext
    Start = (i-1) * block_len + 1;
    End = Start + block_len - 1;
    current_block_mac = padded_plaintext(Start:End); % Extract block of plaintext
    xor_block_mac = bitxor(current_block_mac, previous_block_mac); % XOR with previous block
    encrypted_block_mac = cipher(xor_block_mac, key1_mac); % Encrypt with key1 (MAC)
    previous_block_mac = encrypted_block_mac; % Update for next round
end

% Final MAC generation step: Encrypt the last encrypted block with key2
tag_mac_plaintext = cipher(previous_block_mac, key2_mac); % Final encryption for CBC-MAC

% Display the MAC tag for the plaintext
disp('Generated CBC-MAC Tag for the Original Plaintext:');
disp(tag_mac_plaintext);
