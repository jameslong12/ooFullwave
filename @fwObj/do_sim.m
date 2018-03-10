function rf = do_sim(obj)

%  Method to call Fullwave executable and perform simulation
%
%  Calling:
%           rf = obj.do_sim()
%
%  James Long 03/10/2018

if ispc
    launchTotalFullWaveRebuild2(obj.input_vars.c0, obj.input_vars.omega0,...
        obj.input_vars.wY, obj.input_vars.wZ, obj.input_vars.td,...
        obj.input_vars.p0, obj.input_vars.ppw, obj.input_vars.cfl,...
        obj.field_maps.cmap', obj.field_maps.rhomap', obj.field_maps.attenmap',...
        obj.field_maps.boveramap', obj.xdc.incoords, obj.xdc.outcoords,...
        obj.xdc.icmat);
elseif isunix
    launchTotalFullWave2(obj.input_vars.c0, obj.input_vars.omega0,...
        obj.input_vars.wY, obj.input_vars.wZ, obj.input_vars.td,...
        obj.input_vars.p0, obj.input_vars.ppw, obj.input_vars.cfl,...
        obj.field_maps.cmap', obj.field_maps.rhomap', obj.field_maps.attenmap',...
        obj.field_maps.boveramap', obj.xdc.incoords, obj.xdc.outcoords,...
        obj.xdc.icmat);
    tic
    !./try6_nomex_selfcontained_ts
    toc
else
    error('Fullwave is not supported on your operating system.')
end

%%% Reshape output data %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ncoordsout=size(obj.xdc.outcoords,1);
nRun=sizeOfFile('genout.dat')/4/ncoordsout;
genout = readGenoutSlice(['genout.dat'],0:nRun-1,size(obj.xdc.outcoords,1));
rf = reshape(genout,size(genout,1),size(modidy,2),size(modidy,1));

end