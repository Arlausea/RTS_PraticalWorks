clear all
clc
%%%%%%%%%%%%%%%%%%%% initializations %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
block_len=16; %length of an AES block in bytes
key_ascii1 = 'This is just fun'; % Key 1 (16-byte)
key_ascii2 = 'Isoloveblueskies'; % Key 2 (16-byte)
key1 = double(key_ascii1);
key2 = double(key_ascii2);
key_nonce_ascii='Have you secrets';%key to encrypt the nonce
key_nonce=double(key_nonce_ascii); %convert from ASCII format to double
nonce_ascii=num2str(cputime*1e14); %create a nonce as a counter
nonce=[54,50,55,49,52,48,54,50,53,48,48,48,48,48,48,48]; %convert nonce to double
IV = cipher(nonce, key_nonce); %generate the IV 
padded_plaintext=[]; %initialization
ciphertext=[]; %initialization
recovered_plaintext=[]; %initialization
plaintext_ascii='embezzled pizzalike buzzwords';
%%%%%%%%%%%%%%%%%%%%%%%% add padding %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
len=length(plaintext_ascii); %length of the plaintext
pad_len=16-rem(len, 16); %length of padding in bytes
%padded plaintext using the TLS convention
padded_plaintext=double([plaintext_ascii, repmat(pad_len,1, pad_len)]);
%length of the CBC chain
num_chain=length(padded_plaintext)/block_len;

% CBC Encryption
previous_block=IV;
for i = 1:num_chain
    Start=(i-1)*block_len+1;
    End= Start+block_len-1;
    current_block = padded_plaintext(Start:End);
    xor=bitxor(current_block,previous_block);
    encrypted_block=cipher(xor,key1);
    ciphertext = [ciphertext encrypted_block];
    previous_block=encrypted_block;
end

% CBC Decryption
previous_block=IV;
for i=1:num_chain
    Start=(i-1)*block_len+1;
    End= Start+block_len-1;
    current_block = ciphertext(Start:End);
    decrypt=inv_cipher(current_block,key1);
    xor=bitxor(decrypt,previous_block);
    recovered_plaintext = [recovered_plaintext xor];
    previous_block = current_block;
end

% Remove padding from the recovered plaintext
recovered_plaintext = recovered_plaintext(1:end-pad_len); % Remove padding
recovered_plaintext=char(recovered_plaintext);


% Display results
disp('Original plaintext:');
disp(plaintext_ascii);

disp('Padded plaintext:');
disp(char(padded_plaintext));

disp('Ciphertext:');
disp(ciphertext);

disp('Recovered plaintext:');
disp(recovered_plaintext);