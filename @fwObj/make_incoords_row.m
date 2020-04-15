function incoords = make_incoords_row(inmap)

% Replacement for mapToCoords to make definition curvilinear arrays easier

% check for single row
inmapsum = sum(inmap,2);
assert(~any(inmapsum~=1),'must be a full row of 1''s')
keyboard

for i = 1:size(inmap,1)
    
% [idx idy] = find(map~=0);
% coords = [idx-1 idy-1];
incoords = 0;
end

end