%%
close
figure('pos',[2000 100 800 900],'color','w')

s0 = subplot(311);
imagesc(sim.grid_vars.z_axis*1e3,sim.grid_vars.y_axis*1e3,sim.field_maps.cmap)
s0.FontSize = 14;
ylabel('Azimuth (mm)')
xlabel('Depth (mm)')
title(sprintf('f_{o} = %1.1f MHz',sim.input_vars.f0/1e6),'fontsize',16)

s1 = subplot(312);
rf = sum(rf_focused(:,sim.xdc.on_elements),2); rf = rf/max(rf); plot(z*1e3,rf,'-b','linewidth',1.5); hold on
env = abs(hilbert(rf)); env = env/max(env); plot(z*1e3,env,'-r','linewidth',1.5); hold on
axis tight
xlim([0 max(sim.grid_vars.z_axis)*1e3])
s1.FontSize = 14;
xlabel('Depth (mm)')

s2 = subplot(313);
envdb = db(env);
plot(z*1e3,envdb,'-b','linewidth',1.5)
axis tight
xlim([0 max(sim.grid_vars.z_axis)*1e3])
s2.FontSize = 14;
xlabel('Depth (mm)')