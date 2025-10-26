% Display All images
% image_files = {'images/barbara.mat','images/boats.mat', ...
% 'images/cameraman.mat','images/fingerprint.mat', ...
% 'images/flinstones.mat','images/foreman.mat','images/house.mat', ...
% 'images/lena.mat','images/Monarch.mat','images/Parrots.mat', ...
% 'images/peppers.mat'};
% 
% num_images = length(image_files);
% 
% for k = 1:num_images
%     data = load(image_files{k});
%     var_name = fieldnames(data);
%     img = data.(var_name{1});
%     figure;
%     imshow(img, []);
%     title(var_name{1}, 'Interpreter', 'none'); 
% end

% % images to use given in the assignment
% monarch_img_mat = load('');
% cameraman_img_mat = load('t');
% parrots_img_mat = load('');
% 
% monarch_img_var = fieldnames(monarch_img_mat);
% cameraman_img_var = fieldnames(cameraman_img_mat);
% parrots_img_var = fieldnames(parrots_img_mat);
% 
% monarch_img = monarch_img_mat.(monarch_img_var{1});
% cameraman_img = cameraman_img_mat.(cameraman_img_var{1});
% parrots_img = parrots_img_mat.(parrots_img_var{1});

images = ["images/Monarch.mat", "images/cameraman.mat", "images/Parrots.mat", ... 
    "images/peppers.mat"];

image_names = ["monarch", "cameraman", "parrots", "peppers"];

for im = 1: length(images)
    % Load and read the image
    image_file = load(images(im));
    image_var = fieldnames(image_file);
    image = image_file.(image_var{1});

    % Define the block size
    block_size = 8;
    % Image height and width
    [M, N] = size(image);

    % Display the size of the image
    disp([M, N]);

    % Show the original image and save it as png
    figure;
    imshow(image, []);
    title(sprintf('Original Image %d: %s', im, image_names(im)));
    imwrite(uint8(mat2gray(image) * 255), ... 
        sprintf('%s_original.png', image_names(im)));

    % Divide the image into 8x8 blocks
    
    % Create row and column vectors for mat2cell
    row_blocks = repmat(block_size, 1, M/block_size);
    col_blocks = repmat(block_size, 1, N/block_size);

    % Split image into 8x8 blocks
    blocks = mat2cell(image, row_blocks, col_blocks);

    dct_blocks = cell(size(blocks));  % same size as blocks

    % Apply DCT for each block
    for i = 1:size(blocks,1)
        for j = 1:size(blocks,2)
            % Convert block to double and shift values to [-128,127]
            block = double(blocks{i,j}) - 128;
            % Apply 2D DCT
            dct_blocks{i,j} = dct2(block);
        end
    end

    % Quantization matrix eoth quality level 50
    Q_standard = [16 11 10 16 24  40  51  61;
                 12 12 14 19 26  58  60  55;
                 14 13 16 24 40  57  69  56;
                 14 17 22 29 51  87  80  62;
                 18 22 37 56 68 109 103  77;
                 24 35 55 64 81 104 113  92;
                 49 64 78 87 103 121 120 101;
                 72 92 95 98 112 100 103  99];
    
    % Quality levels
    Q_levels = [90, 35, 5];
    for q=1:length(Q_levels)
        % Create Quantization matrix for desired quality level
        Q_scaled = scale_q_matrix(Q_standard, Q_levels(q));

        % Quantization
        quant_blocks = cell(size(dct_blocks));
        for i = 1:size(dct_blocks,1)
            for j = 1:size(dct_blocks,2)
                quant_blocks{i,j} = round(dct_blocks{i,j} ./ Q_scaled);
            end
        end

        % Reconstruction of compressed image
        recon_img = zeros(M,N);

        for i = 1:size(quant_blocks,1)
            for j = 1:size(quant_blocks,2)
                % Dequantization
                dequant_block = quant_blocks{i,j} .* Q_scaled;
                % Inverse DCT
                recon_block = idct2(dequant_block);
                % Recombine into final image
                row_start = (i-1)*block_size + 1;
                col_start = (j-1)*block_size + 1;
                recon_img(row_start:row_start+block_size-1, ... 
                    col_start:col_start+block_size-1) = recon_block + 128;
            end
        end
        
        % Show the reconstructed image and save it
        figure;
        imshow(recon_img, []);
        title(sprintf('Reconstructed Image %s - Q %d', ... 
                image_names(im), Q_levels(q)));
        % Create output folder if missing
        imwrite(uint8(mat2gray(recon_img) * 255), ...
                sprintf('reconstructed_%s_Q%d.png', image_names(im), Q_levels(q)));
    end
end




%% Function for calculating quantization matrix for specific quality 
function Q_scaled = scale_q_matrix(Q_standard, quality)
    if quality < 50
        scale = 50 / quality;
    else
        scale = (100 - quality) / 50;
    end
    % rounding and clipping the values above 255
    Q_scaled = round(scale * Q_standard);
    Q_scaled(Q_scaled > 255) = 255;
end

% [num_rows, num_cols] = size(quant_blocks);
% [M, N] = deal(num_rows * block_size, num_cols * block_size);
% quantized_img = zeros(M, N);
% 
% for i = 1:num_rows
%     for j = 1:num_cols
%         quantized_img((i-1)*block_size+1:i*block_size, ...
%                       (j-1)*block_size+1:j*block_size) = quant_blocks{i,j};
%     end
% end

% figure;
% imshow(log(abs(quantized_img) + 1), []);
% title('Quantized DCT Coefficients');























