%load the signal and plot the original signal
load('signal551.mat','xn_test');
my_signal = xn_test(:);
signal_length = length(my_signal);
stem(my_signal, 'filled');
xlabel('n');
ylabel('x551[n]');
title('Plot of the original signal');

fs = 128;  %sampling rate is 128Hz
time = 14;   %samples were collected over a 14s time
no_of_samples = time*fs;
fprintf('Number of samples of the signal: %d\n', no_of_samples);

%making the subsets of the given signal 
S1 = my_signal(1:128);
S2 = my_signal(1:256);
S3 = my_signal(1:512);
S4 = my_signal(1:1024);
S5 = my_signal(1:1792);

subsets = {S1, S2, S3, S4, S5};

plot each subset
for s=1:length(subsets)
    figure;
    stem(subsets{s}, 'filled');
    xlabel('n');
    xlim([0 length(subsets{s})])
    ylabel('Amplitude');
    title(sprintf('Subset %d', s));
end

for s=1:length(subsets)
    dft_signal = fft(subsets{s});
    mag_dft = abs(dft_signal); 
    figure;
    stem(mag_dft, 'filled');
    xlabel('k');
    xlim([0 length(subsets{s})]);
    ylabel('Magnitude');
    title(sprintf('DFT of Subset %d', s));
end

for s=1:length(subsets)
    K = length(subsets{s});
    dft_signal = fft(subsets{s});
    mag_dft = abs(dft_signal);
    freq = (0:K-1)*(fs/K);
    figure;
    plot(freq(1:floor(K/2)+1), mag_dft(1:floor(K/2)+1));
    xlabel('k');
    xlim([0 max(freq)/2]);
    ylabel('Magnitude');
    title(sprintf('DFT of Subset %d', s));
end


DFT averaging
K = 128;
L = 14;

start_i = 1;
end_i = K;

X_sum = zeros(1,K);

% Apply DFT to each subset
for n=1:L
    subset = xn_test(start_i: end_i);
    subset_dft = fft(subset, K);
    % Update X_sum
    X_sum = X_sum + subset_dft;
    % Update indices
    start_i = end_i + 1;
    end_i = end_i + K;
end

X_a = abs(X_sum) / L;
disp(X_a)

f = (0:K-1)*(fs/K);

figure; plot(f(1:K/2+1), X_a(1:K/2+1));
xlabel('Frequency (Hz)'); ylabel('|X_{avg}|');
xlim([0 64]);
title('Averaged DFT (K=128, L=14)'); grid on;

figure; stem(f(1:K/2+1), X_a(1:K/2+1), 'filled');
xlabel('Frequency (Hz)'); ylabel('|X_{avg}|');
xlim([0 64])
title('Averaged DFT (K=128, L=14)'); grid on;


% Find minimum L
L_vals = 1:14;

for L=L_vals
    fprintf('L =  %d\n', L);
    K = floor(length(xn_test)/L);
    fprintf('K =  %d\n', K);
    start_index = 1;
    end_index = K;
    samples_count = K*L;
    fprintf('No of samples: %d\n', samples_count)


    X_sum = zeros(1,K);
    % DFT averaging for each iteration
    for n=1:L
        subset = xn_test(start_index:end_index);
        dft = fft(subset, K);
        %Update X_sum 
        X_sum = X_sum + dft;
        %Update indices
        start_index = end_index + 1;
        end_index = end_index + K;
    end

    X_a = abs(X_sum) / L;

    f = (0:K-1)*(fs/K);

    figure; 
    plot(f(1:floor(K/2)+1), X_a(1:floor(K/2)+1));
    xlabel('Frequency (Hz)'); ylabel('|X_{avg}|');
    xlim([0 64]);
    title(sprintf('Averaged DFT K = %d, L = %d)', K, L)); grid on;

    figure; 
    stem(f(1:floor(K/2)+1), X_a(1:floor(K/2)+1), 'filled');
    xlabel('Frequency (Hz)'); ylabel('|X_{avg}|');
    xlim([0 64])
    title(sprintf('Averaged DFT K = %d, L = %d)', K, L)); grid on;

end






