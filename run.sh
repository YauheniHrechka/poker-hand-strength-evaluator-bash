#!/bin/bash

#while read line; do
#echo "$line";
#done

source "./correct.sh"

#while read line; do
#a "$line"
#done

function checkGameType() {
   local gameType=$1
   shift
   local arr=($@)
   # echo "${arr[@]}"
   for i in "${arr[@]}"; do
      if [ "$i" == "$gameType" ]; then
         echo ""
         return
      fi
   done
   echo "Error: The '$gameType' game wasn't found."
   return
}

function checkStrCards() {
   local number=$1
   local strCards=$2
   local name=$3

   curNumber=$(($number * 2))
   if [[ $curNumber != ${#strCards} ]]; then
      echo "Error: The $name '$strCards' can be $number."
      return
   fi

   strError=""
   i=0
   while [ $i -lt $curNumber ]; do
      curFullCard=${strCards:$i:2} # get the current full card (for example, 4c) ...
      echo $curFullCard
      # for i in "${arr[@]}"; do
      #    if [ "$i" == "$gameType" ]; then
      #       echo ""
      #       return
      #    fi
      # done
      # echo "Error: The '$gameType' game wasn't found."
      # echo ${strCards:$i:2}
      i=$(($i + 2))
   done
   return
}

arrGameTypes=("texas-holdem" "omaha-holdem" "five-card-draw")

read str
IFS=" " read -ra arrWords <<<"$str" # get the array of words ...

gameType=${arrWords[0]} # current game-type ...

strError=$(checkGameType "$gameType" "${arrGameTypes[@]}")
if [ "$strError" != "" ]; then
   echo $strError
   exit
fi

arrCheckCards=("test" "test2")
[[ $gameType == "five-card-draw" ]] && startIndex=1 || startIndex=2
[[ $gameType == "five-card-draw" ]] && boardCards="" || boardCards=${arrWords[1]} # get current 5 board cards for 'texas-holdem' and 'omaha-holdem' ...

#echo "startIndex - $startIndex"
#echo "boardCards - $boardCards"

numberPokerHands=2
if [ $gameType == "omaha-holdem" ]; then
   numberPokerHands=4
elif [ $gameType == "five-card-draw" ]; then
   numberPokerHands=5
fi

#echo "numberPokerHands - $numberPokerHands"

#************************************************************************************

function check() {
   for i in "${arrCheckCards[@]}"; do
      echo $i
   done
}

if [ "$boardCards" != "" ]; then
   #check
   strError+=$(checkStrCards "5" "$boardCards" "Board cards")
   # echo $strError
fi

#if [ "$boardCards" != "" ];
#then
#strError+=$(checkStrCards "5" "$boardCards" "Board cards" "${arrCheckCards[*]}")
#echo $strError
#fi

#************************************************************************************

if [ "$strError" != "" ]; then
   echo $strError
   exit
fi

#checkGameType $gameType 34

#for i in "${arrWords[@]}"
#do
#echo $i
#done
