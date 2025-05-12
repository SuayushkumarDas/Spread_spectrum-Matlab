clc;
clear all;
close all;

%——— Input ———%
input_data = input('Enter the binary bit vector (e.g. [1 0 1 1 0]): ');
N = length(input_data);

%——— BPSK Mapping ———%
bpsk_data = 2*input_data - 1;    % 0→−1, 1→+1

%——— PN Spreading ———%
pn_length = 5;                    
pn_seq = randi([0 1],1,pn_length);
pn_seq = 2*pn_seq - 1;           % 0→−1, 1→+1
spread_data = reshape(repmat(bpsk_data, pn_length, 1), 1, []);

%——— AWGN Channel ———%
snr = 10;                      
rx = awgn(spread_data, snr, 'measured');

%——— Despreading & Decision ———%
recovered_bits = zeros(1, N);
for i = 1:N
    segment = rx((i-1)*pn_length+1 : i*pn_length);
    metric  = sum(segment .* pn_seq);
    recovered_bits(i) = metric > 0;
end

%——— Results ———%
num_errors = sum(input_data ~= recovered_bits);
fprintf('Bit Errors: %d out of %d bits (BER = %.2e)\n', ...
        num_errors, N, num_errors/N);

%——— Plotting ———%
figure('Color','w','Position',[100 100 600 900]);

% 1) Original Input Bits
subplot(6,1,1);
stem(1:N, input_data, 'filled');
title('1. Input Bits','FontWeight','bold');
ylim([-0.2 1.2]);
grid on;

% 2) BPSK Mapping
subplot(6,1,2);
stem(1:N, bpsk_data, 'filled');
title('2. BPSK Mapping (−1 / +1)','FontWeight','bold');
ylim([-1.2 1.2]);
grid on;

% 3) PN Sequence
subplot(6,1,3);
stem(1:pn_length, pn_seq, 'filled');
title('3. PN Spreading Sequence','FontWeight','bold');
ylim([-1.2 1.2]);
grid on;

% 4) Transmitted (Spread) Signal
subplot(6,1,4);
plot(spread_data, 'o-','LineWidth',1);
title('4. Transmitted Spread Signal','FontWeight','bold');
ylim([-1.2 1.2]);
grid on;

% 5) Received Noisy Signal
subplot(6,1,5);
plot(rx, '.-','LineWidth',1);
title(sprintf('5. Received Signal (AWGN, SNR = %d dB)', snr),'FontWeight','bold');
ylim([-1.2 1.2]);
grid on;

% 6) Recovered Bits vs. Original
subplot(6,1,6);
stem(1:N, input_data, 'b','filled','DisplayName','Original'); 
hold on;
stem(1:N, recovered_bits, 'r--o','DisplayName','Recovered');
title('6. Original vs. Recovered Bits','FontWeight','bold');
ylim([-0.2 1.2]);
legend('Location','Best');
grid on;
xlabel('Index');
