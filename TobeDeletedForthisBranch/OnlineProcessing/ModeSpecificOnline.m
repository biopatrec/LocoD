%Mode specific processing in online
function LabelePredicted = ModeSpecificOnline(window,mode,Prevlabel,MDL,ClassifierArchitecture)


if ClassifierArchitecture=="Mode-Specific-PhaseDependant"


    if mode=="Swing"
        if (Prevlabel ==3 ||  mod(Prevlabel  ,10)==3)
            % 3 (walking) can have transition to all the movments so if the
            % one before is 3 it can be 3 or 34 or 35 or 36 or 36 or 38 or
            % 39
            % I have to make classifier with these data in it
            LabelePredicted =  predict(MDL{1,1},window);
%             if LabelePredicted== 37
%                 LabelePredicted=3;
%             end


        elseif (Prevlabel ==4  ||  mod(Prevlabel  ,10)==4)
            LabelePredicted =         predict(MDL{1,2},window);
            % % This transition is invalid here
        elseif (Prevlabel ==5  ||  mod(Prevlabel  ,10)==5)
            %         LabelePredicted = predict(MDL{1,3},window);
            LabelePredicted =   Prevlabel;


        elseif (Prevlabel ==6  ||  mod(Prevlabel  ,10)==6)
            LabelePredicted =   predict(MDL{1,4},window);

            % % This transition is invalid here
        elseif (Prevlabel ==7  ||  mod(Prevlabel  ,10)==7)
            %         LabelePredicted =    predict(MDL{1,5},window);
            LabelePredicted =   Prevlabel;

            %LabelePredicted =   3;
        elseif (Prevlabel ==8  ||  mod(Prevlabel  ,10)==8)
            LabelePredicted =         predict(MDL{1,6},window);


        elseif (Prevlabel ==9  ||  mod(Prevlabel  ,10)==9)
            LabelePredicted =   predict(MDL{1,7},window);



        end
    elseif mode=="Stance"
        if (Prevlabel ==3 ||  mod(Prevlabel  ,10)==3)
            % 3 (walking) can have transition to all the movments so if the
            % one before is 3 it can be 3 or 34 or 35 or 36 or 36 or 38 or
            % 39
            % I have to make classifier with these data in it
            LabelePredicted =   predict(MDL{2,1},window);
           % if LabelePredicted== 37
            %    LabelePredicted=3;
            %end


        elseif (Prevlabel ==4  ||  mod(Prevlabel  ,10)==4)
            LabelePredicted = predict(MDL{2,2},window);

        elseif (Prevlabel ==5  ||  mod(Prevlabel  ,10)==5)
            LabelePredicted = predict(MDL{2,3},window);

            % % This transition is invalid here
        elseif (Prevlabel ==6  ||  mod(Prevlabel  ,10)==6)
            %  LabelePredicted = predict(MDL{2,4},window);
            LabelePredicted =   Prevlabel;


        elseif (Prevlabel ==7  ||  mod(Prevlabel  ,10)==7)
            LabelePredicted =   predict(MDL{2,5},window);
            % LabelePredicted = 3;


        elseif (Prevlabel ==8  ||  mod(Prevlabel  ,10)==8)
            LabelePredicted =   predict(MDL{2,6},window);


        elseif (Prevlabel ==9  ||  mod(Prevlabel  ,10)==9)
            LabelePredicted = predict(MDL{2,7},window);



        end
        



    end
elseif ClassifierArchitecture=="Mode-Specific"

    if mode=="Swing"
        if (Prevlabel ==3 ||  mod(Prevlabel  ,10)==3)
            % 3 (walking) can have transition to all the movments so if the
            % one before is 3 it can be 3 or 34 or 35 or 36 or 36 or 38 or
            % 39
            % I have to make classifier with these data in it
            LabelePredicted =  predict(MDL{1,1},window);
%             if LabelePredicted== 37
%                 LabelePredicted=3;
%             end


        elseif (Prevlabel ==4  ||  mod(Prevlabel  ,10)==4)
            LabelePredicted =  predict(MDL{1,2},window);

        elseif (Prevlabel ==5  ||  mod(Prevlabel  ,10)==5)
            LabelePredicted = predict(MDL{1,3},window);


        elseif (Prevlabel ==6  ||  mod(Prevlabel  ,10)==6)
            LabelePredicted =   predict(MDL{1,4},window);


        elseif (Prevlabel ==7  ||  mod(Prevlabel  ,10)==7)
            LabelePredicted =    predict(MDL{1,5},window);
            %LabelePredicted=3;


        elseif (Prevlabel ==8  ||  mod(Prevlabel  ,10)==8)
            LabelePredicted =         predict(MDL{1,6},window);


        elseif (Prevlabel ==9  ||  mod(Prevlabel  ,10)==9)
            LabelePredicted =   predict(MDL{1,7},window);



        end
    elseif mode=="Stance"
        if (Prevlabel ==3 ||  mod(Prevlabel  ,10)==3)
            % 3 (walking) can have transition to all the movments so if the
            % one before is 3 it can be 3 or 34 or 35 or 36 or 36 or 38 or
            % 39
            % I have to make classifier with these data in it
            LabelePredicted =   predict(MDL{1},window);
%             if LabelePredicted== 37
%                 LabelePredicted=3;
%             end


        elseif (Prevlabel ==4  ||  mod(Prevlabel  ,10)==4)
            LabelePredicted = predict(MDL{2},window);

        elseif (Prevlabel ==5  ||  mod(Prevlabel  ,10)==5)
            LabelePredicted = predict(MDL{3},window);


        elseif (Prevlabel ==6  ||  mod(Prevlabel  ,10)==6)
            LabelePredicted = predict(MDL{1,4},window);


        elseif (Prevlabel ==7  ||  mod(Prevlabel  ,10)==7)
            LabelePredicted =   predict(MDL{5},window);
            %LabelePredicted=3;


        elseif (Prevlabel ==8  ||  mod(Prevlabel  ,10)==8)
            LabelePredicted =   predict(MDL{6},window);


        elseif (Prevlabel ==9  ||  mod(Prevlabel  ,10)==9)
            LabelePredicted = predict(MDL{7},window);



        end
    end

end