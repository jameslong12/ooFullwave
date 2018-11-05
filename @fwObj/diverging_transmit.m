function icmat = diverging_transmit(obj,idy,idz,icvec,incoords)

%  Function to calculate diverging transmit focusing
%
%  Parameters:
%           obj             - Fullwave simulation object
%           idy, idz        - y, z indices of focus point
%           icvec           - Precalculated initial condition vector
%
%  Return:
%           icmat           - Initial condition matrix
%
%  James Long, 09/24/2018

cfl = obj.input_vars.cfl;

dd = sqrt((incoords(:,1)-idy).^2+(incoords(:,2)-idz).^2);
dd = round(dd/cfl);
dd = dd-min(dd);

icmat = zeros(size(incoords,1),length(icvec));
for i=1:size(incoords,1)
  icmat(i,dd(i)+1:end)  = icvec(1:end-dd(i));
end

end
