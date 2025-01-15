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
        PredictedLabelsofWindows = [];
        ScoresofWindows=[];
        ScoresOfWindowsAll={};
        TrueTagLab=[];
        trueTags=[];
        numwindow;
        PostProcessingMethod="";
        PostProcessingThreshold=0;
        Postprocessorcaounter=0;
        NANcaounter=0;
        ClassNames=[];

    end
    methods
        function this = OnlineProcessing(offlineProcessing,onlineRecsess)
            this.offlineProcessing=offlineProcessing;
            this.onlineRecsess=onlineRecsess;
        end


        function ProcessWindows(this, windowBlock, gaitPhase, samplePoint)
            %global dbg_g_m
            %dbg_m = {};
            FS = this.offlineProcessing.rp.SamplingFreq;
            WindowAfter=this.offlineProcessing.AfterEvent*FS;
            WindowBefore=this.offlineProcessing.BeforeEvent*FS;
            EMGFilterType=this.offlineProcessing.FilterType;
            IMUFilterType=this.offlineProcessing.IMUFilterType;
            rp=this.offlineProcessing.rp;

            %Filter signal
            %dbg_m = [dbg_m, {gaitPhase}, {samplePoint}, {keyHash(windowBlock)}];
            filtered = windowBlock;
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
            windowBlock=filtered;
            %dbg_m = [dbg_m, {keyHash(windowBlock)}];
            % ...
            this.debug_nClassifyWindowsWeHave = this.debug_nClassifyWindowsWeHave + 1;
            datalength=WindowAfter+WindowBefore;
            Inctime=this.offlineProcessing.IncTime;
            windowlength=this.offlineProcessing.WindowLength;
            sf=this.offlineProcessing.rp.SamplingFreq;
            this.numwindow= floor(((datalength/sf-windowlength)/Inctime)+1); %finding number of windows when we have windows with increment
            % if transitionPoint-WindowBefore>1
            
            if this.PostProcessingMethod=="MajorityVote"
                %check the lable for each window in the extracted data
                for w=1:this.numwindow
                    window= windowBlock(:,(w-1)*Inctime*sf+1:windowlength*sf+(w-1)*Inctime*sf);  %Available data with incremented windwing
                    [this.LabelePredicted, ~]=this.ClassifyExtractedWindows(window,gaitPhase,this.PrevLabelePredicted);  %Predict label
                    this.PredictedLabelsofWindows = [this.LabelePredicted, this.PredictedLabelsofWindows];
                end
                %Mode of predicted tags included in majority vote
                ChoosenLabel = mode(this.PredictedLabelsofWindows);

            else
                for w=1:this.numwindow

                    window= windowBlock(:,(w-1)*Inctime*sf+1:windowlength*sf+(w-1)*Inctime*sf);  %Available data with incremented windwing
                    %Get the Scores from the output of LDA
                    [this.LabelePredicted, Score]=this.ClassifyExtractedWindows(window,gaitPhase,this.PrevLabelePredicted);  %Predict label
                    this.PredictedLabelsofWindows = [this.PredictedLabelsofWindows,this.LabelePredicted];
                    this.ScoresofWindows=[this.ScoresofWindows;Score];

                end
                NewWindowLabels=this.PredictedLabelsofWindows;
                toKeep = true(1, this.numwindow);
                if this.PostProcessingMethod=="ProbabilityBasedMajority"
                    %If we have probability based post processing
                    %Remove the windows the has probability below threshodl and
                    %do a majority vote on rest

                    %Remove it if the score is below the thrreshold for each
                    %window
                    for s = 1:this.numwindow
                        if max(this.ScoresofWindows(s, :)) <= this.PostProcessingThreshold
                            toKeep(s) = false; % Set to false to indicate that this element should be removed
                            this.Postprocessorcaounter=this.Postprocessorcaounter+1;
                            disp(['Number of times we had under Thresh :', num2str(this.Postprocessorcaounter)])
                        end
                    end
                    if sum(toKeep)~=0
                        NewWindowLabels = NewWindowLabels(toKeep);
                        this.ScoresofWindows=this.ScoresofWindows(toKeep,:);
                        ChoosenLabel=mode(NewWindowLabels); %Method 1
                        %If all of them are eliminated and majority vote is NAN
                        %choose the previouse lable as the lable
                    else %Nothing to keep
                        ChoosenLabel=this.PrevLabelePredicted;
                    end


                elseif this.PostProcessingMethod=="ProbabilityBasedMax"
                    %Remove the windows the has probability below threshold and
                    %then choose the class with maximum likelihood
                    for s = 1:this.numwindow
                        if max(this.ScoresofWindows(s, :)) <= this.PostProcessingThreshold
                            toKeep(s) = false; % Set to false to indicate that this element should be removed
                            this.Postprocessorcaounter=this.Postprocessorcaounter+1;
                            disp(['Number of times we had under Thresh :', num2str(this.Postprocessorcaounter)])
                        end
                    end
                    if sum(toKeep)~=0
                        NewWindowLabels = NewWindowLabels(toKeep);
                        this.ScoresofWindows=this.ScoresofWindows(toKeep,:);
                        
                        [~, linearIndex]=max(max(this.ScoresofWindows));
                        
                        ChoosenLabel=this.ClassNames(linearIndex);
            
                        
                        %If all of them are eliminated and majority vote is NAN
                        %choose the previouse lable as the lable
                    else %Nothing to kepp
                        ChoosenLabel=this.PrevLabelePredicted;
                    end
                elseif this.PostProcessingMethod=="ProbabilityBasedMeanMax"
                    % Remove the windows the has probability below threshold and
                    % then do the mean on the rest and choose the class with maximum likelihood
                    %% Method 3 Frist remove the ones lower thn threshold and then Look at the mean of probability for each window and choose the one with the highest mean
                    for s = 1:this.numwindow
                        if max(this.ScoresofWindows(s, :)) <= this.PostProcessingThreshold
                            toKeep(s) = false; % Set to false to indicate that this element should be removed
                            this.Postprocessorcaounter=this.Postprocessorcaounter+1;
                            disp(['Number of times we had under Thresh :', num2str(this.Postprocessorcaounter)])

                        end
                    end

                    % Create a new array with only the elements you want to keep
                    if sum(toKeep)~=0
                        NewWindowLabels = NewWindowLabels(toKeep);
                        this.ScoresofWindows=this.ScoresofWindows(toKeep,:);
                        %Find the mean
                        probMean = mean(this.ScoresofWindows);
                        %Find the class with the highest mean
                        [~,ChoosenLabelIndex] = max(probMean);
                        ChoosenLabel=this.ClassNames(ChoosenLabelIndex); %Method 3

                        %ChoosenLabel=mode(NewWindowLabels); %Method 1
                        %If all of them are eliminated and majority vote is NAN
                        %choose the previouse lable as the lable
                    else %Nothing to kepp
                        ChoosenLabel=this.PrevLabelePredicted;
                    end
                elseif this.PostProcessingMethod=="MeanMax"
                    %first find the mean of the likelihoods and then choose the
                    %highest one

                        [~, Index]=max(mean(this.ScoresofWindows));
                        
                        ChoosenLabel=this.ClassNames(Index);

                elseif this.PostProcessingMethod=="MeanMaxProbabilityBased"
                    %first find the mean of the likelihoods and then do the
                    %threshold if it was below do not make a decission and if
                    %it was more than threshold choose the highest class

                    

                    if max(mean(this.ScoresofWindows)) <= this.PostProcessingThreshold
                        ChoosenLabel=this.PrevLabelePredicted;
                    else
                        [~, Index]=max(mean(this.ScoresofWindows));
                        ChoosenLabel=this.ClassNames(Index);

                    end



                end


                % Create a new array with only the elements you want to keep

            end



            % Store classification history
            %dbg_m = [dbg_m, {ChoosenLabel}, {this.ScoresofWindows}];
            this.ScoresOfWindowsAll = [this.ScoresOfWindowsAll, {this.ScoresofWindows}];

            this.LabelePredicted = ChoosenLabel;
            this.PrevLabelePredicted=this.LabelePredicted;
            this.PredictedLabelAll = [this.PredictedLabelAll, ...
                [this.LabelePredicted; samplePoint]];
            this.PredictedLabelsofWindows=[];
            this.ScoresofWindows=[];
            %dbg_g_m = [dbg_g_m; dbg_m];
        end

        function [LabelePredicted,Score]=ClassifyExtractedWindows(this,window,phase,PrevLabelePredicted)

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
                    [LabelePredicted,Score,this.ClassNames] = predict(this.offlineProcessing.ClassifierModel{1}, testfeature);
                elseif  this.offlineProcessing.ClassifierArchitecture=="Mode-Specific"|| this.offlineProcessing.ClassifierArchitecture=="Mode-Specific-PhaseDependant"
                    [LabelePredicted,Score,this.ClassNames]= ModeSpecificOnline(testfeature,phase,PrevLabelePredicted,this.offlineProcessing.ClassifierModel,this.offlineProcessing.ClassifierArchitecture);
                end
            elseif phase=="Stance"
                if this.offlineProcessing.ClassifierArchitecture=="All data-Phase dependant"
                    [LabelePredicted,Score,this.ClassNames] = predict(this.offlineProcessing.ClassifierModel{2}, testfeature);
                elseif  this.offlineProcessing.ClassifierArchitecture=="Mode-Specific" || this.offlineProcessing.ClassifierArchitecture=="Mode-Specific-PhaseDependant"
                    [LabelePredicted,Score,this.ClassNames]= ModeSpecificOnline(testfeature,phase,PrevLabelePredicted,this.offlineProcessing.ClassifierModel,this.offlineProcessing.ClassifierArchitecture);
                end
            else
                error("Invalid Mode: %s",phase);
            end
        end

        function onlineaccu=OnlineAccuracy(this,trueLab,Transitions)
            rp=this.offlineProcessing.rp;
            %RepPredictedLabs=repelem(this.PredictedLabelAll,1,this.numwindow);
            trueLabels=AlignTagsWithGait(trueLab,Transitions,rp.SamplingFreq);
            %RepPredictedLabs=RepPredictedLabs(:,RepPredictedLabs(2,:)<TrueLabels(2,end));
            %RepPredictedLabs=RepPredictedLabs(:,RepPredictedLabs(2,:)>=TrueLabels(2,1));
            onlineaccu=sum((trueLabels(1,:))==this.PredictedLabelAll(1,:))/length(this.PredictedLabelAll);
        end

        function Reset(this)
            this.PredictedLabelsofWindows = [];
            this.ScoresOfWindowsAll={};
            this.ScoresofWindows=[];
            this.PredictedLabelAll=[];
            this.debug_nClassifyWindowsWeHave = 0;
            this.Postprocessorcaounter=0;
            this.NANcaounter=0;

            % TODO: Do we need these?
            this.PrevLabelePredicted=3;
            this.LabelePredicted=3;
            this.TrueTagLab=[];
            this.trueTags=[];
            this.numwindow=0;
        end
    end
end