#!/bin/bash

#while read line; do
#echo "$line";
#done

# source "./correct.sh"

#while read line; do
#a "$line"
#done

function round() {
   echo "scale=$3;$1/$2" | bc -l
   return
}

function multiplication() {
   echo "$1*$2" | bc -l
   return
}

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

function checkStraightFlush() {
   local arr=($@)

   size=${#arr[@]}
   result=0
   i=0
   sum=0
   while [ $i -lt $size ]; do
      if (($(($i + 4)) > $size)); then
         break

      elif (($(($i + 4)) == $size)); then
         sum=$((${arr[$i]} + ${arr[$i + 1]} + ${arr[$i + 2]} + ${arr[$i + 3]} + ${arr[0]}))
         if (($sum == 5)); then
            result=$(($size - $i + 1))
            break
         fi

      else
         sum=$((${arr[$i]} + ${arr[$i + 1]} + ${arr[$i + 2]} + ${arr[$i + 3]} + ${arr[$i + 4]}))
         if (($sum == 5)); then
            result=$(($size - $i + 1))
            break
         fi
      fi
      i=$(($i + 1))
   done

   echo $(($result * 1000000000))
   return
}

arrGameTypes=("texas-holdem" "omaha-holdem" "five-card-draw")
arrCards=("A" "K" "Q" "J" "T" "9" "8" "7" "6" "5" "4" "3" "2")
arrSuits=("h" "d" "c" "s")
arrPokerHands=()

sizeArrCards=${#arrCards[@]}

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
for curPokerHand in ${arrPokerHands[@]}; do
   echo $curPokerHand

   arrCardsBySuit_h=(0 0 0 0 0 0 0 0 0 0 0 0 0) # h ...
   arrCardsBySuit_d=(0 0 0 0 0 0 0 0 0 0 0 0 0) # d ...
   arrCardsBySuit_c=(0 0 0 0 0 0 0 0 0 0 0 0 0) # c ...
   arrCardsBySuit_s=(0 0 0 0 0 0 0 0 0 0 0 0 0) # s ...

   curCards=$boardCards
   curCards+=$curPokerHand

   j=0
   while [ $j -lt ${#curCards} ]; do
      curFullCard=${curCards:$j:2} # get the current full card (for example, 4c) ...
      # echo $curFullCard

      curCard=${curFullCard:0:1}                               # get the current card ...
      curSuit=${curFullCard:1:2}                               # get the suit of the current cards ...
      indexCard=$(getIndexInArray "$curCard" "${arrCards[@]}") # check the current card ...
      indexSuit=$(getIndexInArray "$curSuit" "${arrSuits[@]}") # check the current suit ...

      if (($indexSuit == 0)); then
         arrCardsBySuit_h[$indexCard]=1

      elif (($indexSuit == 1)); then
         arrCardsBySuit_d[$indexCard]=1

      elif (($indexSuit == 2)); then
         arrCardsBySuit_c[$indexCard]=1

      elif (($indexSuit == 3)); then
         arrCardsBySuit_s[$indexCard]=1
      fi
      j=$(($j + 2))
   done
   # echo ${arrCardsBySuit_h[@]}
   # echo ${arrCardsBySuit_d[@]}
   # echo ${arrCardsBySuit_c[@]}
   # echo ${arrCardsBySuit_s[@]}
   result=0

   # *********************************************************
   #  check 'Straight Flush' ...
   k=0
   while [ $k -lt ${#arrSuits[@]} ]; do
      arrCardsBySuit_a=arrCardsBySuit_${arrSuits[$k]}[@]
      curArrCardsBySuit=${!arrCardsBySuit_a} # get current array by suit (for example, arrCardsBySuit_h ...)

      result=$(checkStraightFlush "${curArrCardsBySuit[@]}")
      if (($result > 0)); then
         break
      fi
      k=$(($k + 1))
   done

   echo "check 'Straight Flush' ... $result"

   if (($result > 0)); then
      arrResult+=($result)
      i=$(($i + 1))
      continue
   fi
   # *********************************************************

   # *********************************************************
   #  check 'Four of a kind' ...
   curResult=0
   for index in ${!arrCards[@]}; do
      sum=$((${arrCardsBySuit_h[$index]} + ${arrCardsBySuit_d[$index]} + ${arrCardsBySuit_c[$index]} + ${arrCardsBySuit_s[$index]}))
      if (($sum == 4)); then
         curResult=$(($sizeArrCards - $index + 1))
         arrCardsBySuit_h[$index]=0
         arrCardsBySuit_d[$index]=0
         arrCardsBySuit_c[$index]=0
         arrCardsBySuit_s[$index]=0
         break
      fi
   done
   # echo "-----------------------------"
   # echo ${arrCardsBySuit_h[@]}
   # echo ${arrCardsBySuit_d[@]}
   # echo ${arrCardsBySuit_c[@]}
   # echo ${arrCardsBySuit_s[@]}

   if (($curResult > 0)); then
      # find a card of the maximum rank ...
      for index in ${!arrCards[@]}; do
         sum=$((${arrCardsBySuit_h[$index]} + ${arrCardsBySuit_d[$index]} + ${arrCardsBySuit_c[$index]} + ${arrCardsBySuit_s[$index]}))
         if (($sum > 0)); then
            curResult+=$(round $(($sizeArrCards - $index + 1)) 100 2)
            # echo $curResult
            break
         fi
      done
      result=$(multiplication $curResult 100000000)
      result=$(round $result 1 0)
   fi

   echo "check 'Four of a kind' ... $result"

   if (($result != 0)); then
      arrResult+=($result)
      i=$(($i + 1))
      continue
   fi
   # *********************************************************

   # *********************************************************
   #  check 'Full House' ...
   curResult=0
   curResult2=0
   curFloatResult2=0
   curResult3=0
   for index in ${!arrCards[@]}; do
      sum=$((${arrCardsBySuit_h[$index]} + ${arrCardsBySuit_d[$index]} + ${arrCardsBySuit_c[$index]} + ${arrCardsBySuit_s[$index]}))
      if (($sum == 3)); then
         curResult3=$(($sizeArrCards - $index + 1))
         break
      fi
   done

   #if 'Three of a kind' wasn't found then it isn't 'Full House' ...
   if (($curResult3 > 0)); then
      for index in ${!arrCards[@]}; do
         sum=$((${arrCardsBySuit_h[$index]} + ${arrCardsBySuit_d[$index]} + ${arrCardsBySuit_c[$index]} + ${arrCardsBySuit_s[$index]}))
         if (($sum == 2 && $curResult2 == 0)); then
            curResult2=$(round $(($sizeArrCards - $index + 1)) 100 2)
            curResult2=$(multiplication $curResult2 10000000)
            curResult2=$(round $curResult2 1 0)
            echo $curResult2
            break
         fi
      done

      if (($curResult2 > 0)); then
         curResult3=$(multiplication $curResult3 10000000)
         result=$(($curResult3 + $curResult2))
      fi
   fi

   echo "check 'Full House' ... $result"

   if (($result != 0)); then
      arrResult+=($result)
      i=$(($i + 1))
      continue
   fi
   # *********************************************************

   echo ${arrResult[@]}
   # break
done

echo "arrResult - ${arrResult[@]}"

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
