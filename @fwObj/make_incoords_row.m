function incoords = make_incoords_row(obj,inmap)

%  Replacement for mapToCoords to make definition curvilinear arrays easier
%
%  James Long 04/15/2020

inmapsum = sum(inmap,2);
assert(~any(inmapsum~=1),'inmap must be defined across lateral span')
assert(size(inmap,1)==obj.grid_vars.nY,'inmap must match dimensions of grid.')
assert(size(inmap,2)==obj.grid_vars.nZ,'inmap must match dimensions of grid.')

for i = 1:size(inmap,1)
    idy(i) = find(logical(inmap(i,:)));
    idx(i) = i;
end
incoords = [idx(:) idy(:)]-1;

end