classdef OnlineProcessing < handle


    properties
        %Online Processing
        ProcessedPointer=0;  %An indicator that how much of online data has been processed
        offlineProcessing Decoding;
        onlineRecsess RecordingFunctions;

        debug_nClassifyWindowsWeHave=0;

        PrevLabelePredicted=3;
        PredictedLabelAll=[];
        LabelePredicted=3;
        MajorVoteHistory = [];
        TrueTagHistory=[];
        TrueTagLab=[];
        trueTags=[];
        numwindow;
        TrueLabels=[];

    end
    methods
        function this = OnlineProcessing(offlineProcessing,onlineRecsess)
            this.offlineProcessing=offlineProcessing;
            this.onlineRecsess=onlineRecsess;
        end


        function ProcessWindows(this, availableData, gaitPhase, samplePoint)
            FS = this.offlineProcessing.rp.SamplingFreq;
            WindowAfter=this.offlineProcessing.AfterEvent*FS;
            WindowBefore=this.offlineProcessing.BeforeEvent*FS;
            EMGFilterType=this.offlineProcessing.FilterType;
            IMUFilterType=this.offlineProcessing.IMUFilterType;
            rp=this.offlineProcessing.rp;

            %Filter signal
            filtered = availableData;
            if EMGFilterType ~= "None"
                for i=1:length(EMGFilterType)
                    filtered=FilterSignal(rp.SamplingFreq,filtered,EMGFilterType(i),rp.IdxEMG);
                end
            end
            if IMUFilterType ~= "None" && this.offlineProcessing.rp.HasIMU==1
                for i=1:length(IMUFilterType)
                   filtered=FilterSignal(rp.SamplingFreq,filtered,IMUFilterType(i),rp.IdxIMU);
                end
            end
            availableData=filtered;

            % ...
            this.debug_nClassifyWindowsWeHave = this.debug_nClassifyWindowsWeHave + 1;
            datalength=WindowAfter+WindowBefore;
            Inctime=this.offlineProcessing.IncTime;
            windowlength=this.offlineProcessing.WindowLength;
            sf=this.offlineProcessing.rp.SamplingFreq;
            this.numwindow= floor(((datalength/sf-windowlength)/Inctime)+1); %finding number of windows when we have windows with increment
            % if transitionPoint-WindowBefore>1
            for w=1:this.numwindow

                window= availableData(:,(w-1)*Inctime*sf+1:windowlength*sf+(w-1)*Inctime*sf);  %Available data with incremented windwing
                this.LabelePredicted=this.ClassifyExtractedWindows(window,gaitPhase,this.PrevLabelePredicted);  %Predict label
                this.MajorVoteHistory = [this.LabelePredicted, this.MajorVoteHistory];

            end

            %Mode of predicted tags included in majority vote
            MajorVote = mode(this.MajorVoteHistory);

            % Store classification history
            this.LabelePredicted = MajorVote;
            this.PrevLabelePredicted=this.LabelePredicted;
            this.PredictedLabelAll = [this.PredictedLabelAll, ...
                [this.LabelePredicted; samplePoint]];
            this.MajorVoteHistory=[];
        end

        function LabelePredicted=ClassifyExtractedWindows(this,window,phase,PrevLabelePredicted)

            %% Feature extraction
            testfeature=GetFeaturesEachWindow(window,this.offlineProcessing.rp,this.offlineProcessing.FetureSet,"EMG");
            if this.offlineProcessing.IfProcessIMU==1
                testfeature_IMU=GetFeaturesEachWindow(window,this.offlineProcessing.rp,this.offlineProcessing.IMUFetureSet,"IMU");
                testfeature=[testfeature,testfeature_IMU];
            end
            if this.offlineProcessing.IfProcessPS==1
                testfeature_PS=GetFeaturesEachWindow(window,this.offlineProcessing.rp,this.offlineProcessing.IMUFetureSet,"PS");
                testfeature=[testfeature,testfeature_PS];
            end
            %% Classification
            if phase=="Swing"
                if this.offlineProcessing.ClassifierArchitecture=="All data-Phase dependant"
                    LabelePredicted = predict(this.ClassifierModel{1}, testfeature);
                elseif  this.offlineProcessing.ClassifierArchitecture=="Mode-Specific"|| this.offlineProcessing.ClassifierArchitecture=="Mode-Specific-PhaseDependant"
                    LabelePredicted= ModeSpecificOnline(testfeature,phase,PrevLabelePredicted,this.offlineProcessing.ClassifierModel,this.offlineProcessing.ClassifierArchitecture);
                end
            elseif phase=="Stance"
                if this.offlineProcessing.ClassifierArchitecture=="All data-Phase dependant"
                    LabelePredicted = predict(this.offlineProcessing.ClassifierModel{2}, testfeature);
                elseif  this.offlineProcessing.ClassifierArchitecture=="Mode-Specific" || this.offlineProcessing.ClassifierArchitecture=="Mode-Specific-PhaseDependant"
                    LabelePredicted= ModeSpecificOnline(testfeature,phase,PrevLabelePredicted,this.offlineProcessing.ClassifierModel,this.offlineProcessing.ClassifierArchitecture);
                end
            else
                error("Invalid Mode: %s",phase);
            end
        end

        function onlineaccu=OnlineAccuracy(this,trueLab,Transitions)
            rp=this.offlineProcessing.rp;
            proc=this.offlineProcessing;
            %RepPredictedLabs=repelem(this.PredictedLabelAll,1,this.numwindow);
            
            this.TrueLabels=ProcessTags(trueLab,Transitions,rp.SamplingFreq);
            %RepPredictedLabs=RepPredictedLabs(:,RepPredictedLabs(2,:)<TrueLabels(2,end));
            %RepPredictedLabs=RepPredictedLabs(:,RepPredictedLabs(2,:)>=TrueLabels(2,1));
            onlineaccu=sum((this.TrueLabels(1,:))==this.PredictedLabelAll(1,:))/length(this.PredictedLabelAll);
            
        end

        function Reset(this)
            this.MajorVoteHistory = [];
            this.PredictedLabelAll=[];
            this.TrueLabels=[];
            this.debug_nClassifyWindowsWeHave = 0;

            % TODO: Do we need these?
            this.PrevLabelePredicted=3;
            this.LabelePredicted=3;
            this.TrueTagHistory=[];
            this.TrueTagLab=[];
            this.trueTags=[];
            this.numwindow=0;
        end
    end
end