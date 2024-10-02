% Serial to Parallel Conversion
function parallel_data = serial_to_parallel(serial_data, Nc)
    % Converts serial data into parallel blocks of size Nc
    parallel_data = reshape(serial_data, Nc, []);  % Nc rows, dynamic columns
    disp(parallel_data(1:10)')
end
