function assignments = extract_struct(struct)

%  Extract structure fields as individual variables
%
%  Calling: assignments = extract_struct(struct)
%           for i = 1:length(assignments)
%           eval(assignments{i});
%           end
%
%  Parameters:  struct      - Structure with fields
%
%  Return:      assignments - Nx1 cell array, where N is the number of
%                             fields in struct
%
%  James Long 03/06/2018

names = fieldnames(struct);
s = inputname(1);
assignments= cellfun(@(f) [f ' = ' s '.' f ';     '],names,'uniformoutput',0);

end