
classdef LOCO
    properties(Constant)
        % T prefix stands for Tag
        
        % Constants defining locomotion mode
        TDefault = 3
        TWalk = 3
        TRmpA = 4
        TRmpD = 5
        TStrA = 6
        TStrD = 7
        StandardTagSeq = [
            LOCO.TRmpA,LOCO.TWalk,LOCO.TStrD,LOCO.TWalk, ...
            LOCO.TStrA,LOCO.TWalk,LOCO.TRmpD,LOCO.TWalk
        ];

        TLocoModes = [LOCO.TWalk, LOCO.TRmpA, LOCO.TRmpD, LOCO.TStrA, LOCO.TStrD]

        % Constants defining locomotion transition
        TWalkTStrA = LOCO.TWalk * 10 + LOCO.TStrA
        TWalkTStrD = LOCO.TWalk * 10 + LOCO.TStrD
        TStrATWalk = LOCO.TStrA * 10 + LOCO.TWalk
        TStrDTWalk = LOCO.TStrD * 10 + LOCO.TWalk
        TWalkTRmpA = LOCO.TWalk * 10 + LOCO.TRmpA
        TWalkTRmpD = LOCO.TWalk * 10 + LOCO.TRmpD
        TRmpATWalk = LOCO.TRmpA * 10 + LOCO.TWalk
        TRmpDTWalk = LOCO.TRmpD * 10 + LOCO.TWalk

        TCommonTransitions = [ ...
            LOCO.TWalkTStrA, LOCO.TWalkTStrD, LOCO.TWalkTRmpA, LOCO.TWalkTRmpD, ...
            LOCO.TStrATWalk, LOCO.TStrDTWalk, LOCO.TRmpATWalk, LOCO.TRmpDTWalk
        ];

        % Constants defining gait phase
        SwingMark = 9
        StanceMark = 8

        % Constants defining gait transition
        StanceToSwingMark = LOCO.StanceMark * 10 + LOCO.SwingMark % 89
        SwingToStanceMark = LOCO.SwingMark * 10 + LOCO.StanceMark % 98
        ToeOff = LOCO.StanceToSwingMark % 89
        HeelCo = LOCO.SwingToStanceMark % 98
    end
    methods(Static)
        function tag = TagT(prev, next)
            if nargin == 2
                tag = prev * 10 + next;
            else
                tag = prev(1) * 10 + prev(2); % passed as [prev,next]
            end
        end

        function [prevtag, nexttag] = TagS(tagTrans)
            prevtag = floor(tagTrans / 10);
            nexttag = mod(tagTrans, 10);
        end

        function [nexttag] = TagSN(tagTrans)
            nexttag = mod(tagTrans, 10);
        end

        function x = IsTagT(tag)
            x = tag >= 10;
        end

        function x = IsTagS(tag)
            x = tag < 10;
        end
    end
end
