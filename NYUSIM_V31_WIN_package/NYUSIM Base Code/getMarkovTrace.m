%%% NYUSIM - User License %%%

% Copyright (c) 2016-2019 New York University and NYU WIRELESS

% Permission is hereby granted, free of charge, to any person obtaining a 
% copy of this software and associated documentation files (the ?Software?),
% to deal in the Software without restriction, including without limitation 
% the rights to use, copy, modify, merge, publish, distribute, sublicense, 
% and/or sell copies of the Software, and to permit persons to whom the 
% Software is furnished to do so, subject to the following conditions:

% The above copyright notice and this permission notice shall be included
% in all copies or substantial portions of the Software. Users shall cite 
% NYU WIRELESS publications regarding this work.

% THE SOFTWARE IS PROVIDED ?AS IS?, WITHOUTWARRANTY OF ANY KIND, EXPRESS OR 
% IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
% FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL 
% THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR 
% OTHER LIABILITY, WHETHER INANACTION OF CONTRACT TORT OR OTHERWISE, 
% ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR 
% OTHER DEALINGS IN THE SOFTWARE.

function mc = getMarkovTrace(lambdaDecay,lambdaShad,lambdaRise,lambdaUnshad,mcLen,t_px)

% Generate a long Markov chain with random states

mc = zeros(mcLen,1);
mc(1) = 1;
pDecay = lambdaDecay*t_px;
pShad = lambdaShad*t_px;
pRise = lambdaRise*t_px;
pUnshad = lambdaUnshad*t_px;

transMatrix = [1-pDecay, pDecay, 0, 0;
    0, 1-pShad, pShad, 0;
    0, 0, 1-pRise, pRise;
    pUnshad, 0, 0, 1-pUnshad];


for i = 2:mcLen
   dist = transMatrix(mc(i-1),:);
   cumuDist = cumsum(dist);
   
   r = rand();
   
   mc(i) = find(cumuDist>r,1);
end

end