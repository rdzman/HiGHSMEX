function opts = highsoptset(varargin)
% Make a struct of user-settable HiGHS options that can be passed to the
% callhighs function. This is a convenience function to recast the option
% values to the type that HiGHS requires. For example, HiGHS option
% "log_to_console" must be a logical (boolean) type, but you can specify it
% as a numeric type in the input.
%
% EXAMPLES:
% Specify options as name-value pairs
% opts = highsoptset('solver', 'choose', 'log_to_console', 0)
%
% Specify options as a struct
% opts = struct('solver', 'choose', 'log_to_console', 0);
% opts = highsoptset(opts)
%
% Author: Savyasachi Singh

persistent optionTypeMap

if isempty(optionTypeMap)
    defopts = callhighs("defopts");
    optionTypeMap = containers.Map('KeyType', 'char', 'ValueType', 'char');
    allOptionNames = fieldnames(defopts);
    for i=1:numel(allOptionNames)
        optionTypeMap(allOptionNames{i}) = class(defopts.(allOptionNames{i}));
    end
end


switch nargin
    case 1
        optionNames = fieldnames(varargin{1});
        optionValues = cell(size(optionNames));
        for i=1:numel(optionNames)
            optionValues{i} = varargin{1}.(optionNames{i});
        end

    otherwise
        assert(~mod(nargin, 2), "Number of input arguments must be even.")
        optionNames = varargin(1:2:end-1);
        optionValues = varargin(2:2:end);
end
for i=1:numel(optionValues)
    name = convertStringsToChars(optionNames{i});
    if ~isKey(optionTypeMap, name)
        error('"%s" is not a legal HiGHS option.', name)
    end
    optclass = optionTypeMap(name);

    if strcmp(optclass, 'string')
        % If HiGHS option is a C++ string then we accept MATLAB char-array or string
        if ~(isstring(optionValues{i}) || ischar(optionValues{i}))
            error('Invalid class of the value of option "%s". Expected it to be char or string but received a %s.',...
                name, class(optionValues{i}))
        end
    else
        % If HiGHS option is bool/int/double then we accept MATLAB numeric or logical type
        if ~(isnumeric(optionValues{i}) || islogical(optionValues{i}))
            error('Invalid class of the value of option "%s". Expected it to be numeric or logical but received a %s.',...
                name, class(optionValues{i}))
        end
    end

    if ischar(optionValues{i})
        optionValues{i} = convertCharsToStrings(optionValues{i});
    elseif isstring(optionValues{i})
        % Do nothing
    else
        optionValues{i} = cast(optionValues{i}, optclass);
    end

    opts.(name) = optionValues{i};
end

% EOF
