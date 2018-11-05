function icmat = plane_transmit(obj,theta,icvec,incoords)

%  Function to calculate transmit focusing
%
%  Parameters:
%           obj             - Fullwave simulation object
%           theta           - Steering angle in degrees
%           icvec           - Precalculated initial condition vector
%
%  Return:
%           icmat           - Initial condition matrix
%
%  James Long, 09/26/2018

cfl = obj.input_vars.cfl;

factor = 1e6;
idy = factor*sind(theta);
idz = factor*cosd(theta);

dd = sqrt((incoords(:,1)-idy).^2+(incoords(:,2)-idz).^2);
dd = -round(dd/cfl);
dd = dd-min(dd);

icmat = zeros(size(incoords,1),length(icvec));
for i=1:size(incoords,1)
  icmat(i,dd(i)+1:end)  = icvec(1:end-dd(i));
end

end