%MultiStreamSourcedSignal handles synchronization of data from more than
%  signal stream.
%Note: Signal Stream #1 is always the main stream
classdef MultiStreamSourcedSignal < handle
    properties (Access = public)
        
    end

    properties (Access = public)
        S = {}    %Cell array of signal caches -- StreamOfSignal
    end

    properties (Constant)
        CacheSizeTime = 3.0 % seconds
        MaxInputSignalLengthTime = 1.5 % seconds
        DefaultMarginForInterpMissingData = 1 % samples
        MaxPatienceForUnarrivedData = 1.0 % seconds
        StreamTimeDeviationSentinel = 3.0 % seconds

        % Sampling Frequency Adjustment
        SFAPeriod = 1.5 %Seconds
        SFADeviationThreshold = 0.01 % 100%
        SFASpeedUpDownTendency = 0.1 %[0,1]
        SFASpeedUpMax = 10.0 %Ratio of original SF
        SFASlowDownMin = 0.1 %Ratio of original SF
        SFATimeDeviationThreshold = 0.05
    end
    
    methods
        function Initialize(this, streamNames, streamChannels, streamSampleFreqs)
            nStream = length(streamNames);

            if nStream ~= length(streamChannels) || nStream ~= length(streamSampleFreqs) || nStream == 0
                % SENTINEL
                error('Invalid args')
            end

            if ~strcmpi(streamNames{1}, "MAIN")
                warning('Stream #1 should be named MAIN, not %s. Regardless, Stream #1 is always the main stream!', streamNames{1})
            end

            this.S = cell(nStream, 1);
            for i = 1 : nStream
                sigStream = StreamOfSignal();
                sigStream.Initialize(streamNames{i}, streamChannels(i), streamSampleFreqs(i), floor(streamSampleFreqs(i) * this.CacheSizeTime));
                this.S{i} = sigStream;
            end

            this.ClearStreams();
        end


        function ClearStreams(this)
            for i = 1 : length(this.S)
                this.S{i}.Clear();
                
                % Put some auxilliary data in the stream.
                % For more info see below.
                this.S{i}.SyncData = struct();
                this.S{i}.SyncData.SFASampleCountStatistics = 0;
                this.S{i}.SyncData.EndTimeDeviationSum = 0;
                this.S{i}.SyncData.EndTimeDeviationN = 0;
                this.S{i}.SyncData.SFAAdjustingForEndTimeDeviation = false;
                this.S{i}.SyncData.MarginForInterpMissingData = this.DefaultMarginForInterpMissingData;

                % We shall store signal time for every stream.
                % To maintain numerical error, we shall do so in samples
                % instead of seconds for the main stream.
                if i == 1
                    this.S{i}.SyncData.ReferenceSample = 0; % Zero based
                else
                    this.S{i}.SyncData.ReferenceTime = 0.0;
                end
                
            end
        end
        

        function PushIntoStream(this, streamName, sig)
            % Find out which stream this is, and push it in the cache.
            for i = 1 : length(this.S)
                if strcmp(this.S{i}.Name, streamName)
                    if size(sig, 2) > this.S{i}.SF * this.MaxInputSignalLengthTime
                        % Show a warning
                        warning('A signal chunk for stream %s seems too long. The excess might be truncated from the beginning.');
                    end

                    % Note: In case of excessive data, priority is with
                    % older parts. We could give priority to newer parts
                    % (second arg -> true), but then we had to adjust all
                    % signal timing variables, which could be an overkill.
                    [nNewSample, Ovf] = this.S{i}.PushChunk(sig, false);
                    
                    if Ovf
                        warning('Stream %s overflow', this.S{i}.Name);
                    end

                    this.S{i}.SyncData.SFASampleCountStatistics = this.S{i}.SyncData.SFASampleCountStatistics + nNewSample;
                    this.S{i}.SyncData.SFAEndTimeDeviationSum = 0;
                    return
                end
            end
            error('Invalid streamName %s for PushIntoStream', streamName);
        end

        function delete(this)
            this.S = {};
        end

        function dischargedData = SyncAndSubmit(this, maxDischargeSamples)
            % So the magic happens here.
            % Main question is, how much signal time to release to the client
            % right now.
            % The main stream is the holy grail. All other streams must be
            % synced to it. Main stream can wait a while for signal from
            % other streams to arrive.
            % So let's see what we've got:

            % Read tX0 = Current Signal Time (corresponds to time of first sample in
            %   the main stream - stream #1)
            nX0 = this.S{1}.SyncData.ReferenceSample;
            tX0 = nX0 / this.S{1}.SF;
            
            % Look at the main stream and
            %   read tX1 = Absolute maximum signal time available.
            tX1 = tX0 + this.S{1}.TimeLen;
            tX1Orig = tX1;

            % We shall consume samples in time range tX0~tX1.

            % Now look at other streams
            for i = 2 : length(this.S)
                % Read tY0,1
                tY0 = this.S{i}.SyncData.ReferenceTime;

                % Note that a few final samples from S{i} are currently
                % useless, since there is not enough data to recalculate
                % them after interpolation. It depends on the type of
                % anti-aliasing filter that is used.
                L = max(0, this.S{i}.SigBufLen - this.S{i}.SyncData.MarginForInterpMissingData);
                tY1 = tY0 + L / this.S{i}.SF;

                % Are we short on amount of data on this stream?
                if tY1 < tX1
                    % Then let's take less data from main stream.
                    tX1 = tY1;
                end

                % Note that there are other conditions also:
                % tY1 > tX1: More data on S{i} compared to main stream.
                %   We shall cache this excess data, later it will be used.
                % tY0 < or > tX0, by a tiny margin: Sample rate disparities
                %   result in stream times not being exactly the same.
                % tY0 < or > tX0, by a large margin: This must not happen.
                %   There is a sentinel to prevent this.
            end

            % Regardless, we don't tolerate falling too much behind with
            %   the main stream, if another stream has missing unarrived
            %   data. In that case the stream with missing data will have
            %   to yield last-read-value as samples (see below).
            if tX1Orig - tX1 > this.MaxPatienceForUnarrivedData
                tX1 = tX1Orig - this.MaxPatienceForUnarrivedData;
            end

            % Count number of samples for progression on the main stream.
            %   nXD = floor(tX1 * SF) - floor(tX0 * SF). To increase
            %   numerical precision, since already tX0 = nX0 / SF,
            %   we do this instead:
            nXD = floor(tX1 * this.S{1}.SF) - nX0;
            if nXD > this.S{1}.SigBufLen
                % Must not get here
                warning('FAULT: S1: nXD > this.S{1}.SigBufLen')
                nXD = this.S{1}.SigBufLen;
            end

            if maxDischargeSamples > 0 && nXD > maxDischargeSamples
                % Caller wants less samples
                nXD = floor(maxDischargeSamples);
            end

            % Release signal to the client
            dischargedData = cell(length(this.S), 2);
            for i = 1:length(this.S)
                dischargedData{i,1} = this.S{i}.Name;
            end

            if nXD <= 0
                % No progression for now. Release empty signal. We shall wait a bit more.
                for i = 1:length(this.S)
                    dischargedData{i,2} = zeros(this.S{i}.NumCh, 0);
                end
                return
            end

            % Interpolate signal streams from their own SF to main SF.
            SFX = this.S{1}.SF;

            % Check what sample times we want
            % NOTE: nX0 is zero based (first sample = sample #0)
            STX = (nX0:nX0 + nXD - 1) / SFX;

            for i = 2 : length(this.S)
                % Sample S{i} at XSampleTimes (XST).
                % We use interp1. Which takes sample indices, and the
                %   sample indices must be in range of [1:N]. N is number
                %   of available samples in the signal. Out of range
                %   samples will turn NaN.
                % Trivially, n=1 correponds to t=tY0,
                %   and n=N corresponds to t=tY0 + (N - 1)/SFy
                tY0 = this.S{i}.SyncData.ReferenceTime;
                SFY = this.S{i}.SF;
                NY = this.S{i}.SigBufLen;
                SNY = (STX - tY0) * SFY + 1;

                %SNY is indices of samples to interpolate from Y. Out of
                %  range samples (< 1 or > N) should be clamped to border.
                MaxSampleThatOriginallyWasToBeUsed = ceil(max(SNY));
                SNY(SNY < 1) = 1;
                SNY(SNY > NY) = NY;

                if NY > 0
                    %Peek from stream and use interp1 to linearly interpolate.
                    %  Note that interp1, views the channels along the first
                    %  dimension. Therefore, we transpose before and after.
                    PeekLen = ceil(max(SNY)); % or just set PeekLen to NY.
                    Y = this.S{i}.PeekChunk(PeekLen);
                    if size(Y, 2) ~= PeekLen
                        % Must not get here.
                        error('FAULT: S%d: %d = size(Y, 2) ~= PeekLen = %d', i, size(Y, 2), PeekLen);
                    end
                    InterpY = interp1(Y', SNY)';
                else
                    % Special condition when there is absolutely no data
                    % available in this stream.
                    InterpY = zeros(this.S{i}.NumCh, nXD);
                end
                
                % Discharge stream #i
                dischargedData{i,2} = InterpY;

                % Discard the used data. Note that we are somewhate
                %  flexible on number of samples to discard here.
                %  We even can keep all of them and not throw away any (we
                %  will run into memory limit and overflow the stream).
                % Discard all samples we used in the interpolation, minus
                %  the last few of them. Reason is to keep them for later
                %  chunks, when the anti-aliasing filter needs a couple of
                %  older samples.
                % Again, it doesn't hurt to have a few extra samples in the
                %  cache, since we keep track of the time.
                %  We can take more samples just for over-cautionism :/ No rationale.
                % Note that this doesn't have to do with M=MarginForInterpMissingData.
                %  M samples are already saved for future and they were
                %  never used originally (see above). Here we are talking
                %  about STILL keeping samples that we have used for later
                %  cycles.
                nSalvagedSamples = 3;
                nProgression = MaxSampleThatOriginallyWasToBeUsed - nSalvagedSamples;

                if nProgression > 0
                    % Progress on time
                    this.S{i}.SyncData.ReferenceTime = this.S{i}.SyncData.ReferenceTime + nProgression / this.S{i}.SF;

                    % Discard used data. Note that a data underrun might
                    % happen here, in case already have a shortage of data
                    % data with this stream (same reason as the
                    %  'SNY(SNY > NY) = NY' statement above.
                    if nProgression > this.S{i}.SigBufLen
                        warning('Stream %s underrun. System behaviour might be undefined.', this.S{i}.Name)
                    end
                    this.S{i}.DiscardChunk(nProgression);
                end
            end

            % Discharge main stream -- stream #1. No interpolation needed.
            % Read and **DISCARD** signal from stream #1
            PeekLen = nXD;
            X = this.S{1}.PopChunk(PeekLen);
            if size(X, 2) ~= PeekLen
                % Must not get here.
                error('FAULT: S1: %d = size(X, 2) ~= PeekLen = %d', size(X, 2), PeekLen);
            end
            dischargedData{1,2} = X;

            % Progress sample time on main stream. The data is already
            % discard (above PopChunk()).
            this.S{1}.SyncData.ReferenceSample = this.S{1}.SyncData.ReferenceSample + nXD;

            % ==========================================
            % Furthur optimizations

            % To prevent numerical error buildup, rotate
            %   ReferenceSample/Time counters every now and then.
            if this.S{1}.SyncData.ReferenceSample > this.S{1}.SF
                % Rotate all the counters so that S{1}.ReferenceSample
                % becomes 0.
                RotateXN = this.S{1}.SyncData.ReferenceSample;
            else
                RotateXN = 0;
            end

            this.S{1}.SyncData.ReferenceSample = this.S{1}.SyncData.ReferenceSample - RotateXN;
            nX0 = this.S{1}.SyncData.ReferenceSample;
            tX0 = nX0 / this.S{1}.SF;

            % Do the same for non-main streams.
            RotateT = RotateXN / this.S{1}.SF;
            for i = 2 : length(this.S)
                this.S{i}.SyncData.ReferenceTime = this.S{i}.SyncData.ReferenceTime - RotateT;

                % Simultaneously put a limit on reference time deviation
                % (Must not get there)
                if this.S{i}.SyncData.ReferenceTime > tX0 + this.StreamTimeDeviationSentinel
                    this.S{i}.SyncData.ReferenceTime = tX0 + this.StreamTimeDeviationSentinel;
                    error('FAULT: Stream %s reference time overrun', this.S{i}.Name)

                elseif this.S{i}.SyncData.ReferenceTime < tX0 - this.StreamTimeDeviationSentinel
                    this.S{i}.SyncData.ReferenceTime = tX0 - this.StreamTimeDeviationSentinel;
                    error('FAULT: Stream %s reference time underrun', this.S{i}.Name)
                end
            end

            % Measure how much most recent data points of streams are falling behind and leading forward
            %   in regards to main stream.
            % Used for logic to temporary speed up non-main streams to
            %   consume excessive data.
            tX1 = tX0 + this.S{1}.TimeLen;
            for i = 2 : length(this.S)
                tY1 = this.S{i}.SyncData.ReferenceTime + this.S{i}.TimeLen;

                this.S{i}.SyncData.EndTimeDeviationSum = this.S{i}.SyncData.EndTimeDeviationSum + (tY1 - tX1);
                this.S{i}.SyncData.EndTimeDeviationN = this.S{i}.SyncData.EndTimeDeviationN + 1;
            end

            % Every once in a while, adjust the sampling frequency on non-main streams,
            %   as if the SF is not very precise.
            % TODO: Improve this part and make it bullet proof!
            KX = this.S{1}.SyncData.SFASampleCountStatistics;
            if KX > this.S{1}.SF * this.SFAPeriod
                this.S{1}.SyncData.SFASampleCountStatistics = 0; %reset
            
                % Estimate SF on other streams.
                for i = 2 : length(this.S)
                    KY = this.S{i}.SyncData.SFASampleCountStatistics;
                    this.S{i}.SyncData.SFASampleCountStatistics = 0;  %reset
                    SF = this.S{i}.SF;

                    Dev = this.S{i}.SyncData.EndTimeDeviationSum / max(this.S{i}.SyncData.EndTimeDeviationN, 1);
                    this.S{i}.SyncData.EndTimeDeviationSum = 0;
                    this.S{i}.SyncData.EndTimeDeviationN = 0;

                    if this.S{i}.SyncData.SFAAdjustingForEndTimeDeviation
                        % End the current adjustment because of time
                        % ref deviation. Don't take further action
                        this.S{i}.SyncData.SFAAdjustingForEndTimeDeviation = false;
                        this.S{i}.SF = this.S{i}.OriginalSF;

                    elseif Dev > this.SFATimeDeviationThreshold
                        % There is a big deviation on time of
                        % the latest received sample, between this stream and
                        % main stream.
                        % Temporarily adjust the SF so that the time
                        % deviation resolves in a few seconds.
                        % Dev should be resolved in SFAPeriod.
                        EstSF = SF * (1 + Dev / this.SFAPeriod);
                        EstSF = ClampAB(EstSF, this.S{i}.OriginalSF * this.SFASpeedUpMax, this.S{i}.OriginalSF * this.SFASlowDownMin);
                        this.S{i}.SF = EstSF;
                        this.S{i}.SyncData.SFAAdjustingForEndTimeDeviation = true;
                    elseif Dev < -this.SFATimeDeviationThreshold
                        % Same as above, but falling behind
                        if Dev > -this.SFAPeriod * 0.5
                            % Same as above
                            EstSF = SF * (1 + Dev / this.SFAPeriod);
                            EstSF = ClampAB(EstSF, this.S{i}.OriginalSF * this.SFASpeedUpMax, this.S{i}.OriginalSF * this.SFASlowDownMin);
                            this.S{i}.SF = EstSF;
                            this.S{i}.SyncData.SFAAdjustingForEndTimeDeviation = true;
                        else
                            % This stream is falling too much behind. There
                            % should be a different problem.
                            warning('Stream %s is falling behind', this.S{i}.Name)
                        end
                    else
                        % There could be somewhat deviation in sampling frequency.
                        EstSF = KY / KX * this.S{1}.SF;
                        EstSFRatio = EstSF / SF;
                        if abs(EstSFRatio - 1) < this.SFADeviationThreshold
                            % Negligible
                        else
                            % Put a limit on the estimation SF.
                            EstSF = ClampAB(EstSF, this.S{i}.OriginalSF * this.SFASpeedUpMax, this.S{i}.OriginalSF * this.SFASlowDownMin);
        
                            % Adjust
                            NewSF = SF * (1 - this.SFASpeedUpDownTendency) + EstSF * this.SFASpeedUpDownTendency;
                            this.S{i}.SF = NewSF;
                        end
                    end

                    %disp([this.S{i}.SyncData.SFAAdjustingForEndTimeDeviation Dev this.S{i}.SF])
                end
            end
        end
    end
end

