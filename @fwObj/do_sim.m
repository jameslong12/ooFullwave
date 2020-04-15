function out = do_sim(obj, field_flag)

%  Method to call Fullwave executable and perform simulation
%
%  Calling:
%           out = obj.do_sim(field_flag)
%
%  Parameters:
%           field_flag          - Flag to indicate entire field output. 1
%                                 for field pressure data output, 0 for
%                                 channel data (default = 0).
%
%  Returns:
%           out                 - Simulation result data
%
%  James Long 01/16/2019

%%% Use field flag to get pressure across entire map %%%%%%%%%%%%%%%%%%%%%%
if ~exist('field_flag','var'), field_flag = 0; end
if field_flag
    % redefine outmap and outcoords
    dY=1:obj.xdc.p_size(2):obj.grid_vars.nY;
    dZ=1:obj.xdc.p_size(3):obj.grid_vars.nZ;
    obj.xdc.outmap(dY,dZ) = 1;
    obj.xdc.outcoords = mapToCoords(obj.xdc.outmap);
end

%%% Launch FullWave executable %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
echo off
if obj.input_vars.v == 2
    fprintf('    Launching Fullwave version 2\n')
    if isunix
        launch_fullwave2_try6_nln_relaxing4(obj.input_vars.c0,...
            obj.input_vars.omega0, obj.input_vars.wY, obj.input_vars.wZ,...
            obj.input_vars.td, obj.input_vars.p0, obj.input_vars.ppw,...
            obj.input_vars.cfl, obj.field_maps.cmap, obj.field_maps.rhomap,...
            obj.field_maps.attenmap, obj.field_maps.Bmap, obj.xdc.incoords,...
            obj.xdc.outcoords, obj.xdc.icmat);
        !./fullwave2_try6_nln_relaxing
    else
        error('Fullwave2 is not supported on your operating system.')
    end
else
    if ispc
        launchTotalFullWaveRebuild2(obj.input_vars.c0, obj.input_vars.omega0,...
            obj.input_vars.wY, obj.input_vars.wZ, obj.input_vars.td,...
            obj.input_vars.p0, obj.input_vars.ppw, obj.input_vars.cfl,...
            obj.field_maps.cmap, obj.field_maps.rhomap, obj.field_maps.attenmap,...
            obj.field_maps.boveramap, obj.xdc.incoords, obj.xdc.outcoords,...
            obj.xdc.icmat);
    elseif isunix
        launchTotalFullWave2(obj.input_vars.c0, obj.input_vars.omega0,...
            obj.input_vars.wY, obj.input_vars.wZ, obj.input_vars.td,...
            obj.input_vars.p0, obj.input_vars.ppw, obj.input_vars.cfl,...
            obj.field_maps.cmap', obj.field_maps.rhomap', obj.field_maps.attenmap',...
            obj.field_maps.boveramap', obj.xdc.incoords, obj.xdc.outcoords,...
            obj.xdc.icmat);
        tic
        !./try6_nomex
        %!./try6_nomex_selfcontained_ts
        toc
    else
        error('Fullwave is not supported on your operating system.')
    end
end
echo on

%%% Reshape output data %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ncoordsout=size(obj.xdc.outcoords,1);
nRun=sizeOfFile('genout.dat')/4/ncoordsout;
genout = readGenoutSlice(['genout.dat'],0:nRun-1,size(obj.xdc.outcoords,1));

if field_flag
    out = reshape(genout,size(genout,1),length(dY),length(dZ));
    out = out(1:obj.xdc.p_size(1):end,:,:);
else
    for idx = 1:size(obj.xdc.outcoords)
%         genout_re(:,obj.xdc.outcoords(idx,1)-min(obj.xdc.outcoords(:,1))+1) = genout(:,idx);
        genout_re(:,obj.xdc.outcoords(idx,1)+1) = genout(:,idx);
    end

    %%% Average across output to reconstruct element traces %%%%%%%%%%%%%%%
    for idx = 1:obj.xdc.n
        out(:,idx) = mean(genout_re(:,obj.xdc.e_ind(idx,1):obj.xdc.e_ind(idx,2)),2);
    end
end

end
