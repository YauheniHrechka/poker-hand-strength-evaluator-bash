#!/bin/bash

#while read line; do
#echo "$line";
#done

# source "./correct.sh"

#while read line; do
#a "$line"
#done

function elementInArray() {
   local element=$1
   shift
   local arr=($@)
   isFound=false

   for i in "${arr[@]}"; do
      if [ "$i" == "$element" ]; then
         isFound=true
         break
      fi
   done

   echo $isFound
   return
}

function getIndexInArray() {
   local element=$1
   shift
   local arr=($@)
   curIndex=0

   for index in "${!arr[@]}"; do
      if [ "${arr[$index]}" == "$element" ]; then
         curIndex=$index
         break
      fi
   done

   echo $curIndex
   return
}

function checkDraw() {
   local number=$1
   local strCards=$2
   local name=$3

   strError=""
   curNumber=$(($number * 2))
   if [[ $curNumber != ${#strCards} ]]; then
      strError="Error: The $name '$strCards' can be $number. "
   fi
   echo $strError
   return
}

function checkStrCards() {
   local strCards=$1

   arr=()
   strError=""
   i=0
   while [ $i -lt ${#strCards} ]; do
      curFullCard=${strCards:$i:2} # get the current full card (for example, 4c) ...
      isOk=$(elementInArray "$curFullCard" "${arr[@]}")

      if [ $isOk == true ]; then
         strError+="Error: The '$curFullCard' card has already added. "
      else
         curCard=${curFullCard:0:1}                           # get the current card ...
         curSuit=${curFullCard:1:2}                           # get the suit of the current cards ...
         isCard=$(elementInArray "$curCard" "${arrCards[@]}") # check the current card ...
         isSuit=$(elementInArray "$curSuit" "${arrSuits[@]}") # check the current suit ...

         if [ $isCard == false ] || [ $isSuit == false ]; then
            strError+="Error: The '${curFullCard}' card doesn't exist. "
         fi
         arr+=($curFullCard)
      fi
      i=$(($i + 2))
   done

   echo $strError
   return
}

arrGameTypes=("texas-holdem" "omaha-holdem" "five-card-draw")
arrCards=("A" "K" "Q" "J" "T" "9" "8" "7" "6" "5" "4" "3" "2")
arrSuits=("h" "d" "c" "s")
arrPokerHands=()

read str
IFS=" " read -ra arrWords <<<"$str" # get the array of words ...

gameType=${arrWords[0]} # current game-type ...

#strError=$(checkGameType "$gameType" "${arrGameTypes[@]}")
isOk=$(elementInArray "$gameType" "${arrGameTypes[@]}") # check the game-type ...
if [ $isOk == false ]; then
   echo "Error: The '$gameType' game wasn't found. "
   exit
fi

[[ $gameType == "five-card-draw" ]] && startIndex=1 || startIndex=2
[[ $gameType == "five-card-draw" ]] && boardCards="" || boardCards=${arrWords[1]} # get current 5 board cards for 'texas-holdem' and 'omaha-holdem' ...

numberPokerHands=2
if [ $gameType == "omaha-holdem" ]; then
   numberPokerHands=4
elif [ $gameType == "five-card-draw" ]; then
   numberPokerHands=5
fi

strCheckCards=$boardCards
if [ "$boardCards" != "" ]; then
   strError+=$(checkDraw "5" "$boardCards" "Board cards")
fi

i=$startIndex
while [ $i -lt ${#arrWords[@]} ]; do
   strError+=$(checkDraw "$numberPokerHands" "${arrWords[i]}" "Poker hands")
   strCheckCards+=${arrWords[i]}
   i=$(($i + 1))
done

strError+=$(checkStrCards "$strCheckCards")

if [ "$strError" != "" ]; then
   echo $strError
   exit
fi

# ************************************************************************

arrPokerHands=()

i=$startIndex
while [ $i -lt ${#arrWords[@]} ]; do
   arrPokerHands+=(${arrWords[i]})
   i=$(($i + 1))
done

arrResult=()

i=0
while [ $i -lt ${#arrPokerHands[@]} ]; do
   curPokerHand=${arrPokerHands[i]}

   arrCardsBySuitH=(0 0 0 0 0 0 0 0 0 0 0 0 0) # h ...
   arrCardsBySuitD=(0 0 0 0 0 0 0 0 0 0 0 0 0) # d ...
   arrCardsBySuitC=(0 0 0 0 0 0 0 0 0 0 0 0 0) # c ...
   arrCardsBySuitS=(0 0 0 0 0 0 0 0 0 0 0 0 0) # s ...

   curCards=$boardCards
   curCards+=$curPokerHand

   j=0
   while [ $j -lt ${#curCards} ]; do
      curFullCard=${curCards:$j:2} # get the current full card (for example, 4c) ...
      echo $curFullCard

      curCard=${curFullCard:0:1}                               # get the current card ...
      curSuit=${curFullCard:1:2}                               # get the suit of the current cards ...
      indexCard=$(getIndexInArray "$curCard" "${arrCards[@]}") # check the current card ...
      indexSuit=$(getIndexInArray "$curSuit" "${arrSuits[@]}") # check the current suit ...

      if [ "$indexSuit" == 0 ]; then
         arrCardsBySuitH[$indexCard]=1

      elif [ "$indexSuit" == 1 ]; then
         arrCardsBySuitD[$indexCard]=1

      elif [ "$indexSuit" == 2 ]; then
         arrCardsBySuitC[$indexCard]=1

      elif [ "$indexSuit" == 3 ]; then

         arrCardsBySuitS[$indexCard]=1
      fi

      j=$(($j + 2))
   done

   echo ${arrCardsBySuitH[@]}
   echo ${arrCardsBySuitD[@]}
   echo ${arrCardsBySuitC[@]}
   echo ${arrCardsBySuitS[@]}

   i=$(($i + 1))
   break
done

# a1=(1 2 3 4 5 6)
# a2=("A" "B" "C" "D" "E")
# myArr=(${a1[@]} ${a2[@]})

# i=0
# while [ $i -lt ${#myArr[*]} ]; do
#    # curPokerHand=${myArr[i]}
#    echo ${myArr[i]}
#    i=$(($i + 1))
# done
# echo ${myArr[@]}

# echo ${arrPokerHands[@]}
