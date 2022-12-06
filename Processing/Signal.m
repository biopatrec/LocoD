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
% This is the third class of out of 4 main class of LocoD and every thing
%%related to the recorded raw signal is here
% Also there are some get functions to for example get number of samples or
% number of tags
%
% --------------------------Updates--------------------------
% 2022-03-15 / Bahareh Ahkami / Creation



classdef Signal < handle
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        recProps RecordingProperties
        
        % === Original (storage) Signal Content ===
        % Signal channels: EMG1 EMG2 ... EMGn PS IMU1 IMU2 ... IMUm
        signal=[];
        tags=[];
        originalPressureSignal=[];

        % === Derived (run-time) Signal Content ===
        PredictedtagsOnline=[];
        TrueLabelsOnline=[];
        GaitTransitionsOnline=[];
    end

    properties (Transient) % transient stuff are not saved in a file.
        % === Callbacks ===
        onSignalCallback function_handle;
        onSignalClean function_handle;
        onAddGroundTruthTag function_handle;

        % === Other transient stuff ===
        filename=[];
    end
    
    methods
        function this=Signal(recProps)
            this.recProps=recProps;
            
        end
        
        function ClearSignal(this)
            this.signal=[];
            this.tags = [];
            this.originalPressureSignal=[];
            
            %~~this.indexTagsOnline = 0;
            %~~this.indexTags = 0;
            %~~this.tagNames = [];
            %~~this.tagNamesOnline = [];
            this.PredictedtagsOnline=[];
            this.TrueLabelsOnline=[];
            this.GaitTransitionsOnline=[];
            
            if ~isempty(this.onSignalClean)
                try
                    this.onSignalClean(this);
                catch Ex
                    gprlog('* Exception in onSignalClean: %s', GetExceptionSummary(Ex));
                end
            end
        end
        
        function success = AppendSignal(this, numNewSample, allChannelData)
            success = 0;
            
            % SENTINEL
            % newsig should be array of double of size (nCh x numNewSample).
            if any(size(allChannelData) ~= [this.recProps.UnmaskedNumAllCh numNewSample])
                gprlog('* AppendSignal: Invalid newsig size')
                return
            end
            
            if isempty(this.onSignalCallback)
                gprlog('* AppendSignal: Callback must be set!')
                return
            end

            % It is a good time to hard-limit the Pressure Sensor.
            if this.recProps.UnmaskedHasPS==1
                NewPS = allChannelData(this.recProps.UnmaskedIdxPS, :);
                %plot(NewPS)

                % 8 and 9 are stance and swing codes
                NewPSHardLimit = 8 + 1 * (NewPS < this.recProps.PressureThreshold);

                % Replace with hard limited version.
                allChannelData(this.recProps.UnmaskedIdxPS, :) = NewPSHardLimit;
            end

            % Put new signal chunk in the big array
            [~, oldNumSample] = size(this.signal);
            this.signal(:,oldNumSample + 1:oldNumSample+numNewSample) = allChannelData;

            % Good idea to keep the original version of PS also
            if this.recProps.UnmaskedHasPS==1
                this.originalPressureSignal(oldNumSample + 1:oldNumSample+numNewSample) = NewPS;
                %plot( this.originalPressureSignal)
            end
            % ... and we call the data callback
            try
                this.onSignalCallback(this, numNewSample);
            catch Ex
                gprlog('* Exception in onSignalCallback: %s', GetExceptionSummary(Ex));
            end

            success = 1;
        end
      
        
        %% Get functions
        function NumSample=GetNumSample(this)
            [~, NumSample] = size(this.signal);    
        end
        function tagcounter=GetNumTags(this)
            tagcounter=size(this.tags,2);
        end
        function pressurethreshold=GetSizePressureThreshold(this)
            % pressurethresholdnum=size(this.preshthresh,2);
            error('NYI')
        end
        
        function [t_moment]=GetTime(this)
            [~, totalSamples] = size(this.signal);
            t_moment=(totalSamples-1)/ this.recProps.SamplingFreq;
        end
        
        function [t,t_moment]=GetTimeSeries(this)
            [~, totalSamples] = size(this.signal);
            t = (0:totalSamples-1) / this.recProps.SamplingFreq;
            t_moment=(totalSamples-1)/ this.recProps.SamplingFreq;
        end
        
        %% Add Tags
        function AddGroundTruthTags(this,type,time)
            tagCount=this.GetNumTags();
            
            if size(this.tags, 2) > 0
                latestTagTime = this.tags(2, end);
                if time < latestTagTime
                    % Technically should not get here.
                    gprlog(['*Critical error: AddGroundTruthTags(): The added tag should' ...
                        ' cannot be placed before the previous tag.'])
                    return
                end
            end

            tagInfo = [type time];
            this.tags(1:2,tagCount+1) = tagInfo;

            if ~isempty(this.onAddGroundTruthTag)
                try
                    this.onAddGroundTruthTag(this, tagInfo);
                catch Ex
                    gprlog('* Exception in onAddGroundTruthTag: %s', GetExceptionSummary(Ex));
                end
            end
        end
   
        function AddPressureThresh(this,type,time)
            PreshCounter=this.GetSizePressureThreshold();
            this.preshthresh(1:2,PreshCounter+1)=[type time];
        end
        
        %% Save
        function SaveData(this)
            
            % Avoid saving useless stuff!
            signalCopy = Signal(this.recProps.MakeSignalInfoCopy('all'));
            
            % Only copy stuff you need!
            signalCopy.signal = this.signal;
            signalCopy.tags=this.tags;
            signalCopy.originalPressureSignal=this.originalPressureSignal;
            signalCopy.filename=[];
            signalCopy.PredictedtagsOnline=this.PredictedtagsOnline;
            signalCopy.TrueLabelsOnline=this.TrueLabelsOnline;
            signalCopy.GaitTransitionsOnline=this.GaitTransitionsOnline;
           
            % Save
            locoDDir = fileparts(which('LocoD.m'));
            if isempty(locoDDir)
                error('Cannot find LocoD root directory!')
            end
            [~,~] = mkdir([locoDDir '/SavedData']);
            uisave('signalCopy', [locoDDir '/SavedData/gprdata.mat'])
        end
        
    end
    methods(Static)
        function [fullpath,filename]=GetLoadSignalFileName(dialogtitle)
            locoDDir = fileparts(which('LocoD.m'));
            if isempty(locoDDir)
                error('Cannot find LocoD root directory!')
            end
            [filename, path] = uigetfile([locoDDir '/SavedData/*'], dialogtitle,'MultiSelect','off');

            fullpath = fullfile(path, filename);
        end

        function loadedSig=LoadSignal()
            [fullpath, filename] = Signal.GetLoadSignalFileName('Select signal to load');
            if isempty(fullpath)
                gprlog('* LoadSignal: No file selected')
                loadedSig = [];
                return
            end
            loadedSig=load(fullpath);
            if ~isfield(loadedSig, 'signalCopy') || ~isa(loadedSig.signalCopy, 'Signal')
                gprlog('* LoadSignal: Invalid input file -- Not Signal')
                loadedSig = [];
                return
            end
            loadedSig.signalCopy.filename=filename;
            loadedSig = loadedSig.signalCopy;
        end
        
    end
end

