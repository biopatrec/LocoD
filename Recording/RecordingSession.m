% ---------------------------- Copyright Notice ---------------------------
% This file is part of LocoD © which is open and free software under
% the GNU Lesser General Public License (LGPL). See the file "LICENSE" for
% the full license governing this code and copyrights.
%
% LocoD was initially developed by Bahareh Ahkami at
% Center for Bionics and Pain research and Chalmers University of Technology.
% All authors’ contributions must be kept
% acknowledged below in the section "Updates % Contributors".
%
% Would you like to contribute to science and sum efforts to improve
% amputees’ quality of life? Join this project! or, send your comments to:
% ahkami@chalmers.se.
%
% The entire copyright notice must be kept in this or any source file
% linked to LocoD. This will ensure communication with all authors and
% acknowledge contributions here and in the project web page (optional).

% acknowledge contributions here and in the project web page (optional).
% ------------------- Function Description ------------------
%This is the second class among the four main class of this program
%This class will handle all the stuff related to start snd stop recording and connecting
%to devices, and disconnecting
% --------------------------Updates--------------------------
% 2022-03-15 / Bahareh Ahkami / Creation

%This is the second class among the four main class of this program
%This class will handle all the stuff related to start snd stop recording and connecting
%to devices, and disconnecting
classdef RecordingSession < handle

    properties (Access = public)
        signal Signal;
        RecordingStat logical = 0;
        DrawnIdx=[];

        % === Statistics ===
        statTotalReceivedBytes=0; % on MAIN pipe

    end

    properties (Access = private)
        isConnected logical = 0;

        recProps RecordingProperties;

        % Polling timer stuff
        pollTimer = timer.empty; %Timer object
        tStartRec = 0; %Starting time for recording
        tLastPoll = 0; %Last timer callback time

        streams MultiStreamSourcedSignal;

        % === dummy ===
        dummyLastSample = 0;
        dummyCurrentTime = 0;

        % === DELSYS ===
        objsendto = [];
        objreadfromEMG = [];
        objreadfromAUX = [];
        hasStreamAux logical = false;

        % === Pre-recorded Signal File ===
        prerecSignal Signal = Signal.empty;
        prerecCurrentTime = 0;
        prerecPlaybackSpeedRatio = 0; % For future use
        
        prerecImportTrueTags logical = true;
        prerecTrueTagPtr = -1;
    end

    properties (Constant)
        SwingMark= 9;
        StanceMark= 8;
        SizeofDelsysEMG= 64; %16channels,  % Each sample is 64 bytes = 16channel x 4byte/sample.
        SizeofDelsysAUX= 576; %16channels  %  % Each sample is 576 bytes = 144 channel x 4byte/sample.
        MaxEMGChan=16;
        MaxAUXChan=144;
    end

    methods
        function this = RecordingSession(rec_props)
            % Ctor
            this.recProps = rec_props;
            this.signal = Signal(rec_props);
        end

        function rp = GetRecProps(this)
            rp = this.recProps;
        end

        function t = GetPrerecordedPlaybackTime(this)
            if ~strcmp(this.recProps.Device, "prerecorded")
                error("Invalid call to GetPrerecordedPlaybackTime")
            end
            t = this.prerecCurrentTime;
        end

        function SetPrerecordedPlaybackTime(this, t)
            if ~strcmp(this.recProps.Device, "prerecorded")
                error("Invalid call to GetPrerecordedPlaybackTime")
            end
            if isnan(t)
                error("Invalid time specified for SetPrerecordedPlaybackTime()")
            end
            maxTime = this.GetPrerecordedSignalLength();
            if t > maxTime
                t = maxTime;
            end
            if t < 0
                t = 0;
            end
            this.prerecCurrentTime = t;
            this.prerecTrueTagPtr = -1; % invalidate true tag pointer.
        end

        function SetPrerecordedImportTrueTags(this, enable)
            if ~strcmp(this.recProps.Device, "prerecorded")
                error("Invalid call to SetPrerecordedImportTrueTags")
            end
            this.prerecImportTrueTags = enable;
            this.prerecTrueTagPtr = -1; % invalidate true tag pointer.
        end

        function enable = GetPrerecordedImportTrueTags(this)
            enable = this.prerecImportTrueTags;
        end

        function sig = GetPrerecordedSignal(this)
            if ~strcmp(this.recProps.Device, "prerecorded")
                error("Invalid call to GetPrerecordedSignal")
            end
            sig = this.prerecSignal;
        end

        function L = GetPrerecordedSignalLength(this)
            if ~strcmp(this.recProps.Device, "prerecorded")
                error("Invalid call to GetPrerecordedSignalLength")
            end

            % Note that when calculating length of source signal, the
            % original samplerate (sig.RecProps.SamplingFreq) doesn't
            % matter!
            sig = this.prerecSignal;
            L = sig.GetNumSample() / this.recProps.SamplingFreq;
        end

        function delete(this)
            % Make sure to stop and disconnect
            this.StopRecording()
            this.Disconnect()
        end

        function y = IsConnected(this)
            y = this.isConnected;
        end

        function y = IsRecordingStarted(this)
            y = this.isConnected && ~isempty(this.pollTimer);
        end

        function Disconnect(this)
            % !@! CLEANUP

            % First do a cleanup of recording
            this.StopRecording()

            % Cleanup
            this.statTotalReceivedBytes = 0;

            if ~isempty(this.recProps)
                % Disconnect from device
                if strcmp(this.recProps.Device, 'dummy')
                    % Handle dummy
                    gprlog('Disconnecting from dummy');
                elseif strcmp(this.recProps.Device, 'prerecorded')
                    % Handle prerecorded
                    this.prerecSignal = Signal.empty;
                    this.prerecCurrentTime = 0;
                    gprlog('Closing prerecorded signal');
                elseif strcmp(this.recProps.Device, 'DELSYS_Trigno')
                    % Handle DELSYS
                    gprlog('Disconnecting from DELSYS');

                    if this.recProps.UnmaskedHasIMU==1
                        gprlog('Disconnecting from DELSYS_IMU');
                    end

                    % Close TCP/IP
                    if ~isempty(this.objsendto)
                        clear this.objsendto
                        this.objsendto = [];
                    end
                    if ~isempty(this.objreadfromEMG)
                        clear this.objreadfromEMG
                        this.objreadfromEMG = [];
                    end
                    if ~isempty(this.objreadfromAUX)
                        clear this.objreadfromAUX
                        this.objreadfromAUX = [];
                    end

                end

                this.isConnected = 0;
            end
        end
        function ConnectToDevice(this)
            if this.isConnected
                gprlog('* Already connected!')
                return
            end

            % Verify rec props. Would crash if any issues.
            this.recProps.Verify();

            % Connect
            deviceName  = this.recProps.Device;
            commType = this.recProps.ComType;
            nCh = this.recProps.UnmaskedNumEMGCh+this.recProps.UnmaskedNumPSCh;
            %nChAux = this.recProps.UnmaskedNumIMUCh;
            %sF = this.recProps.SamplingFreq;

            if nCh < 0
                gprlog('* Invalid number of channels')
                return
            end

            if strcmp(deviceName, 'DELSYS_Trigno') == 1 && strcmp(commType, 'WiFi') == 1
                try
                    if nCh > 16
                        gprlog('* DELSYS expects maximum channel count of 16');
                        return
                    end

                    % Open the connection to data port
                    this.objreadfromEMG = tcpclient('localhost',50043);
                    this.objreadfromEMG.ByteOrder = "little-endian";
                    %this.objreadfromEMG.InputBufferSize = 64000000;

                    % Open command port
                    this.objsendto = tcpclient('localhost',50040);
                    configureTerminator(this.objsendto, "CR/LF")
                    writeline(this.objsendto, sprintf('MASTER\r\nSTOP\r\nENDIAN LITTLE\r\n')); % Will add extra \r\n
                    pause(0.1);
                    flush(this.objsendto)

                    % Do we have IMU data for Delsys?
                    if this.recProps.UnmaskedHasIMU==1
                        this.hasStreamAux = true;
                    else
                        this.hasStreamAux = false;
                    end

                    if this.hasStreamAux
                        % Open the connection to data port for IMU
                        this.objreadfromAUX = tcpclient('localhost', 4);
                        this.objreadfromAUX.ByteOrder = "little-endian";
                        %this.objreadfromAUX.InputBufferSize = 64000000;
                        flush(this.objreadfromAUX)
                    end

                    % Read available data from data port and discard it
                    flush(this.objreadfromEMG)
                    gprlog('Connected to Delsys!')

                    % Generate streams handler for DELSYS.
                    % This is the signal configuration in DELSYS.
                    this.streams = MultiStreamSourcedSignal();
                    if this.hasStreamAux
                        this.streams.Initialize({'MAIN', 'AUX'}, [16 144], [2000 4000/27]); % 4000/27=148.148
                    else
                        this.streams.Initialize({'MAIN'}, [16], [2000]);
                    end

                catch Ex
                    % Clean up
                    clear this.objreadfromEMG
                    clear this.objsendto
                    clear this.objreadfromAUX

                    this.objreadfromEMG = [];
                    this.objreadfromAUX = [];
                    this.objsendto = [];

                    gprlog('* CONNECTION ERROR: please start the DELSYS Trigno Control Utility or download it from: http://www.delsys.com/Attachments_pdf/installer/TrignoSDKServerInstaller.exe or from DELSYS website: http://www.delsys.com/integration/sdk/ - Internal error: %s', GetExceptionSummary(Ex));
                    rethrow(Ex);

                    %return
                end

            elseif strcmp(deviceName, 'dummy') == 1
                % Nothing to do
                gprlog('Connected to Dummy!')

            elseif strcmp(deviceName, 'prerecorded') == 1
                % Source signal is already verified above.
                this.prerecSignal = this.recProps.prerecFileData.signalCopy;
                this.prerecPlaybackSpeedRatio = 1;
                this.prerecCurrentTime = 0;
                this.prerecImportTrueTags = true;
                this.prerecTrueTagPtr = -1;

                gprlog('Opened prerecorded signal!')

            else
                gprlog('* Unknown device/comm type %s/%s', deviceName, commType);
                return
            end

            this.isConnected = 1;

        end

        function StartRecording(this)
            if ~this.isConnected
                gprlog('* StartRecording (RecSess): Device is not connected yet.')
                return
            end

            this.RecordingStat =1;
            deviceName_EMG  = this.recProps.Device;

            % Store timer start time
            this.tStartRec = tic;
            this.tLastPoll = this.tStartRec;

            % Clear signal log
            this.signal.ClearSignal();

            % Send start command
            if strcmp(deviceName_EMG, 'dummy')
                % Handle dummy -- Nothing special to do
                gprlog('Starting recording on dummy...');
                this.dummyCurrentTime = 0;
                this.dummyLastSample = 0;

            

            elseif strcmp(deviceName_EMG, 'DELSYS_Trigno')
                % Handle DELSYS
                % Send the commands to start data streanng
                flush(this.objsendto);
                if this.hasStreamAux
                    flush(this.objreadfromAUX);
                end
                flush(this.objreadfromEMG);

                this.streams.ClearStreams();

                gprlog('Starting recording on DELSYS...');
                writeline(this.objsendto, sprintf('ENDIAN LITTLE\r\nSTART\r\n')); % will add extra \r\n
                pause(0.1);
            end

            % Create data polling timer
            this.pollTimer = timer('Name', 'PollTimer', ...
                'Period', 0.05, ...
                'StartDelay', 0, ...
                'TasksToExecute', inf, ...
                'ExecutionMode', 'fixedRate', ...
                'TimerFcn', @this.OnPollData, ...
                'ErrorFcn', @this.OnPollError);
            start(this.pollTimer);
            disp('Poll Timer Started')
        end

        function OnPollData(this, tmrObj, ~) %(this, tmrObj, eventArgs)
            % Check that this is a valid call to OnPollData
            try
                if tmrObj ~= this.pollTimer
                    throw(MException("LOCOD:InternalError", "Invalid timer object for OnPollData. This is an internal error."))
                end
                if ~this.isConnected
                    throw(MException("LOCOD:InternalError", "Device is not connected"))
                end
            catch Ex
                % Something is wrong
                stop(tmrObj);
                delete(tmrObj);
                this.pollTimer = timer.empty;

                gprlog('* Invalid call to data poll timer: %s', GetExceptionSummary(Ex));
                throw(MException("LOCOD:PollDataFailed", "Exception " + ...
                    "caught within onPollData. See console for more info."))
            end

            try
                % Read delta time
                t = tic;
                deltaTime = double(t - this.tLastPoll) / 1.0e7; % 1.0e7 is resolution of tic()
                this.tLastPoll = t;

                if strcmp(this.recProps.Device, 'dummy')
                    % === Dummy Device === %
                    sampleRate = this.recProps.SamplingFreq;
                    nChTotal = this.recProps.UnmaskedNumAllCh;

                    % How many samples do we get?
                    if deltaTime > 0.3
                        disp('Very high dt! Slow...')
                    end
                    if deltaTime > 5
                        gprlog('* Trimming deltaTime')
                        deltaTime = 5;
                    end
                    this.dummyCurrentTime = this.dummyCurrentTime + deltaTime;
                    currSample = floor(this.dummyCurrentTime * sampleRate);
                    if currSample <= this.dummyLastSample
                        % Nothing new.
                        return
                    end

                    % Create some samples for all channels, with different
                    % freq for each channel.
                    t = (this.dummyLastSample + 1 : currSample) / sampleRate;
                    nNewDummySample=length(t);
                    this.dummyLastSample = currSample;

                    channel_freqs = 0.1 * double(1:nChTotal);
                    sample_time_matrix = channel_freqs' * t;
                    sig = sin(2 * pi * sample_time_matrix) + randn([nChTotal nNewDummySample]) * 0.1;

                    % Register
                    if this.RecordingStat==1
                        this.signal.AppendSignal(nNewDummySample, sig);
                    end


                elseif strcmp(this.recProps.Device, 'DELSYS_Trigno')
                    % === Handle DELSYS === %

                    % Find out how many samples to read. Check available
                    % data count and read all available samples.
                    % MAIN pipe: Always 16 channels (64 B)
                    % AUX pipe : Always 9x16 = 144 channels (576 B)
                    MainSrcMaxSample = floor(this.objreadfromEMG.NumBytesAvailable / 64);
                    if this.hasStreamAux
                        AuxSrcMaxSample = floor(this.objreadfromAUX.NumBytesAvailable / 576);
                    else
                        AuxSrcMaxSample = 0;
                    end

                    % Read the MAIN pipe
                    if MainSrcMaxSample ~= 0
                        % Read MAIN data. Originally it is Float32 (Flt)
                        MainSrcSamplesVectorFlt = read(this.objreadfromEMG, MainSrcMaxSample * 16, 'single');
                        MainSrcSamplesVector = cast(MainSrcSamplesVectorFlt, 'double');
                        MainSrcSamples = reshape(MainSrcSamplesVector, [16 MainSrcMaxSample]);

                        this.statTotalReceivedBytes = this.statTotalReceivedBytes + this.objreadfromEMG.NumBytesAvailable;
                    else
                        MainSrcSamples = zeros(16, 0);
                    end

                    % Read the AUX pipe
                    if AuxSrcMaxSample ~= 0
                        AuxSrcSamplesVectorFlt = read(this.objreadfromAUX, AuxSrcMaxSample * 144, 'single');
                        AuxSrcSamplesVector = cast(AuxSrcSamplesVectorFlt, 'double');
                        AuxSrcSamples = reshape(AuxSrcSamplesVector, [144 AuxSrcMaxSample]);
                    else
                        AuxSrcSamples = zeros(144, 0);
                    end

                    %gprlog('delsys %f %d %d', double(tic) / 1.0e7, size(MainSrcSamples, 2), size(AuxSrcSamples, 2))

                    % Place received streams in the stream handler
                    this.streams.PushIntoStream('MAIN', MainSrcSamples);
                    if this.hasStreamAux
                        this.streams.PushIntoStream('AUX', AuxSrcSamples);
                    end

                    % Perform interpolation and side streams, (and a lot of
                    % other magic! B))
                    SyncedSamples = this.streams.SyncAndSubmit(0);
                    MainSrcSamples = SyncedSamples{1, 2};
                    if this.hasStreamAux
                        AuxSrcSamples = SyncedSamples{2, 2};
                    else
                        AuxSrcSamples = [];
                    end

                    % If actually recording, go further.
                    if this.RecordingStat == 1 && size(MainSrcSamples, 2) > 0
                        this.IncomingDataTransposition_Delsys(MainSrcSamples, AuxSrcSamples);
                    end

                else
                    error('OnPollData: Invalid device')
                end

            catch Ex
                gprlog('* Exception in Poll Timer: \n%s', GetExceptionSummary(Ex));
                throw(MException("LOCOD:PollDataFailed", "Exception " + ...
                    "caught within onPollData. See console for more info."))
            end
        end



        function StopRecording(this)
            this.RecordingStat=0;

            % !@! CLEANUP
            if ~isempty(this.recProps)
                % Handle DELSYS
                if strcmp(this.recProps.Device, 'DELSYS_Trigno')
                    if ~isempty(this.objsendto)
                        % Stop the aquisition
                        writeline(this.objsendto,  sprintf(['STOP\r\n']));
                        pause(0.1)
                        flush(this.objsendto);
                    end
                end

                % Handle prerecorded
                % !@! WASBUGGY: Must not clear prerecSignal yet.
            end

 

            % Cleanup Streams manager
            this.streams = MultiStreamSourcedSignal.empty;

            % Kill the timer
            if ~isempty(this.pollTimer)
                gprlog("Stopping poll timer")
                stop(this.pollTimer);
                delete(this.pollTimer);
                this.pollTimer = [];
            end
        end

        function OnPollError(~, ~, eventArgs) %(this, tmrObj, eventArgs)
            gprlog(['* Error occured with while capturing data within timer ' ...
                '-- See console for more info: %s'], eventArgs.Data.message)
        end

        function IncomingDataTransposition_Delsys(this, MainSrcSamples, AuxSrcSamples)
            % Data from Delsys is configured in the following way:
            % MainSrc: Always 16 channels x NumSampleMain
            % AuxSrc: Always 144 channels x NumSampleAux
            %~~[~, nSmpMain] = size(MainSrcSamples);
            %~~[~, nSmpAux] = size(AuxSrcSamples);

            % Now! Sample rate at MAIN should be 2000 (see RecProps.Verify)
            % Sample rate at AUX should be 4000 / 27 = 148.148148...
            % The data at AUX should be upsampled to same sample rate of
            % MAIN. Store data inside MAIN
            % More info on Trigno SDK datasheet.
            % TODO: Check UnmaskedHasEMG
            if this.recProps.UnmaskedHasEMG==1
                EMGSig = MainSrcSamples(this.recProps.ChannelSelectionEMG, :);
            else
                EMGSig = [];
            end

            if this.recProps.UnmaskedHasPS==1
                PSSig = MainSrcSamples(this.recProps.ChannelSelectionPS, :);

            else
                PSSig = [];
            end

            if this.recProps.UnmaskedHasIMU==1
                IMUSig = AuxSrcSamples(this.recProps.ChannelSelectionIMU, :);
            else
                IMUSig = [];
            end

            AllSig = [EMGSig; PSSig; IMUSig];

            % Put signal and request processing
            this.signal.AppendSignal(size(AllSig, 2), AllSig);
        end
    end
end

