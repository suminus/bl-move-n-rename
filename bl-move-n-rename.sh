#!/bin/bash
# baselight rename clipster vtr seq to reels by foldernames
# utilising filmlight's fl-ls fl-mv
# (c) mario hartz @ postfactory.de

HOME=/usr/fl/scripts
SRC=$1

####################

MOVE () {

#### search for vtr-dpx-seq

        fl-ls -R $SRC | grep dpx > $HOME/tmp_seq.mv
        cat $HOME/tmp_seq.mv | grep dpx | grep vtr | rev | cut -d / -f 3 | rev | uniq > $HOME/tmp_fld.mv

#### gen list of seq to move

        cp $HOME/tmp_seq.mv $HOME/tmp_seq.mv.mklist
        cp $HOME/tmp_fld.mv $HOME/tmp_fld.mv.mklist
        touch $HOME/tmp_fld.mv.list

        for SUBFLDMV in $( cat $HOME/tmp_fld.mv.mklist )
        do
                echo $SUBFLDMV >> $HOME/tmp_fld.mv.list
                echo "++++++++++++++++++"  >> $HOME/tmp_fld.mv.list
                for SUBSEQMV in $( cat $HOME/tmp_seq.mv.mklist | grep $SUBFLDMV | cut -d . -f 1-2 | sed -e 's#$#.dpx#' )
                do
                        SUBSEQMVTRG=$( echo $SUBSEQMV | rev | cut -d / -f 3- | rev | sed -e 's/$/\//' )
                        echo $SUBSEQMV >> $HOME/tmp_fld.mv.list
                        echo " to:"  >> $HOME/tmp_fld.mv.list
                        echo $SUBSEQMVTRG  >> $HOME/tmp_fld.mv.list
                        printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' _  >> $HOME/tmp_fld.mv.list
                        echo  >> $HOME/tmp_fld.mv.list
                        sed -i '1d' $HOME/tmp_seq.mv.mklist
                done
                sed -i '1d' $HOME/tmp_fld.mv.mklist
        done
        rm $HOME/tmp_fld.mv.mklist
        rm $HOME/tmp_seq.mv.mklist

#### move all found seq into appropriate folder

        clear
        echo -e " this will \e[7m move \e[27m:"
        printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' =
        cat $HOME/tmp_fld.mv.list
        echo
        read -p ' are you shure [y/N] '
        case $REPLY in
             y) for SUBFLDMV in $( cat $HOME/tmp_fld.mv )
                do
                echo "moving to: $SUBFLDMV"
                        for SUBSEQMV in $( cat $HOME/tmp_seq.mv | grep $SUBFLDMV | cut -d . -f 1-2 | sed -e 's#$#.dpx#' )
                        do
                                SUBSEQMVTRG=$( echo $SUBSEQMV | rev | cut -d / -f 3- | rev | sed -e 's/$/\//' )
                                fl-mv $SUBSEQMV $SUBSEQMVTRG
                                sed -i '1d' $HOME/tmp_seq.mv
                        done
                sed -i '1d' $HOME/tmp_fld.mv
                done
                ;;

             N)      break
                     ;;

             *)      echo "wrong entry!"
                     sleep 1
                     clear
                     ;;
        esac

        rm $HOME/tmp_fld.mv
        rm $HOME/tmp_seq.mv
        rm $HOME/tmp_fld.mv.list
        echo
        }

RENAME () {

#### search for vtr-dpx-seq

        fl-ls -R $SRC | grep dpx > $HOME/tmp_seq.rn
        cat $HOME/tmp_seq.rn | grep dpx | rev | cut -d / -f 2 | rev > $HOME/tmp_fld.rn

#### gen list of seq to rename
		
        cp $HOME/tmp_seq.rn $HOME/tmp_seq.rn.mklist
        cp $HOME/tmp_fld.rn $HOME/tmp_fld.rn.mklist
        touch > $HOME/tmp_seq.rn.list

        for SUBFLD in $( cat $HOME/tmp_fld.rn.mklist )
        do
                SUBSEQ=$( head -n 1 $HOME/tmp_seq.rn.mklist )
                SEQO=$( echo "$SUBSEQ" | cut -d . -f 1-2 | sed -e 's#$#.dpx#' )
                SEQN=$( echo "$SUBSEQ" | rev | cut -d / -f 2- | rev | sed -e 's/$/\//' | sed -e "s/$/$SUBFLD/" | sed -e 's/$/_%.7F.dpx/' )
                echo $SUBFLD >> $HOME/tmp_seq.rn.list
                echo "+++++++++++++" >> $HOME/tmp_seq.rn.list
                echo $SEQO >> $HOME/tmp_seq.rn.list
                echo " to" >> $HOME/tmp_seq.rn.list
                echo $SEQN >> $HOME/tmp_seq.rn.list
                printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' _  >> $HOME/tmp_seq.rn.list
                sed -i '1d' $HOME/tmp_seq.rn.mklist
                sed -i '1d' $HOME/tmp_fld.rn.mklist
        done

        rm $HOME/tmp_seq.rn.mklist
        rm $HOME/tmp_fld.rn.mklist

#### move all found seq into appropriate folder

        clear
        echo -e " this will \e[7m rename \e[27m:"
        printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' =
        cat $HOME/tmp_seq.rn.list
        echo
        read -p ' are you shure [y/N] '
        case $REPLY in

                y)      for SUBFLD in $( cat $HOME/tmp_fld.rn )
                        do
                        SUBSEQ=$( head -n 1 $HOME/tmp_seq.rn )
                        SEQO=$( echo "$SUBSEQ" | cut -d . -f 1-2 | sed -e 's#$#.dpx#' )
                        SEQN=$( echo "$SUBSEQ" | rev | cut -d / -f 2- | rev | sed -e 's/$/\//' | sed -e "s/$/$SUBFLD/" | sed -e 's/$/_%.7F.dpx/' )
                        fl-mv $SEQO $SEQN
                        sed -i '1d' $HOME/tmp_seq.rn
                        sed -i '1d' $HOME/tmp_fld.rn
                        echo " remaining sequences:"
                        echo
                        cat $HOME/tmp_seq.rn
                        echo
                        done
                        ;;

                N)      break
                        ;;

                *)      echo "wrong entry!"
                        sleep 1
                        clear
                        ;;
        esac

        rm $HOME/tmp_seq.rn.list
        rm $HOME/tmp_fld.rn
        rm $HOME/tmp_seq.rn
        }

############## start

rm $HOME/tmp_seq.*  > /dev/null 2>&1
rm $HOME/tmp_fld.*  > /dev/null 2>&1

clear
case $1 in

        "") echo " missing input path as 1st argument or drag/drop folder"
            echo
            echo " [drag-folder]"
            echo "      |"
            echo "      |___[destination reelname]"
            echo "      |             |"
            echo "      :             |____[vtr_xx]"
            echo "      :             |____[vtr_xx]"
            echo
            echo
            echo " hit any key to exit."
            read
            ;;

        *) MOVE
           RENAME
           echo
           echo " finished! hit any key to exit."
           read
           ;;
esac

echo -e "\e[0m "
exit
