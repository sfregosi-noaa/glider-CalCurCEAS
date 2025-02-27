% plot system sensitivity


figure(8);
clf
hold on;

plot(frqSys, hydFilt + hydSens, 'ro--', 'DisplayName', 'Hydrophone Sensitivity');
plot(frqSys, paGain, 'bo--', 'DisplayName', 'Pre-amp gain');
plot(frqSys, antiAli, 'go--', 'DisplayName', 'Anti-aliasing filter')
plot(frqSys, sysSens, 'ks-', 'LineWidth', 2, 'DisplayName', 'System response');
xline(62500, 'k-.', 'DisplayName', 'Upper limit for valid data');

set(gca, 'XScale', 'log');
grid on;
xlabel('sensitivity [dB]');
ylabel('frequency [Hz]');
xlim([0 max(frqSys)]);
legend('Location', 'west');