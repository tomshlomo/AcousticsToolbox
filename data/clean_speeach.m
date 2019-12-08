function [s, fs] = clean_speeach(type, len, outputType)
% get clean speech signal

if nargin==0
    type = "male";
end
if isnumeric(type)
    assert(isscalar(type));
    types = ["male1","female1","male2","female2","male3","female3"];
    assert(type<=length(types));
    type = types(1:type);
end
n = zeros(length(type));
if nargin<2 || isempty(len)
    len = inf;
end
if nargin<3 || isempty(outputType)
    if length(n) == 1
        outputType = 'array';
    else
        outputType = 'cell';
    end
end

for i=1:length(type)
    switch lower(type(i))
        case {"male","male1","maleenglish"}
            n(i) = 50;
        case {"male2","malefrench"}
            n(i) = 52;
        case {"male3","malegerman"}
            n(i) = 54;
        case {"female","female1","femaleenglish"}
            n(i) = 49;
        case {"female2","femalefrench"}
            n(i) = 51;
        case {"female3","femalegerman"}
            n(i) = 53;
        otherwise
            error('unknown type: %s', type(i));
    end
end

[s, fs] = read_anechoic_recordings(n, len, outputType);

end

