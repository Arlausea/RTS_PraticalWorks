% Parallel to Serial Conversion
function serial_data = parallel_to_serial(parallel_data)
    % Converts parallel data back to serial form
    serial_data = reshape(parallel_data, Nc, []);
end
