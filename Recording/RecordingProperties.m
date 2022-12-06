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
%This is the first class in the 4 main class of this program
%The idea behind it is to have all the variables related to the signal and
%recording in one place, forexmple name of device, communication way,
%number of channels, etc
% --------------------------Updates--------------------------
% 2022-03-15 / Bahareh Ahkami / Creation

classdef RecordingProperties < handle
    properties (Access = public)
        % ==== 1. I/O Device Information ====
        Device string = '';
        ComType string = '';
        IMU_Device string = '';
        IMU_ComType string = '';
        IMU_ChannelNames='';


        % for Device = prerecorded
        prerecFileData = [];
        originalFileName = '';

        % ==== 2. Annotation ==== 
        % TODO: IMU_ChannelNames = {};

        % ==== 3. Signal Specifications ==== 
        PressureThreshold double = 0; 
        IMU_SamplingFreq double = 50;
        SamplingFreq double = 50;


        % ==== 4. Aggregate Statistics ====
        RoundNum double = 0;
    end

    properties (Access = private)
        % ==== 5. Channel Transposition Settings ==== 
        % for Device = Delsys, dummy, prerecorded
        channelSelectionEMG=[];
        channelSelectionIMU=[];
        channelSelectionPS=[];

        % ==== 6. Channel mask out settings ====
        % Mask vector looks like logical([1 1 1 0 0 1 1 ...])
        m_maskChEnable logical = 0;
        m_maskChMask = []; 
    end

    properties (Transient, Access = private)
        % ==== 7. Channel post transposition configuration
        m_numAllCh int32 = 0;
        m_numPSCh int32 = 0;
        m_numEMGCh int32 = 0;
        m_numIMUCh int32 = 0;
        m_numEMGPSCh int32 = 0;
        m_hasPS logical = 0;
        m_hasIMU logical = 0;
        m_hasEMG logical = 0;
        m_idxPS = [];
        m_idxEMG = [];
        m_idxIMU = [];
        m_idxAll = [];

        m_unmaskedNumAllCh int32 = 0;
        m_unmaskedNumPSCh int32 = 0;
        m_unmaskedNumEMGCh int32 = 0;
        m_unmaskedNumIMUCh int32 = 0;
        m_unmaskedNumEMGPSCh int32 = 0;
        m_unmaskedHasPS logical = 0;
        m_unmaskedHasIMU logical = 0;
        m_unmaskedHasEMG logical = 0;
        m_unmaskedIdxPS = [];
        m_unmaskedIdxEMG = [];
        m_unmaskedIdxIMU = [];
        m_unmaskedIdxAll = [];
    end

    properties (Transient, Access = private)
        % ==== 7. Channel post transposition configuration
        m_chConfigCached logical = 0;
        m_unmaskedChConfigCached logical = 0;
    end

    properties (Dependent)
        % ==== 5 (cont). Channel transposition settings
        ChannelSelectionEMG
        ChannelSelectionIMU
        ChannelSelectionPS
    end

    properties (Dependent)
        % ==== 7. Channel post-transposition configuration
        % Counts of Channels
        NumAllCh
        NumEMGCh
        NumPSCh
        NumEMGPSCh
        NumIMUCh
        HasPS
        HasIMU
        HasEMG

        % Channel Indices in recorded signal
        IdxPS
        IdxEMG
        IdxIMU
        IdxAll

        % Same settings but with masking bypassed
        UnmaskedNumAllCh
        UnmaskedNumEMGCh
        UnmaskedNumPSCh
        UnmaskedNumEMGPSCh
        UnmaskedNumIMUCh
        UnmaskedHasPS
        UnmaskedHasIMU
        UnmaskedHasEMG
        UnmaskedIdxPS
        UnmaskedIdxEMG
        UnmaskedIdxIMU
        UnmaskedIdxAll
    end
    
    properties (Access = private)
        RandomId = 0;
    end 

    methods (Access = public)
        function UnmaskedGatherPostTranspositionChannelConfig(this)
            % !@! MINEZONE
            if this.m_unmaskedChConfigCached
                % This info already cached
                return
            end
            this.m_unmaskedNumAllCh = length(this.channelSelectionIMU) + length(this.channelSelectionPS) + length(this.channelSelectionEMG);
            this.m_unmaskedHasPS = ~isempty(this.channelSelectionPS);
            this.m_unmaskedHasEMG = ~isempty(this.channelSelectionEMG);
            this.m_unmaskedHasIMU = ~isempty(this.channelSelectionIMU);
            this.m_unmaskedNumEMGCh = length(this.channelSelectionEMG);
            this.m_unmaskedNumPSCh = length(this.channelSelectionPS);
            this.m_unmaskedNumEMGPSCh = length(this.channelSelectionPS) + length(this.channelSelectionEMG);
            this.m_unmaskedNumIMUCh = length(this.channelSelectionIMU);
            this.m_unmaskedIdxEMG = 1:this.m_unmaskedNumEMGCh;
            this.m_unmaskedIdxPS = (this.m_unmaskedNumEMGCh + 1) : (this.m_unmaskedNumEMGCh + this.m_unmaskedNumPSCh);
            this.m_unmaskedIdxIMU = (this.m_unmaskedNumEMGCh + this.m_unmaskedNumPSCh + 1) : ...
                (this.m_unmaskedNumEMGCh + this.m_unmaskedNumPSCh + this.m_unmaskedNumIMUCh);
            this.m_unmaskedIdxAll = 1 : this.m_unmaskedNumAllCh;
            this.m_unmaskedChConfigCached = 1;
        end

        function GatherPostTranspositionChannelConfig(this)
            % !@! MINEZONE
            if this.m_chConfigCached
                % This info already cached
                return
            end
            this.UnmaskedGatherPostTranspositionChannelConfig()

            % Mask out post transposition channel indices
            if this.m_maskChEnable == 0
                M = ones(1, this.m_unmaskedNumAllCh); 
            else
                M = this.m_maskChMask;
            end

            % Maksed = Unmasked( logical( Mask(Unmasked) ) )
            % Example:
            %    U = [5 6 7];
            %    M = [1 1 1 1 0 0 1 1 1];
            %    C = U(logical(M(U)));
            %    ==> U == [7]
            this.m_idxEMG = this.m_unmaskedIdxEMG(logical(M(this.m_unmaskedIdxEMG)));
            this.m_idxPS = this.m_unmaskedIdxPS(logical(M(this.m_unmaskedIdxPS)));
            this.m_idxIMU = this.m_unmaskedIdxIMU(logical(M(this.m_unmaskedIdxIMU)));
            this.m_idxAll = [this.m_idxEMG, this.m_idxPS, this.m_idxIMU];
            this.m_hasEMG = ~isempty(this.m_idxEMG);
            this.m_hasPS = ~isempty(this.m_idxPS);
            this.m_hasIMU = ~isempty(this.m_idxIMU);
            this.m_numAllCh = length(this.m_idxAll);
            this.m_numEMGCh = length(this.m_idxEMG);
            this.m_numEMGPSCh = length(this.m_idxEMG) + length(this.m_idxPS);
            this.m_numIMUCh = length(this.m_idxIMU);
            this.m_numPSCh = length(this.m_idxPS);
            this.m_chConfigCached = 1;
        end

        function BeforeChangeChannelTransposition(this)
            if this.m_maskChEnable
                error('RecProps: cannot change ChannelSelectionXYZ when channel mask (subset) is enabled')
            end
            if ~strcmp(this.Device, 'DELSYS_Trigno') && ~strcmp(this.Device, 'prerecorded') && ~strcmp(this.Device, 'dummy')
                error('RecProps: cannot set channel transposition settings for device type %s', this.Device)
            end

            % Uncache
            this.m_unmaskedChConfigCached = 0;
        end
    end
    
    methods
        % === 7. Channel post transposition config (masked)
        function n = get.NumAllCh(this)
            this.GatherPostTranspositionChannelConfig()
            n = this.m_numAllCh;
        end

        function n = get.NumEMGCh(this)
            this.GatherPostTranspositionChannelConfig()
            n = this.m_numEMGCh;
        end

        function n = get.NumEMGPSCh(this)
            this.GatherPostTranspositionChannelConfig()
            n = this.m_numEMGPSCh;
        end

        function n = get.NumPSCh(this)
            this.GatherPostTranspositionChannelConfig()
            n = this.m_numPSCh;
        end
        function n = get.NumIMUCh(this)
            this.GatherPostTranspositionChannelConfig()
            n = this.m_numIMUCh;
        end

        function i = get.IdxEMG(this)
            this.GatherPostTranspositionChannelConfig()
            i = this.m_idxEMG;
        end

        function i = get.IdxPS(this)
            this.GatherPostTranspositionChannelConfig()
            i = this.m_idxPS;
        end

        function i = get.IdxIMU(this)
            this.GatherPostTranspositionChannelConfig()
            i = this.m_idxIMU;
        end

        function i = get.IdxAll(this)
            this.GatherPostTranspositionChannelConfig()
            i = this.m_idxAll;
        end

        function n = get.HasEMG(this)
            this.GatherPostTranspositionChannelConfig()
            n = this.m_hasEMG;
        end

        function n = get.HasPS(this)
            this.GatherPostTranspositionChannelConfig()
            n = this.m_hasPS;
        end

        function n = get.HasIMU(this)
            this.GatherPostTranspositionChannelConfig()
            n = this.m_hasIMU;
        end
    
        function types = GetChannelTypes(this)
            types = -1 * ones(1, this.m_unmaskedNumAllCh); % Pay attention!
            if this.HasEMG
                types(this.IdxEMG) = 0;
            end
            if this.HasPS
                types(this.IdxPS) = 1;
            end
            if this.HasIMU
                types(this.IdxIMU) = 2;
            end
        end

        % === 7. Channel post transposition config (Unmasked)
        function n = get.UnmaskedNumAllCh(this)
            this.UnmaskedGatherPostTranspositionChannelConfig()
            n = this.m_unmaskedNumAllCh;
        end

        function n = get.UnmaskedNumEMGCh(this)
            this.UnmaskedGatherPostTranspositionChannelConfig()
            n = this.m_unmaskedNumEMGCh;
        end

        function n = get.UnmaskedNumEMGPSCh(this)
            this.UnmaskedGatherPostTranspositionChannelConfig()
            n = this.m_unmaskedNumEMGPSCh;
        end

        function n = get.UnmaskedNumPSCh(this)
            this.UnmaskedGatherPostTranspositionChannelConfig()
            n = this.m_unmaskedNumPSCh;
        end

        function n = get.UnmaskedNumIMUCh(this)
            this.UnmaskedGatherPostTranspositionChannelConfig()
            n = this.m_unmaskedNumIMUCh;
        end

        function i = get.UnmaskedIdxEMG(this)
            this.UnmaskedGatherPostTranspositionChannelConfig()
            i = this.m_unmaskedIdxEMG;
        end

        function i = get.UnmaskedIdxPS(this)
            this.UnmaskedGatherPostTranspositionChannelConfig()
            i = this.m_unmaskedIdxPS;
        end

        function i = get.UnmaskedIdxIMU(this)
            this.UnmaskedGatherPostTranspositionChannelConfig()
            i = this.m_unmaskedIdxIMU;
        end

        function i = get.UnmaskedIdxAll(this)
            this.UnmaskedGatherPostTranspositionChannelConfig()
            i = this.m_unmaskedIdxAll;
        end

        function n = get.UnmaskedHasEMG(this)
            this.UnmaskedGatherPostTranspositionChannelConfig()
            n = this.m_unmaskedHasEMG;
        end

        function n = get.UnmaskedHasPS(this)
            this.UnmaskedGatherPostTranspositionChannelConfig()
            n = this.m_unmaskedHasPS;
        end

        function n = get.UnmaskedHasIMU(this)
            this.UnmaskedGatherPostTranspositionChannelConfig()
            n = this.m_unmaskedHasIMU;
        end
    
        function types = UnmaskedGetChannelTypes(this)
            types = -1 * ones(1, this.UnmaskedNumAllCh);
            if this.UnmaskedHasEMG
                types(this.UnmaskedIdxEMG) = 0;
            end
            if this.UnmaskedHasPS
                types(this.UnmaskedIdxPS) = 1;
            end
            if this.UnmaskedHasIMU
                types(this.UnmaskedIdxIMU) = 2;
            end
        end
        
        % ==== 6. Set/Get Channel mask out settings ====
        function ChannelMaskSet(this, mask)
            numCh = this.UnmaskedNumAllCh;
            if ~isvector(mask) || length(mask) ~= numCh
                error(['RecProps SetChannelMask: mask should be vector with same number of elements' ...
                    ' as number of channels'])
            end

            % Note: Convert to logical
            this.m_maskChMask = logical(mask);
            this.m_maskChEnable = 1;
            this.m_chConfigCached = 0; % uncache masked channel config
        end

        function m = ChannelMaskGet(this)
            if ~this.m_maskChEnable
                m = ones(1, this.UnmaskedNumAllCh);
            else
                m = this.m_maskChMask;
            end
        end

        function ChannelMaskInclusion(this, idx, include)
            this.m_chConfigCached = 0; % uncache masked channel config
            numCh = this.UnmaskedNumAllCh;

            if ~isvector(idx) || any(idx < 1) || any(idx > numCh)
                error('RecProps ChannelMaskInclusion: idx should be a vector of positive integer channel indices')
            end

            include = logical(include); % Note here!
            if this.m_maskChEnable == 0
                if include
                    % Initialize to zeros
                    this.m_maskChMask = zeros(1, numCh);
                else
                    % Initialize to ones
                    this.m_maskChMask = ones(1, numCh);
                end
                this.m_maskChEnable = 1;
            end
            this.m_maskChMask(idx) = include;
        end

        function b = ChannelMaskIsEnabled(this)
            b = this.m_maskChEnable;
        end

        function ChannelMaskUnset(this)
            this.m_maskChEnable = 0;
            this.m_chConfigCached = 0; % uncache masked channel config
        end

        % ==== 5. Set/Get Channel Transposition Settings ==== 
        function set.ChannelSelectionEMG(this, s)
            this.BeforeChangeChannelTransposition()
            this.channelSelectionEMG = s;
        end

        function set.ChannelSelectionIMU(this, s)
            this.BeforeChangeChannelTransposition()
            this.channelSelectionIMU = s;
        end

        function set.ChannelSelectionPS(this, s)
            this.BeforeChangeChannelTransposition()
            this.channelSelectionPS = s;
        end

        function s = get.ChannelSelectionEMG(this)
            s = this.channelSelectionEMG;
        end

        function s = get.ChannelSelectionIMU(this)
            s = this.channelSelectionIMU;
        end

        function s = get.ChannelSelectionPS(this)
            s = this.channelSelectionPS;
        end

        % === Other methods

        function Who(this)
            fprintf('This is a recording properties instance, device name is %s.\n', this.Device);
            disp(this);
        end

        function [compatible, txterror] = EnsureCompatibleWithOtherRecprops(this, that)
            txterror = '';
            compatible = 1;

            if isempty(txterror) && this.NumEMGCh ~= that.NumEMGCh
                txterror = 'Mismatching number of EMG channels';
                compatible = 0;
            end
            if isempty(txterror) && this.NumPSCh ~= that.NumPSCh
                txterror = 'Mismatching number of pressure sensor channels';
                compatible = 0;
            end
            if isempty(txterror) && this.NumIMUCh ~= that.NumIMUCh
                txterror = 'Mismatching number of IMU channels';
                compatible = 0;
            end
            if this.NumIMUCh > 0 && isempty(txterror) && this.IMU_SamplingFreq ~= that.IMU_SamplingFreq
                txterror = 'Mismatching IMU sampling frequency';
                compatible = 0;
            end
            if this.NumPSCh > 0 && isempty(txterror) && this.PressureThreshold ~= that.PressureThreshold
                txterror = 'Mismatching Pressure Threshold';
                compatible = 0;
            end
            if isempty(txterror) && this.SamplingFreq ~= that.SamplingFreq
                txterror = 'Mismatching sampling frequency';
                compatible = 0;
            end
        end
        
        function Verify(this)
            if this.NumAllCh == 0
                throw(MException('locod:InvalidRecProps', 'Absolutely no channels selected at all!'));
            end

            if strcmp(this.Device, 'DELSYS_Trigno')
                if this.SamplingFreq ~= 2000
                    throw(MException('LocoD:InvalidRecProps', 'DELSYS Sample Freq should be 2000!'));
                end
            elseif strcmp(this.Device, 'dummy')
                % Nothing to check
            elseif strcmp(this.Device, 'prerecorded')
                if isfield(this.prerecFileData, 'signalCopy') == 0
                    throw(MException('LocoD:InvalidRecProps', ['When opening a prerecorded signal file, ' ...
                        'the file must contain a Signal named signalCopy.']));
                end

                sig = this.prerecFileData.signalCopy;
                originRecProps = sig.recProps;

                % Ensure that channels to be extracted from source signal
                %   actually exist and are of the same type.
                if ~all(ismember([this.channelSelectionEMG], originRecProps.IdxEMG)) || ...
                   ~all(ismember([this.channelSelectionIMU], originRecProps.IdxIMU)) || ...
                   ~all(ismember([this.channelSelectionPS], originRecProps.IdxPS))
                    throw(MException('LocoD:InvalidRecProps', ...
                        ['When running off a prererecorded signal as input signal, ' ...
                        'channels that you select to be extracted should be a subset of ' ...
                        'those channels that already exist in the source signal.']));
                end

                % Have a look at the recording sample rate
                if this.SamplingFreq > originRecProps.SamplingFreq * 10 || ...
                   this.SamplingFreq < originRecProps.SamplingFreq * 0.1
                    throw(MException('LocoD:InvalidRecProps', ...
                        ['When running off a prererecorded signal as input signal, ' ...
                        'sample rate must be 0.1x up to 10x of the original sample rate.  ' ...
                        'Original sample rate will then be ignored.']));
                end

                % Have a look at pressure threshold
                if this.PressureThreshold ~= originRecProps.PressureThreshold
                    warning(['prerecorded recprops: Pressure Threshold is different between ' ...
                        'original recprops and replay recprops.'])
                end
            else
                throw(MException('LocoD:InvalidRecProps', 'Invalid recording device'));
            end
        end
        
        function recPropsCopy = MakeSignalInfoCopy(this, varargin)
            if nargin < 2
                error(['MakeSignalInfoCopy: varargin should be specified with a combination of: ' ...
                    'all, device, annotate, signalspec, stats, chtrans, mask'])
            end

            % Make a minimal copy that only contains
            % information regarding recording of the signal.
            recPropsCopy = RecordingProperties();
            
            % I/O
            if any(ismember({'all', 'device'}, varargin))
                recPropsCopy.Device = this.Device;
                recPropsCopy.IMU_Device = this.IMU_Device;
                recPropsCopy.ComType = this.ComType;            
                recPropsCopy.IMU_ComType = this.IMU_ComType;
    
                recPropsCopy.prerecFileData=this.prerecFileData;
                recPropsCopy.originalFileName=this.originalFileName;
            end

            % Signal Specs
            if any(ismember({'all', 'signalspec'}, varargin))
                recPropsCopy.SamplingFreq = this.SamplingFreq;
                recPropsCopy.PressureThreshold = this.PressureThreshold;
                recPropsCopy.IMU_SamplingFreq = this.IMU_SamplingFreq;
            end

            % Aggregate Statistics
            if any(ismember({'all', 'stats'}, varargin))
                recPropsCopy.RoundNum = this.RoundNum;
            end

            % Annotation
            if any(ismember({'all', 'annotate'}, varargin))
                % recPropsCopy.IMU_ChannelNames = this.IMU_ChannelNames;
            end

            % Channel Transposition Data
            if any(ismember({'all', 'chtrans'}, varargin))
                recPropsCopy.ChannelSelectionIMU = this.channelSelectionIMU;
                recPropsCopy.ChannelSelectionEMG = this.channelSelectionEMG;
                recPropsCopy.ChannelSelectionPS = this.channelSelectionPS;
            end

            % Mask
            if any(ismember({'all', 'mask'}, varargin))
                recPropsCopy.m_maskChEnable=this.m_maskChEnable;
                recPropsCopy.m_maskChMask=this.m_maskChMask;
            end
        end
    
        % Sample ctor
        function this = RecordingProperties(devName)
            if nargin == 0
                devName = '';
            end
            this.Device = devName;
            this.RandomId = randi([0 1000000]);
            fprintf('RecProp %d is born!!!\n', this.RandomId);
        end
        
        % Sample dtor
        function delete(this)
            fprintf('RecProp %d [%s] is deleted...\n', this.RandomId, this.Device);
        end

        % Apply channel mask to channel transposition directly
        function ApplyChannelMaskOntoChannelTransposition(this)
            error('* NYI')
        end
    end

    methods (Static)
        % Helper function to create RecProps for replaying from a file.
        function [new_recprops] = CreateReplayRecprops(fileName)
            try
                fprintf('Creating a replay recprops from file %s\n', fileName);
                fileData = load(fileName);
                original_recprops = fileData.signalCopy.recProps;

                % Create a recprops that resembles the same signal specs
                new_recprops = original_recprops.MakeSignalInfoCopy( ...
                    'signalspec','annotate');
                
                % Copy I/O device info:
                new_recprops.Device = 'prerecorded';
                new_recprops.prerecFileData = fileData;

                [~,new_recprops.originalFileName,~] = fileparts(fileName);

                % Make channel transposition info.
                % Specify that we take all channels from the input signal,
                %   and then we apply the channel mask.
                new_recprops.ChannelSelectionEMG = original_recprops.UnmaskedIdxEMG;
                new_recprops.ChannelSelectionIMU = original_recprops.UnmaskedIdxIMU;
                new_recprops.ChannelSelectionPS = original_recprops.UnmaskedIdxPS;
                new_recprops.ChannelMaskSet(original_recprops.ChannelMaskGet());

                % Done
            catch Ex
                gprlog('* Failed to create recprops for replay session: %s', GetExceptionSummary(Ex));
                rethrow(Ex);
            end
        end
    end
end

