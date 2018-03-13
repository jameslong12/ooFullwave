function out = do_sim(obj, field_flag)

%  Method to call Fullwave executable and perform simulation
%
%  Calling:
%           out = obj.do_sim(field_flag)
%
%  Parameters: 
%           field_flag          - Flag to indicate entire field output
%
%  James Long 03/10/2018

%%% Use field flag to get pressure across entire map %%%%%%%%%%%%%%%%%%%%%%
if ~exist('field_flag','var'), field_flag = 0; end
if field_flag
    obj.xdc.outmap = ones(size(obj.xdc.outmap));
    obj.xdc.outcoords = mapToCoords(obj.xdc.outmap);
end

%%% Launch FullWave executable %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
if field_flag
    out = reshape(genout, size(genout,1), size(obj.xdc.outmap,2), size(obj.xdc.outmap,1));
else
    for idx = 1:size(obj.xdc.outcoords)
        genout_re(:,obj.xdc.outcoords(idx,1)-min(obj.xdc.outcoords(:,1))+1) = double(genout(:,idx));
    end
    
    %%% Average across output to reconstruct element traces %%%%%%%%%%%%%%%
    for idx = 1:obj.xdc.n
        out(:,idx) = mean(genout_re(:,obj.xdc.e_ind(idx,:)),2);
    end
end

end