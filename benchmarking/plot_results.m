%%
close
figure('pos',[2000 100 1600 900],'color','k')
vals = {'8','12','0'};
for i = 1:length(vals)

t = tic; load(['./' vals{i} '/test_4.mat']); fprintf('Loaded in %1.2f seconds.\n',toc(t))
s0 = subplot(4,length(vals),i);
imagesc(sim.grid_vars.z_axis*1e3,sim.grid_vars.y_axis*1e3,sim.field_maps.cmap)
s0.FontSize = 14; s0.Color = 'k'; s0.YColor = 'w'; s0.XColor = 'w'; s0.TickLength = [0 0];
ylabel('Azimuth (mm)')
xlabel('Depth (mm)')
title(vals{i},'fontsize',16,'color','w')
drawnow

s1 = subplot(4,length(vals),length(vals)+i);
rf = sum(rf_focused(:,sim.xdc.on_elements),2); rf = rf/max(rf); plot(z*1e3,rf,'linewidth',1,'color',cool(1)); hold on
env = abs(hilbert(rf)); env = env/max(env); plot(z*1e3,env,'linewidth',1.5,'color',autumn(1)); hold on
axis tight
xlim([0 max(sim.grid_vars.z_axis)*1e3])
s1.FontSize = 14; s1.Color = 'k'; s1.YColor = 'w'; s1.XColor = 'w'; s1.TickLength = [0 0];
drawnow

s2 = subplot(4,length(vals),length(vals)*2+i);
envdb = db(env);
plot(z*1e3,envdb,'linewidth',1.5,'color',autumn(1))
axis tight
xlim([0 max(sim.grid_vars.z_axis)*1e3])
ylim([-80 0])
s2.FontSize = 14; s2.Color = 'k'; s2.YColor = 'w'; s2.XColor = 'w'; s2.TickLength = [0 0];
drawnow

s3 = subplot(4,length(vals),length(vals)*3+i);
a(1) = mean(envdb(z>0.035&z<0.045));
a(2) = mean(envdb(z>0.045&z<0.055));
a(3) = mean(envdb(z>0.055&z<0.065));
names = categorical({'4 cm','5 cm','6 cm'});
bar(names,a,'facecolor',autumn(1))
text(1:length(a),double(a),num2str(round(a)'),'vert','bottom','horiz','center','fontsize',14,'color','w'); 
ylim([-80 0])
s3.FontSize = 14; s3.Color = 'k'; s3.YColor = 'w'; s3.XColor = 'w'; s3.TickLength = [0 0];
drawnow

end

set(gcf, 'invertHardcopy', 'off');

%%
t = tic; load('./12/test_1.mat'); fprintf('Loaded in %1.2f seconds.\n',toc(t))
s0 = subplot(422);
imagesc(sim.grid_vars.z_axis*1e3,sim.grid_vars.y_axis*1e3,sim.field_maps.cmap)
s0.FontSize = 14; s0.Color = 'k'; s0.YColor = 'w'; s0.XColor = 'w'; s0.TickLength = [0 0];
ylabel('Azimuth (mm)')
xlabel('Depth (mm)')
title('ppw/12','fontsize',16,'color','w')

s1 = subplot(424);
rf = sum(rf_focused(:,sim.xdc.on_elements),2); rf = rf/max(rf); plot(z*1e3,rf,'linewidth',1.5,'color',cool(1)); hold on
env = abs(hilbert(rf)); env = env/max(env); plot(z*1e3,env,'linewidth',1.5,'color',autumn(1)); hold on
axis tight
xlim([0 max(sim.grid_vars.z_axis)*1e3])
s1.FontSize = 14; s1.Color = 'k'; s1.YColor = 'w'; s1.XColor = 'w'; s1.TickLength = [0 0];

s2 = subplot(426);
envdb = db(env);
plot(z*1e3,envdb,'linewidth',1.5,'color',autumn(1))
axis tight
xlim([0 max(sim.grid_vars.z_axis)*1e3])
ylim([-80 0])
s2.FontSize = 14; s2.Color = 'k'; s2.YColor = 'w'; s2.XColor = 'w'; s2.TickLength = [0 0];

s3 = subplot(428);
a(1) = mean(envdb(z>0.035&z<0.045));
a(2) = mean(envdb(z>0.045&z<0.055));
a(3) = mean(envdb(z>0.055&z<0.065));
names = categorical({'4 cm','5 cm','6 cm'});
bar(names,a,'facecolor',autumn(1))
text(1:length(a),double(a),num2str(round(a)'),'vert','bottom','horiz','center','fontsize',14,'color','w'); 
ylim([-80 0])
s3.FontSize = 14; s3.Color = 'k'; s3.YColor = 'w'; s3.XColor = 'w'; s3.TickLength = [0 0];