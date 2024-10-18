clear all
clc
%%%%%%%%%%%%%%%%%%%% initializations %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
key1 = 'ThisIsASecretKey';
key2 = 'AnotherSecretKey'; 
message = 'This is a four block message';
block_len = 16;
IV = zeros(1, block_len);

previous_block=IV; % Start with IV = 0 for CBC-MAC
for i = 1:num_chain
    Start=(i-1)*block_len+1;
    End= Start+block_len-1;
    current_block = padded_plaintext(Start:End);
    xor= bitxor(current_block, previous_block);
    encrypted = cipher(xor, key1); % Encrypt with key1
    previous_block=encrypted;
end

tag=cipher(previous_block,key2);% Encrypt with key2


