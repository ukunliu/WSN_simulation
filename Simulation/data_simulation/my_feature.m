function  [pathDelays, pathGains] = my_feature(obj)
    %showProfile Visualize temporal and spatial profiles of the channel
    %   showProfile(CHAN) plots the power delay profile (PDP), angle of
    %   departure (AoD), and angle of arrival (AoA) information for the ray
    %   tracing channel, CHAN, in a single figure with three subplots. 
    %  
    %   The PDP subplot is derived from the propagation delay, path loss,
    %   phase shift, pattern gain at transmit array and pattern gain at
    %   receive array for each ray. The AoD/AoA subplot shows the 3-D
    %   directions of the rays in the local coordinate system (LCS). When
    %   the TransmitArray/ReceiveArray property is specified as an object
    %   from Phased Array System Toolbox, the AoD/AoA subplot also shows
    %   the directivity pattern of the array.
    %
    %   showProfile(CHAN, 'ArrayPattern', FALSE) optionally turns off the
    %   directivity pattern in the AoD/AoA subplot. It applies only when
    %   the TransmitArray/ReceiveArray property is specified as an object
    %   from Phased Array System Toolbox. 

    coder.internal.errorIf(~isempty(coder.target), ...
        'comm:RayTracingChannel:VisualForSimOnly');
    
    narginchk(1,3);
    
%     p = inputParser;
%     p.addParameter('ArrayPattern', true);
%     p.parse(varargin{:});
%     showPattern = p.Results.ArrayPattern;
%     validateattributes(showPattern, {'logical'}, {'scalar'}, ...
%         'showProfile', 'ArrayPattern');

    % Retrieve necessary info from ray objects    
    rays = obj.PropagationRays;
    txArray = obj.TransmitArray;
    rxArray = obj.ReceiveArray;
    NP = length(obj.PropagationRays);
    [fc, pathLoss, pathPhase, AoD, AoA] = ...
        comm.RayTracingChannel.retrieveRayCIRParam(rays);
    pathDelays = comm.RayTracingChannel.retrievePathDelays( ...
        rays, obj.MinimizePropagationDelay);

    % Set up a figure
%     figure('units','normalized','outerposition',[0.2 0.2 0.6 0.6]);
%     
%     % Plot power delay profile (PDP) 
%     subplot('position',[0.05 0.1 0.5 0.8])    
    
    % Convert AoD and AoA from GCS to LCS
    AoD = global2localcoord([AoD; ones(1, NP)], 'ss', ...
        zeros(3,1), obj.TransmitArrayOrientationAxes); 
    AoA = global2localcoord([AoA; ones(1, NP)], 'ss', ...
        zeros(3,1), obj.ReceiveArrayOrientationAxes); 
    
    % Calculate Tx and Rx pattern gains
    patTx = arrayfun(@(x,y)pattern(txArray, fc, x, y), AoD(1,:), AoD(2,:));
    patRx = arrayfun(@(x,y)pattern(rxArray, fc, x, y), AoA(1,:), AoA(2,:));
    
    % Derive complex path gains (= PatGainTx - PathLoss + PatGainRx)
    pathGains = 10.^((patTx-pathLoss+patRx)/20) .* exp(1i*pathPhase);
    
%     % Stem plot for PDP
%     stem(pathDelays, abs(pathGains), 'filled', 'y');
%     % Force the x-axis to start at a negative value or 0
%     xl = xlim;
%     xlim([min(0, xl(1)), xl(2)]); 
%     grid on;
%     ax = gca;
%     set(ax,'Color','black','GridColor','white', ...
%         'FontUnits','normalized','FontSize',0.03);
%     title('Power Delay Profile');
%     xlabel('Delay (s)'); ylabel('Magnitude');
%     
%     % Plot AoD and Tx pattern
%     subplot('position', [0.55 0.5 0.4 0.38]);        
%     plotPatternWithRayAngles(txArray, fc, AoD, 'tx', showPattern);
%     
%     % Plot AoA and Rx pattern
%     subplot('position',[0.55 0.1 0.4 0.38]);
%     plotPatternWithRayAngles(rxArray, fc, AoA, 'rx', showPattern);
  end