clear all
clc
%%%%%%%%%%%%%%%%%%%% initializations Task 1 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
block_len = 16; % Length of an AES block in bytes
key_ascii1 = 'This is just fun'; % Key 1 (16-byte)
key_ascii2 = 'Isoloveblueskies'; % Key 2 (16-byte)
key1 = double(key_ascii1); % Convert to numeric
key2 = double(key_ascii2); % Convert to numeric
key_nonce_ascii = 'Have you secrets'; % Key to encrypt the nonce
key_nonce = double(key_nonce_ascii); % Convert from ASCII format to numeric
nonce = [54,50,55,49,52,48,54,50,53,48,48,48,48,48,48,48]; % Fixed nonce
IV = cipher(nonce, key_nonce); % Generate the IV
padded_plaintext = []; % Initialization
ciphertext = []; % Initialization
plaintext_ascii = 'embezzled pizzalike buzzwords';

%%%%%%%%%%%%%%%%%%%%%%%% Add padding (Task 1) %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
len = length(plaintext_ascii); % Length of the plaintext
pad_len = block_len - rem(len, block_len); % Length of padding in bytes
padded_plaintext = double([plaintext_ascii, repmat(pad_len, 1, pad_len)]); % Apply padding
num_chain = length(padded_plaintext) / block_len; % Number of blocks

% CBC Encryption (Task 1)
previous_block = IV;
for i = 1:num_chain
    Start = (i-1) * block_len + 1;
    End = Start + block_len - 1;
    current_block = padded_plaintext(Start:End); % Current plaintext block
    xor_block = bitxor(current_block, previous_block); % XOR with previous block (or IV)
    encrypted_block = cipher(xor_block, key1); % Encrypt with key1
    ciphertext = [ciphertext, encrypted_block]; % Append encrypted block
    previous_block = encrypted_block; % Update previous block
end

% Display ciphertext
disp('Generated Ciphertext from Task 1:');
disp(ciphertext);

%%%%%%%%%%%%%%%%%%%% CBC-MAC on the Ciphertext %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
key1_mac = double('ThisIsASecretKey'); % Key 1 for intermediate CBC encryption (MAC)
key2_mac = double('AnotherSecretKey'); % Key 2 for final MAC generation (MAC)

% Pad the ciphertext as done in Task 1
len_ciphertext = length(ciphertext); % Length of the ciphertext
pad_len_ciphertext = block_len - rem(len_ciphertext, block_len); % Length of padding for MAC
padded_ciphertext = [ciphertext, repmat(pad_len_ciphertext, 1, pad_len_ciphertext)]; % Apply padding

% Length of the CBC chain (number of blocks)
num_chain_ciphertext = length(padded_ciphertext) / block_len;

% CBC-MAC Computation on the ciphertext
IV_mac = zeros(1, block_len); % Start with an IV of zeros for CBC-MAC
previous_block_mac = IV_mac; % Initialize previous block with IV

for i = 1:num_chain_ciphertext
    Start = (i-1) * block_len + 1;
    End = Start + block_len - 1;
    current_block_mac = padded_ciphertext(Start:End); % Extract block of ciphertext
    xor_block_mac = bitxor(current_block_mac, previous_block_mac); % XOR with previous block
    encrypted_block_mac = cipher(xor_block_mac, key1_mac); % Encrypt with key1 (MAC)
    previous_block_mac = encrypted_block_mac; % Update for next round
end

% Final MAC generation step: Encrypt the last encrypted block with key2
tag_mac = cipher(previous_block_mac, key2_mac); % Final encryption for CBC-MAC

% Display the generated MAC
disp('Generated CBC-MAC Tag for the Ciphertext:');
disp(tag_mac);
