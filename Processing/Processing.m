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
% All the pre processing from filtering to windowing, feature extraction,
% adding tags and classification happens here 
%
% --------------------------Updates--------------------------
% 2022-03-15 / Bahareh Ahkami / Creation

classdef Processing < handle

    properties
        % Processing Params
        originalRecProps RecordingProperties;
        FilterOutBadRounds = false;
        GoodTagSequence = [4,3,7,3,6,3,5,3]; % TODO: Set in settings page
        RoundStartTag = 5; %StairTODO: Set in settings page
        FilterType=[];
        BeforeEvent;
        AfterEvent;
        FetureSet=[];
        ClassificationMethod=[];
        ClassificationType=[];
        ClassifierArchitecture=[];
        ClassifireValidation=[];
        WindowingMethod=[];
        IncTime=[];
        WindowLength=[];
        NumRounds;
        IfProcessEMG=1;
        IfProcessIMU=1;
        IfProcessPS=1;



        %IMU
        IMUFilterType=[];
        IMUFetureSet=[];


        SwingDataTransition=[];
        StanceDataTransition=[];
        SwingDataSteady=[];
        StanceDataSteady=[];
        SwingData=[];
        StanceData=[];
        AllDataSteady=[];
        AllDataTransition=[];


        %features from each set
        features_SW_TR
        features_SW_SS
        features_ST_TR
        features_ST_SS
        features_SW_all
        features_ST_all
        features_all

        %features from each set IMU

        IMUfeatures_SW_TR
        IMUfeatures_SW_SS
        IMUfeatures_ST_TR
        IMUfeatures_ST_SS
        IMUfeatures_SW_all
        IMUfeatures_ST_all
        IMUfeatures_all
        %IMUfeatures_Roundall %unused


        %features from each set PS

        PSfeatures_SW_TR
        PSfeatures_SW_SS
        PSfeatures_ST_TR
        PSfeatures_ST_SS
        PSfeatures_SW_all
        PSfeatures_ST_all
        PSfeatures_all
        PSfeatures_Roundall %unused


        TestPercent
        TrainPercent
        ValidPercent



        %Labels


        Lables_TransitionORSteady_SW_TR
        Lables_TransitionORSteady_SW_SS
        Lables_SW_TR
        Lables_SW_SS
        Lables_TransitionORSteady_SW_all
        Lables_ST_all
        Lables_SW_all
        Lables_TransitionORSteady_ST_all
        Lables_TransitionORSteady_ST_TR
        Lables_TransitionORSteady_ST_SS
        Lables_ST_TR
        Lables_ST_SS
        Lables_all
        PrevLabel_all
        PrevLabel_SW_all
        PrevLabel_ST_all
        features_all_SS
        Lables_all_SS


        features_Roundall
        Lables_Roundall
        PrevLabel_Roundall



        %Labels IMU

        IMULables_TransitionORSteady_SW_TR
        IMULables_TransitionORSteady_SW_SS
        IMULables_SW_TR
        IMULables_SW_SS
        IMULables_TransitionORSteady_SW_all
        IMULables_ST_all
        IMULables_SW_all
        IMULables_TransitionORSteady_ST_all
        IMULables_TransitionORSteady_ST_TR
        IMULables_TransitionORSteady_ST_SS
        IMULables_ST_TR
        IMULables_ST_SS
        IMULables_all
        IMUPrevLabel_all
        IMUPrevLabel_SW_all
        IMUPrevLabel_ST_all
        IMUfeatures_all_SS
        IMULables_all_SS

        IMULables_Roundall
        IMUPrevLabel_Roundall

        %Labels PS

        PSLables_TransitionORSteady_SW_TR
        PSLables_TransitionORSteady_SW_SS
        PSLables_SW_TR
        PSLables_SW_SS
        PSLables_TransitionORSteady_SW_all
        PSLables_ST_all
        PSLables_SW_all
        PSLables_TransitionORSteady_ST_all
        PSLables_TransitionORSteady_ST_TR
        PSLables_TransitionORSteady_ST_SS
        PSLables_ST_TR
        PSLables_ST_SS
        PSLables_all
        PSPrevLabel_all
        PSPrevLabel_SW_all
        PSPrevLabel_ST_all
        PSfeatures_all_SS
        PSLables_all_SS
        PSLables_Roundall
        PSPrevLabel_Roundall


        AvailableTagName;

        ClassifierModel_TransitionSteady_SW
        ClassifierModel_TransitionSteady_ST
        ClassifierModel_TransitionClasses_SW
        ClassifierModel_TransitionClasses_ST
        ClassifierModel_SteadyClasses_SW
        ClassifierModel_SteadyClasses_ST
        ClassifierModel_SW
        ClassifierModel_ST
        ClassifierModel_AllData
        ClassifierModel_ModeSpecific
        ClassifierModel_SW_MS
        ClassifierModel_ST_MS
        ClassifierModel_SteadyClasses_all
        ClassifierModel


        ST_CC_3
        ST_CC_4
        ST_CC_5
        ST_CC_6
        ST_CC_7
        ST_CC_8
        ST_CC_9
        SW_CC_3
        SW_CC_4
        SW_CC_5
        SW_CC_6
        SW_CC_7
        SW_CC_8
        SW_CC_9



        AllData

        signal

       
        RecordingProperties RecordingProperties
    end

    properties (Dependent)
        rp RecordingProperties; % just an old name mapping
    end

    methods
        function this = Processing()
            % Ctor
        end

        function v = get.rp(this)
            v = this.originalRecProps;
        end

        function set.originalRecProps(this, v)
            % if isempty(this.originalRecProps)
            this.originalRecProps = v;
            %  else
            % error('Processing.originalRecProps can only be set once!')
            %end
        end

        function v = get.originalRecProps(this)
            v = this.originalRecProps;
        end


        %Do all the preproceesing
        function TreatSignal(this,recordedRawData,pressOriginal,tags)
            %% Remove and report bad tag sequences
            if this.FilterOutBadRounds
                gprlog('-> Filtering out bad rounds (bad tag sequences)')
                [outSig, outPS, outTags,~] = DeleteBadRounds(recordedRawData,pressOriginal,tags,this.rp.SamplingFreq,this.GoodTagSequence);
                recordedRawData = outSig;
                pressOriginal = outPS;
                tags = outTags;
            else
                warning('FilterOutBadRounds is not selected!!! Results could be undefined')
            end

            % Get hardlimited pressure channel
            % Note that this channel should only contain whole values of 8 or 9
            % and DeleteBadRounds above might interfere with
            % that.
            pressHardlimited = recordedRawData(this.rp.IdxPS, :);
            pressHardlimited(pressHardlimited == 0) = 8;
            recordedRawData(this.rp.IdxPS, :) = pressHardlimited;

            

            %% Filter signal based on chosen filters
           

          FilteredData = recordedRawData;
          if this.FilterType ~= "None"
              gprlog('-> Applying EMG filter')

              for i=1:length(this.FilterType)
                  FilteredData=FilterSignal(this.rp.SamplingFreq,FilteredData,this.FilterType(i),this.rp.IdxEMG);

                  % plot(abs(fft(Fsignal(2,1000:10000))));
                  %%figure
                  %plot (abs(fft(data(2,1000:10000))))
              end

          end
          if this.IMUFilterType ~= "None"
              gprlog('-> Applying IMU filter')

              if this.rp.HasIMU==1
                  for i=1:length(this.IMUFilterType)
                      FilteredData=FilterSignal(this.rp.SamplingFreq,FilteredData,this.IMUFilterType(i),this.rp.IdxIMU);
                  end
              end 
          end
            this.signal=FilteredData;



            %% Process the gait phase and event tag information.

            %%Here I need to input the refined pressure sensor
            gprlog('-> FindGaitTransitions')
            [gaitTrans]=FindGaitTransitions(pressHardlimited,this.rp.SamplingFreq);  

            gprlog('-> UnrollTagsOntoSignal')
            [this.AvailableTagName, this.signal,this.NumRounds]=UnrollTagsOntoSignal(this.signal,tags,this.rp.NumAllCh,this.rp.SamplingFreq,gaitTrans,this.RoundStartTag);

            gprlog('Number of rounds: %d', this.NumRounds)

            %% Devide data into stance and swing based on hardlimited PS and window them
            gprlog('-> SwingStanceDevider')
            [this.AllData, this.SwingData,this.StanceData]=SwingStanceDevider(gaitTrans,this.signal,this.BeforeEvent,this.rp,this.AfterEvent,this.IncTime,this.WindowLength,this.WindowingMethod);
            
            %% Window Swing and Stance data tagging (-1000 and 1000 to show if there is transition or not and transition number)
            gprlog('-> WindowedSwingAndStanceTagger')
            [this.AllData,this.SwingData,this.StanceData]=WindowedSwingAndStanceTagger(this.AllData,this.SwingData,this.StanceData,this.rp.NumAllCh);

            gprlog("Swing  windows: %d x %d x %d\nStance windows: %d x %d x %d\n", ...
                size(this.SwingData, 1), size(this.SwingData, 2), size(this.SwingData, 3), ...
                size(this.StanceData, 1), size(this.StanceData, 2), size(this.StanceData, 3));


            %% Devide Swing and Stance Data into steadystate and transition
            gprlog('-> TransitionSteadyDivider')
            [this.SwingDataTransition,this.SwingDataSteady,this.StanceDataTransition,this.StanceDataSteady,this.AllDataSteady,this.AllDataTransition]=TransitionSteadyDivider(this.AllData,this.SwingData, this.StanceData,this.rp.NumAllCh);
            gprlog("Pre-Processing done")
            
            %% Show some stuff
            if false
                idxTag = this.rp.NumAllCh+1;
                idxTagTrans = this.rp.NumAllCh+2;
                idxRound = this.rp.NumAllCh+3;
                idxPrevTag = this.rp.NumAllCh+4;

                figure;
                % plot(pressOriginal)
                colormap colorcube(100)
                F = {this.SwingDataTransition, this.SwingDataSteady, this.StanceDataTransition, this.StanceDataSteady};
                for Fi = 1:4
                    subplot(2,2,Fi)
                    Ffi = F{Fi};
                    [~,~,Fin]=size(Ffi);
                    for i=1:Fin
                        hold on
                        set(gca,'ColorOrderIndex',Ffi(idxTag,1,i))
                        offset = 1e-4 * Ffi(idxTag,1,i);
                        plot(Ffi(3,:,i) + offset);
                    end
                end
            end
        end

        function SaveTagNames(this)
            %Save signal tagnames to save as an agenda

            uniqueAvailableTagName=unique(this.AvailableTagName);
            for i=1:length(uniqueAvailableTagName)

                [TagnamesAgenda{i,1},~]=GetTagName(uniqueAvailableTagName(i));
                TagnamesAgenda{i,2}=uniqueAvailableTagName(i);

            end
            [~,~] = mkdir('./SavedData');
            uisave('TagnamesAgenda', './SavedData/LDtags.mat')
   
        end

        function ClearFeatureExtraction(this)
            %Reset all the features

            %EMG
            this.features_SW_TR=[];
            this.features_SW_SS=[];
            this.features_ST_TR=[];
            this.features_ST_SS=[];
            this.features_SW_all=[];
            this.features_ST_all=[];
            this.features_all=[];
            %this.features_Roundall=[];

            %IMU
            this.IMUfeatures_SW_TR=[];
            this.IMUfeatures_SW_SS=[];
            this.IMUfeatures_ST_TR=[];
            this.IMUfeatures_ST_SS=[];
            this.IMUfeatures_SW_all=[];
            this.IMUfeatures_ST_all=[];
            this.IMUfeatures_all=[];
            %this.IMUfeatures_Roundall=[];

            %PS
            this.PSfeatures_SW_TR=[];
            this.PSfeatures_SW_SS=[];
            this.PSfeatures_ST_TR=[];
            this.PSfeatures_ST_SS=[];
            this.PSfeatures_SW_all=[];
            this.PSfeatures_ST_all=[];
            this.PSfeatures_all=[];
            %this.PSfeatures_Roundall=[];
        end
        
        function GetFeaturesEMG(this)


            %Getfeatures from each set
            [this.features_SW_TR,this.Lables_SW_TR,this.Lables_TransitionORSteady_SW_TR,~]=GetFeaturesEachSet(this.SwingDataTransition,this.rp,this.FetureSet,"EMG");
            [this.features_SW_SS,this.Lables_SW_SS,this.Lables_TransitionORSteady_SW_SS,~]=GetFeaturesEachSet(this.SwingDataSteady,this.rp,this.FetureSet,"EMG");
            [this.features_SW_all,this.Lables_SW_all,this.Lables_TransitionORSteady_SW_all,this.PrevLabel_SW_all]=GetFeaturesEachSet(this.SwingData,this.rp,this.FetureSet,"EMG");
            [this.features_ST_SS,this.Lables_ST_SS,this.Lables_TransitionORSteady_ST_SS,~]=GetFeaturesEachSet(this.StanceDataSteady,this.rp,this.FetureSet,"EMG");
            [this.features_ST_TR,this.Lables_ST_TR,this.Lables_TransitionORSteady_ST_TR,~]=GetFeaturesEachSet(this.StanceDataTransition,this.rp,this.FetureSet,"EMG");
            [this.features_ST_all,this.Lables_ST_all,this.Lables_TransitionORSteady_ST_all,this.PrevLabel_ST_all]=GetFeaturesEachSet(this.StanceData,this.rp,this.FetureSet,"EMG");

            [this.features_all_SS,this.Lables_all_SS,~,~]=GetFeaturesEachSet(this.AllDataSteady,this.rp,this.FetureSet,"EMG");

            % %Getfeatures from each set all the data together regardless
            % of swing or stance or steady or transition
            [this.features_all,this.Lables_all,~,this.PrevLabel_all]=GetFeaturesEachSet(this.AllData,this.rp,this.FetureSet,"EMG");

            % %Getfeatures from each ROUND all the data together regardless
            % of swing or stance or steady or transition

            % [this.features_Roundall,this.Lables_Roundall,~,this.PrevLabel_Roundall]=GetFeaturesEachRound(this.AllData,this.rp,this.FetureSet,this.NumRounds,"EMG");
            gprlog("Extraction done - EMG");
        end

        function GetFeaturesIMU(this)

            %Getfeatures from each set
            [this.IMUfeatures_SW_TR,this.IMULables_SW_TR,this.IMULables_TransitionORSteady_SW_TR,~]=GetFeaturesEachSet(this.SwingDataTransition,this.rp,this.IMUFetureSet,"IMU");
            [this.IMUfeatures_SW_SS,this.IMULables_SW_SS,this.IMULables_TransitionORSteady_SW_SS,~]=GetFeaturesEachSet(this.SwingDataSteady,this.rp,this.IMUFetureSet,"IMU");
            [this.IMUfeatures_SW_all,this.IMULables_SW_all,this.IMULables_TransitionORSteady_SW_all,this.IMUPrevLabel_SW_all]=GetFeaturesEachSet(this.SwingData,this.rp,this.IMUFetureSet,"IMU");
            [this.IMUfeatures_ST_SS,this.IMULables_ST_SS,this.IMULables_TransitionORSteady_ST_SS,~]=GetFeaturesEachSet(this.StanceDataSteady,this.rp,this.IMUFetureSet,"IMU");
            [this.IMUfeatures_ST_TR,this.IMULables_ST_TR,this.IMULables_TransitionORSteady_ST_TR,~]=GetFeaturesEachSet(this.StanceDataTransition,this.rp,this.IMUFetureSet,"IMU");
            [this.IMUfeatures_ST_all,this.IMULables_ST_all,this.IMULables_TransitionORSteady_ST_all,this.IMUPrevLabel_ST_all]=GetFeaturesEachSet(this.StanceData,this.rp,this.IMUFetureSet,"IMU");

            [this.IMUfeatures_all_SS,this.IMULables_all_SS,~,~]=GetFeaturesEachSet(this.AllDataSteady,this.rp,this.IMUFetureSet,"IMU");
            % %Getfeatures from each set all the data together regardless
            % of swing or stance or steady or transition

            [this.IMUfeatures_all,this.IMULables_all,~,this.PrevLabel_all]=GetFeaturesEachSet(this.AllData,this.rp,this.IMUFetureSet,"IMU");
            % %Getfeatures from each ROUND all the data together regardless
            % of swing or stance or steady or transition

            %[this.IMUfeatures_Roundall,this.IMULables_Roundall,~,this.IMUPrevLabel_Roundall]=GetFeaturesEachRound(this.AllData,this.rp,this.IMUFetureSet,this.NumRounds,"IMU");
            gprlog("Extraction done - IMU");

        end

        function GetFeaturesPS(this)

            %Getfeatures from each set
            [this.PSfeatures_SW_TR,this.PSLables_SW_TR,this.PSLables_TransitionORSteady_SW_TR,~]=GetFeaturesEachSet(this.SwingDataTransition,this.rp,this.IMUFetureSet,"PS");
            [this.PSfeatures_SW_SS,this.PSLables_SW_SS,this.PSLables_TransitionORSteady_SW_SS,~]=GetFeaturesEachSet(this.SwingDataSteady,this.rp,this.IMUFetureSet,"PS");
            [this.PSfeatures_SW_all,this.PSLables_SW_all,this.PSLables_TransitionORSteady_SW_all,this.PSPrevLabel_SW_all]=GetFeaturesEachSet(this.SwingData,this.rp,this.IMUFetureSet,"PS");
            [this.PSfeatures_ST_SS,this.PSLables_ST_SS,this.PSLables_TransitionORSteady_ST_SS,~]=GetFeaturesEachSet(this.StanceDataSteady,this.rp,this.IMUFetureSet,"PS");
            [this.PSfeatures_ST_TR,this.PSLables_ST_TR,this.PSLables_TransitionORSteady_ST_TR,~]=GetFeaturesEachSet(this.StanceDataTransition,this.rp,this.IMUFetureSet,"PS");
            [this.PSfeatures_ST_all,this.PSLables_ST_all,this.PSLables_TransitionORSteady_ST_all,this.PSPrevLabel_SW_all]=GetFeaturesEachSet(this.StanceData,this.rp,this.IMUFetureSet,"PS");

            [this.PSfeatures_all_SS,this.PSLables_all_SS,~,~]=GetFeaturesEachSet(this.AllDataSteady,this.rp,this.IMUFetureSet,"PS");
            % %Getfeatures from each set all the data together regardless
            % of swing or stance or steady or transition

            [this.PSfeatures_all,this.PSLables_all,~,this.PrevLabel_all]=GetFeaturesEachSet(this.AllData,this.rp,this.IMUFetureSet,"PS");
            % %Getfeatures from each ROUND all the data together regardless
            % of swing or stance or steady or transition

            % [this.PSfeatures_Roundall,this.PSLables_Roundall,~,this.PSPrevLabel_Roundall]=GetFeaturesEachRound(this.AllData,this.rp,this.IMUFetureSet,this.NumRounds,"PS");


            gprlog("Extraction done - PS");
        end

        
        function OfflineClassify(this)


            % Classification
            Testpercentage=this.TestPercent;
            trainpercentage=this.TrainPercent;
            validationpercentage=this.ValidPercent;

       
             
            if (this.ClassificationMethod=="LDA" || this.ClassificationMethod=="SVM" )&& this.ClassifierArchitecture=="Mode-Specific"
                if  this.IfProcessEMG==1 && this.IfProcessIMU ==1 &&  this.IfProcessPS==1
                    [this.features_all,this.Lables_all]=SensorConcat(this.features_all,this.Lables_all,this.IMUfeatures_all,this.PSfeatures_all);

                elseif this.rp.HasIMU==1 && this.IfProcessEMG==0 && this.IfProcessIMU ==1 &&  this.IfProcessPS==1

                    [this.features_all,this.Lables_all]=SensorConcat(this.IMUfeatures_all,this.IMULables_all,this.PSfeatures_all);
                end
                %Classify mode specific
                [~,this.ClassifierModel,CC_3,CC_4,CC_5,CC_6,CC_7,CC_8,CC_9]=OfflineClassification(this.features_all,this.Lables_all,this.PrevLabel_all,this.ClassificationMethod,this.ClassificationType,Testpercentage,trainpercentage, validationpercentage, this.ClassifierArchitecture, this.ClassifireValidation); %SS=steady

            elseif (this.ClassificationMethod== "LDA" || this.ClassificationMethod== "SVM") && this.ClassifierArchitecture=="All data-Phase dependant"

                [this.features_SW_all,this.Lables_SW_all]=SensorConcat(this.features_SW_all,this.Lables_SW_all,this.IMUfeatures_SW_all,this.PSfeatures_SW_all);
                [this.features_ST_all,this.Lables_ST_all]=SensorConcat(this.features_ST_all,this.Lables_ST_all,this.IMUfeatures_ST_all,this.PSfeatures_ST_all);
                [this.features_all,this.Lables_all]=SensorConcat(this.features_all,this.Lables_all,this.IMUfeatures_all,this.PSfeatures_all);

                this.ClassifierModel={};
                %CLassify  in swing
                [~,this.ClassifierModel,CC,~,~,~,~,~,~]=OfflineClassification(this.features_SW_all,this.Lables_SW_all,[],this.ClassificationMethod,this.ClassificationType,Testpercentage,trainpercentage, validationpercentage, this.ClassifierArchitecture, this.ClassifireValidation);
                %CLassify in stance
                [~,this.ClassifierModel,CC,~,~,~,~,~,~]=OfflineClassification(this.features_ST_all,this.Lables_ST_all,[],this.ClassificationMethod,this.ClassificationType,Testpercentage,trainpercentage, validationpercentage, this.ClassifierArchitecture, this.ClassifireValidation); %SSTR=steady or transition
                %Classify all data
                [~,this.ClassifierModel,CC,~,~,~,~,~,~]=OfflineClassification(this.features_all,this.Lables_all,[],this.ClassificationMethod,this.ClassificationType,Testpercentage,trainpercentage, validationpercentage, this.ClassifierArchitecture, this.ClassifireValidation); %SS=steady
                this.ClassifierModel={this.ClassifierModel_SW;this.ClassifierModel_ST;this.ClassifierModel_SteadyClasses_ST};
            elseif (this.ClassificationMethod=="LDA"  || this.ClassificationMethod=="SVM" )&& this.ClassifierArchitecture=="Mode-Specific-PhaseDependant"
                if  this.IfProcessEMG==1 && this.IfProcessIMU ==1 &&  this.IfProcessPS==1
                    [this.features_SW_all,this.Lables_SW_all]=SensorConcat(this.features_SW_all,this.Lables_SW_all,this.IMUfeatures_SW_all,this.PSfeatures_SW_all);
                    [this.features_ST_all,this.Lables_ST_all]=SensorConcat(this.features_ST_all,this.Lables_ST_all,this.IMUfeatures_ST_all,this.PSfeatures_ST_all);
                elseif  this.IfProcessEMG==0 && this.IfProcessIMU ==1 &&  this.IfProcessPS==1
                    [this.features_SW_all,this.Lables_SW_all]=SensorConcat(this.IMUfeatures_SW_all,this.IMULables_SW_all,this.PSfeatures_SW_all);
                    [this.features_ST_all,this.Lables_ST_all]=SensorConcat(this.IMUfeatures_ST_all,this.IMULables_ST_all,this.PSfeatures_ST_all);
                    this.PrevLabel_SW_all=this.IMUPrevLabel_SW_all;
                    this.PrevLabel_ST_all=this.IMUPrevLabel_ST_all;
                elseif   this.IfProcessEMG==1 && this.IfProcessIMU ==0 &&  this.IfProcessPS==0
                    [this.features_SW_all,this.Lables_SW_all]=SensorConcat(this.features_SW_all,this.Lables_SW_all);
                    [this.features_ST_all,this.Lables_ST_all]=SensorConcat(this.features_ST_all,this.Lables_ST_all);
                end
                %Classify mode specific in swing
                [~,this.ClassifierModel_SW_MS,this.SW_CC_3,this.SW_CC_4,this.SW_CC_5,this.SW_CC_6,this.SW_CC_7,this.SW_CC_8,this.SW_CC_9]=OfflineClassification(this.features_SW_all,this.Lables_SW_all,this.PrevLabel_SW_all,this.ClassificationMethod,this.ClassificationType,Testpercentage,trainpercentage, validationpercentage, "Mode-Specific", this.ClassifireValidation); %SS=steady
                %Classify mode specific in stance
                [~,this.ClassifierModel_ST_MS,this.ST_CC_3,this.ST_CC_4,this.ST_CC_5,this.ST_CC_6,this.ST_CC_7,this.ST_CC_8,this.ST_CC_9]=OfflineClassification(this.features_ST_all,this.Lables_ST_all,this.PrevLabel_ST_all,this.ClassificationMethod,this.ClassificationType,Testpercentage,trainpercentage, validationpercentage, "Mode-Specific" , this.ClassifireValidation); %SS=steady
                this.ClassifierModel=[this.ClassifierModel_SW_MS; this.ClassifierModel_ST_MS];
            end
        end
    end
end

