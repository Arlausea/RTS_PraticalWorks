function a = apply_hermitian_symmetry(s, Ns)
    % Apply Hermitian symmetry to the QAM symbols
    % s: Vector of Ns M-QAM symbols
    % Ns: Number of M-QAM symbols
    % a: Vector to be input to the IFFT block (size Nc = 2Ns + 2)
    
    % Ensure that s is a row vector for correct concatenation
    if iscolumn(s)
        s = s.';  % Transpose to row vector
    end

    % Create the Hermitian symmetric vector a of size Nc = 2*Ns + 2
    a = [0, s, 0, fliplr(conj(s))];  % fliplr: flip left-right for conjugate symmetry
end

