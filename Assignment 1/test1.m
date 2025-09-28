% ----- Parameters -----
fs = 128;                % sampling rate (Hz)
% load your signal variable (replace with actual file/variable name)
% e.g. load('xn_test_index.mat');   % produces variable xn_test
x = xn_test(:);          % column vector
N = length(x);           % expected 1793

% Short subsets S1..S5
S1 = x(1:128);
S2 = x(1:256);
S3 = x(1:512);
S4 = x(1:1024);
% For S5 use 1792 (drop 1 sample so it's divisible by 128)
S5 = x(1:1792);

% Example: plot S1 and S4
figure;
subplot(2,1,1); plot_dft_segment(S1, fs, 'S1 (first 128 samples)');
subplot(2,1,2); plot_dft_segment(S4, fs, 'S4 (first 1024 samples)');

% Function to compute & plot magnitude
% function plot_dft_segment(xseg, fs, titleStr)
%   K = length(xseg);
%   X = fft(xseg);
%   mag = abs(X)/K;                        % normalize amplitude (optional)
%   f = (0:K-1)*(fs/K);
%   plot(f(1:floor(K/2)+1), mag(1:floor(K/2)+1));
%   xlabel('Frequency (Hz)'); ylabel('|X(k)| (normalized)');
%   title(titleStr); grid on;
% end











