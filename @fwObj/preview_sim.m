function obj = preview_sim(obj)

close all
figure('pos',[100 100 1400 600])
subplot(131)
imagesc(obj.grid_vars.y_axis*1e3,obj.grid_vars.z_axis*1e3,obj.field_maps.cmap'); axis image
xlabel('Lateral (mm)'); ylabel('Axial (mm)'); title('Acoustic map');

subplot(232)
imagesc(obj.grid_vars.y_axis*1e3,obj.grid_vars.t_axis*1e6,obj.xdc.icmat(1:obj.grid_vars.nY,:)');
xlabel('Lateral (mm)'); ylabel('Time (us)'); title('Focused transmit'); ylim([0 20])

subplot(235)                                     
scatter(obj.xdc.on_elements,obj.xdc.delays*1e6,100,'.b'); axis tight
xlabel('Element number'); ylabel('Time (us)'); title('Focused delays')

subplot(233)
plot(obj.xdc.impulse_t*1e6,obj.xdc.impulse)
xlabel('Time (us)'); ylabel('Amplitude (a.u.)'); title('Impulse response')
axis tight

subplot(236)
plot(obj.xdc.pulse_t*1e6,obj.xdc.pulse)
xlabel('Time (us)'); ylabel('Amplitude (a.u.)'); title('Transmitted pulse')
axis tight

end