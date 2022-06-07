function upvecs = PlatModel(tinc,g,cacc,lacc,on_off,cper,cdamp,lper,ldamp)
% upvecs = PlatModel(tinc,g,cacc,lacc,on_off,cper,cdamp,lper,ldamp)
%
% tinc: time increment(seconds)
% g: normal gravity values (mGals)
% cacc: cross accelerations (mGals)
% lacc: long accelerations (mGals)
% on_off: logical flag for platform in 
% cper: cross-axis period (seconds)
% cdamp: cross-axis damping
% lper: long-axis period (seconds)
% ldamp: long-axis damping
%
% upvecs: 3xN matrix of platform up-vectors in
%         (cross, long, up) coords

% zero out NaN's in accels
cacc(isnan(cacc)) = 0;
cacc(on_off > 0) = 0;
lacc(isnan(lacc)) = 0;
lacc(on_off > 0) = 0;

% get cross axis tilt filters
[cnum,cden] = TiltFilter(cper,tinc,cdamp);

% cross axis driving term
drive = cacc ./ g;
drive(isnan(drive)) = 0;

% do tilt filtering
ctilt = filter(cnum, cden, drive);

% long axis tilt filters
[lnum,lden] = TiltFilter(lper,tinc,ldamp);

% long axis driving term
drive = lacc ./ g;
drive(isnan(drive)) = 0;

% tilt filtering
ltilt = filter(lnum, lden, drive);

% combine for platform up vectors
upvecs = CalcPlatUpVec(atan(ctilt),atan(ltilt));
%upvecs = CalcPlatUpVec(ctilt,ltilt);

end



