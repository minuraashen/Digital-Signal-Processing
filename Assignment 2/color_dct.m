% Load color image
img = imread("Sunrise.bmp");
img = im2double(img);  % Convert to [0,1]
[M, N, C] = size(img);

block_size = 8;
Q_standard = [16 11 10 16 24 40 51 61;
              12 12 14 19 26 58 60 55;
              14 13 16 24 40 57 69 56;
              14 17 22 29 51 87 80 62;
              18 22 37 56 68 109 103 77;
              24 35 55 64 81 104 113 92;
              49 64 78 87 103 121 120 101;
              72 92 95 98 112 100 103 99];

Q_levels = [90, 35, 5]; % Example quality

% Pad image so dimensions are multiples of 8
pad_M = mod(8 - mod(M,8), 8);
pad_N = mod(8 - mod(N,8), 8);

img_padded = padarray(img, [pad_M, pad_N], 'replicate', 'post');
[M_pad, N_pad, ~] = size(img_padded);

% Display
figure;
imshow(uint8(img*255));
title('Original Color Image');


for q=1:length(Q_levels)
    Q_level = Q_levels(q);
    Q_scaled = scale_q_matrix(Q_standard, Q_level);

    recon_img = zeros(M_pad, N_pad, C);

    for c = 1:C
        channel = img_padded(:,:,c) * 255;  % scale to 0–255
        
        row_blocks = repmat(block_size, 1, M_pad/block_size);
        col_blocks = repmat(block_size, 1, N_pad/block_size);
        blocks = mat2cell(channel, row_blocks, col_blocks);
        
        dct_blocks = cell(size(blocks));
        quant_blocks = cell(size(blocks));
        
        % DCT + Quantization
        for i = 1:size(blocks,1)
            for j = 1:size(blocks,2)
                block = double(blocks{i,j}) - 128;
                dct_block = dct2(block);
                quant_blocks{i,j} = round(dct_block ./ Q_scaled);
            end
        end
        disp('done...')
        
        % Dequantization + IDCT
        for i = 1:size(quant_blocks,1)
            for j = 1:size(quant_blocks,2)
                dequant_block = quant_blocks{i,j} .* Q_scaled;
                recon_block = idct2(dequant_block) + 128;
                row_start = (i-1)*block_size + 1;
                col_start = (j-1)*block_size + 1;
                recon_img(row_start:row_start+block_size-1, ...
                          col_start:col_start+block_size-1, c) = recon_block;
            end
        end
        disp('done...')
    end
    
    % Remove padding
    recon_img = recon_img(1:M, 1:N, :);
    
    % Clip to 0-255 and convert to uint8
    recon_img = uint8(max(min(recon_img,255),0));
    
    figure;
    imshow(recon_img);
    title(sprintf('Reconstructed (Q=%d)', Q_level));
    
    % Save result
    imwrite(recon_img, sprintf('compressed_color_Q%d.png', Q_level));
end



%% Function
function Q_scaled = scale_q_matrix(Q_standard, quality)
    if quality < 50
        scale = 50 / quality;
    else
        scale = (100 - quality) / 50;
    end
    Q_scaled = round(Q_standard * scale);
    Q_scaled(Q_scaled > 255) = 255;
end
