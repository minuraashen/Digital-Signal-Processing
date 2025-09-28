% Interpolation using DFT-based method
clc; clear; close all;

% Load the Handel signal
load handel;   
N = 20000;  

x = y(1:N);
x2 = x(1:2:N);
x3 = x(1:3:N);
x4 = x(1:4:N);

% Interpolation of x2 with K=1
x2_interp = dft_interpolate(x2, 2, N);  % x2 is downsampled by 2 → interpolate by 2
err2 = norm(x - x2_interp, 2);          % 2-norm error
fprintf("2-norm error for x2 interpolation = %.4f\n", err2);

figure;
stem(1:50, x(1:50), 'filled', 'LineWidth', 1.2); hold on;
stem(1:50, x2_interp(1:50), 'filled', 'red', 'LineWidth', 1.2);
legend('Original x', 'Interpolated x2');
title('Interpolation of x2 (first 50 samples)');

% Interpolation of x3 with K=2
x3_interp = dft_interpolate(x3, 3, N);  % interpolate by 3
err3 = norm(x - x3_interp, 2);
fprintf("2-norm error for x3 interpolation = %.4f\n", err3);

figure;
stem(1:50, x(1:50), 'filled', 'LineWidth', 1.2); hold on;
stem(1:50, x3_interp(1:50), 'filled', 'red', 'LineWidth', 1.2);
legend('Original x', 'Interpolated x3');
title('Interpolation of x3 (first 50 samples)');

% Interpolation of x4 with K=3
x4_interp = dft_interpolate(x4, 4, N);  % interpolate by 4
err4 = norm(x - x4_interp, 2);
fprintf("2-norm error for x4 interpolation = %.4f\n", err4);

figure;
stem(1:50, x(1:50), 'filled', 'LineWidth', 1.2); hold on;
stem(1:50, x4_interp(1:50), 'filled', 'red', 'LineWidth', 1.2);
legend('Original x', 'Interpolated x4');
title('Interpolation of x4 (first 50 samples)');

% Function: DFT-based interpolation
% x_down : downsampled signal
% K      : interpolation factor
% N_full : original signal length
function x_interp = dft_interpolate(x_down, K, N_full)
    M = length(x_down);          % length of downsampled signal
    % Take DFT of downsampled signal
    X = fft(x_down);
    
    % Zero-padding in frequency domain
    if mod(M,2) == 0
        % Even-length
        Xzp = [X(1:M/2); zeros((K-1)*M,1); X(M/2+1:end)];
    else
        % Odd-length
        Xzp = [X(1:(M+1)/2); zeros((K-1)*M,1); X((M+1)/2+1:end)];
    end
    
    % Inverse DFT to get interpolated signal
    x_interp = real(ifft(Xzp))*K;
    
    % Trim or pad to match original length
    if length(x_interp) > N_full
        x_interp = x_interp(1:N_full);
    else
        x_interp = [x_interp; zeros(N_full-length(x_interp),1)];
    end
end

