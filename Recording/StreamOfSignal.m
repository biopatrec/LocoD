%StreamOfSignal stores a circular buffer of a signal with a certain maximum
%size, and certain number of channels.
classdef StreamOfSignal < handle
    properties (Access = public)
        Name = ''
        NumCh = 0
        SF = 0
        OriginalSF = 0
        SyncData = struct() % User custom data

        % Here we are implementing a circular buffer
        SigBufAlloc = 0
        SigBufLen = 0
        SigBufWrPtr = 0
        SigBufRdPtr = 0
        SigBuf = []
    end

    properties (Dependent)
        TimeLen
    end

    methods
        function t = get.TimeLen(this)
            t = this.SigBufLen / this.SF;
        end

        function Initialize(this, Name, NumCh, SF, AllocLen)
            this.Name = Name;
            this.NumCh = NumCh;
            this.SF = SF;
            this.OriginalSF = SF;
            this.SyncData = struct();
            this.SigBufAlloc = AllocLen;
            this.SigBufLen = 0;
            this.SigBufWrPtr = 0;
            this.SigBufRdPtr = 0;
            this.SigBuf = zeros(NumCh, this.SigBufAlloc);
        end

        function Clear(this)
            this.SigBufLen = 0;
            this.SigBufWrPtr = 0;
            this.SigBufRdPtr = 0;
        end

        function DiscardChunk(this, ChunkLen)
            if ChunkLen > this.SigBufLen
                ChunkLen = this.SigBufLen;
            end

            if this.SigBufRdPtr + ChunkLen >= this.SigBufAlloc
                % Two rounds
                C1 = this.SigBufAlloc - this.SigBufRdPtr;
                C2 = ChunkLen - C1;
                this.SigBufRdPtr = C2;
            else
                % One round
                this.SigBufRdPtr = this.SigBufRdPtr + ChunkLen;
            end

            this.SigBufRdPtr = mod(this.SigBufRdPtr, this.SigBufAlloc); % SENTINEL
            this.SigBufLen = this.SigBufLen - ChunkLen;
        end

        function Chunk = PeekChunk(this, ChunkLen)
            % See the future
            if ChunkLen > this.SigBufLen
                ChunkLen = this.SigBufLen;
            end

            Chunk = zeros(this.NumCh, ChunkLen);

            if this.SigBufRdPtr + ChunkLen >= this.SigBufAlloc
                % Two rounds
                C1 = this.SigBufAlloc - this.SigBufRdPtr;
                C2 = ChunkLen - C1;
                Chunk(:, 1 : C1) = this.SigBuf(:, this.SigBufRdPtr + 1 : this.SigBufAlloc);
                Chunk(:, C1 + 1:ChunkLen) = this.SigBuf(:, 1 : C2);
            else
                % One round
                Chunk(:, 1:ChunkLen) = this.SigBuf(:, this.SigBufRdPtr + 1 : this.SigBufRdPtr + ChunkLen);
            end
        end

        function Chunk = PopChunk(this, ChunkLen)
            if ChunkLen > this.SigBufLen
                ChunkLen = this.SigBufLen;
            end

            Chunk = zeros(this.NumCh, ChunkLen);

            if this.SigBufRdPtr + ChunkLen >= this.SigBufAlloc
                % Two rounds
                C1 = this.SigBufAlloc - this.SigBufRdPtr;
                C2 = ChunkLen - C1;
                Chunk(:, 1 : C1) = this.SigBuf(:, this.SigBufRdPtr + 1 : this.SigBufAlloc);
                Chunk(:, C1 + 1:ChunkLen) = this.SigBuf(:, 1 : C2);

                % Also move pointer
                this.SigBufRdPtr = C2;
                this.SigBufRdPtr = mod(this.SigBufRdPtr, this.SigBufAlloc); % SENTINEL
            else
                % One round
                Chunk(:, 1:ChunkLen) = this.SigBuf(:, this.SigBufRdPtr + 1 : this.SigBufRdPtr + ChunkLen);

                % Also move pointer
                this.SigBufRdPtr = this.SigBufRdPtr + ChunkLen;
                this.SigBufRdPtr = mod(this.SigBufRdPtr, this.SigBufAlloc); % SENTINEL
            end

            this.SigBufLen = this.SigBufLen - ChunkLen;
        end

        function [NumNewSample, Overflow] = PushChunk(this, Chunk, DiscardExcessOldData)
            Overflow = false;
            [ChunkNumCh, ChunkLen] = size(Chunk);
            if ChunkNumCh ~= this.NumCh
                % Sentinel
                error('Invalid Chunk size')
            end

            if ChunkLen > this.SigBufAlloc
                % Toooo much data
                ChunkLen = this.SigBufAlloc;
                Overflow = true;
                if DiscardExcessOldData
                    % Throw away older part
                    Chunk = Chunk(:, end - ChunkLen + 1 : end);
                else
                    % Throw away newer part
                    Chunk = Chunk(:, 1 : ChunkLen);
                end
            end

            if ChunkLen + this.SigBufLen > this.SigBufAlloc
                % Overflow would occur
                Overflow = true;
                Excess = this.SigBufLen + ChunkLen - this.SigBufAlloc;
                if DiscardExcessOldData
                    % Throw away old data
                    this.SigBufRdPtr = mod(this.SigBufRdPtr + Excess, this.SigBufAlloc);
                    this.SigBufLen = this.SigBufLen - Excess;  
                else
                    % Cut excess of new data
                    ChunkLen = ChunkLen - Excess;
                    Chunk = Chunk(:, 1 : ChunkLen);
                end
            end

            % Copy data to buffer
            % It could take maximum two rounds to move the full data,
            % in case in the first round the WrPtr rolls over.
            NumNewSample = ChunkLen;

            this.SigBufLen = this.SigBufLen + ChunkLen;

            if ChunkLen == 0
                % Nothing to do.
                return
            end

            if this.SigBufWrPtr + ChunkLen >= this.SigBufAlloc
                % Two rounds
                C1 = this.SigBufAlloc - this.SigBufWrPtr;
                C2 = ChunkLen - C1;
                this.SigBuf(:, this.SigBufWrPtr + 1 : this.SigBufAlloc) = Chunk(:, 1 : C1);
                this.SigBuf(:, 1 : C2) = Chunk(:, C1 + 1:ChunkLen);
                this.SigBufWrPtr = C2;
                this.SigBufWrPtr = mod(this.SigBufWrPtr, this.SigBufAlloc); % SENTINEL
            else
                % One round
                this.SigBuf(:, this.SigBufWrPtr + 1 : this.SigBufWrPtr + ChunkLen) = Chunk(:, 1:ChunkLen);
                this.SigBufWrPtr = this.SigBufWrPtr + ChunkLen;
                this.SigBufWrPtr = mod(this.SigBufWrPtr, this.SigBufAlloc); % SENTINEL
            end
        end
    end
end

