#!/bin/bash

function getChar() {
   echo ${arrChars[$1]}
   return
}

function getMainCards() {
   local isCounter=$1
   local sum=$2
   local counter=$3
   local result=""

   if $isCounter; then
      q=0
      for i in ${!arrCards[@]}; do
         curSum=$((${arrCardsBySuit_h[$i]} + ${arrCardsBySuit_d[$i]} + ${arrCardsBySuit_c[$i]} + ${arrCardsBySuit_s[$i]}))
         if (($curSum == $sum)); then
            q=$(($q + 1))
            result+=$(getChar $(($sizeArrCards - $i)))

            if (($q == $counter)); then
               break
            fi
         fi
      done
      if (($q != $counter)); then
         result=""
      fi
   else
      for i in ${!arrCards[@]}; do
         curSum=$((${arrCardsBySuit_h[$i]} + ${arrCardsBySuit_d[$i]} + ${arrCardsBySuit_c[$i]} + ${arrCardsBySuit_s[$i]}))
         if (($curSum == $sum)); then
            result=$(getChar $(($sizeArrCards - $i)))
            break
         fi
      done
   fi

   echo $result
   return
}

function elementInArray() {
   local element=$1
   shift
   local arr=($@)
   isFound=false

   for i in ${arr[@]}; do
      if [ $i == $element ]; then
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

   for i in ${!arr[@]}; do
      if [ ${arr[$i]} == $element ]; then
         curIndex=$i
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
   result=""
   i=0
   sum=0
   while [ $i -lt $size ]; do
      if (($(($i + 4)) > $size)); then
         break

      elif (($(($i + 4)) == $size)); then
         sum=$((${arr[$i]} + ${arr[$i + 1]} + ${arr[$i + 2]} + ${arr[$i + 3]} + ${arr[0]})) # 5 4 3 2 A ...
         if (($sum == 5)); then
            result=$(getChar $(($size - $i)))
            break
         fi

      else
         sum=$((${arr[$i]} + ${arr[$i + 1]} + ${arr[$i + 2]} + ${arr[$i + 3]} + ${arr[$i + 4]}))
         if (($sum == 5)); then
            result=$(getChar $(($size - $i)))
            break
         fi
      fi
      i=$(($i + 1))
   done
   echo $result
   return
}

function checkFlush() {
   local arr=($@)

   size=${#arr[@]}
   result=""
   i=0
   sum=0
   arrIndexes=()
   while [ $i -lt $size ]; do
      if ((${arr[$i]} == 1)); then
         sum=$(($sum + 1))
         arrIndexes+=($i)

         if (($sum == 5)); then
            break
         fi
      fi
      i=$(($i + 1))
   done

   if (($sum == 5)); then
      result1=$(getChar $(($sizeArrCards - ${arrIndexes[0]})))
      result2=$(getChar $(($sizeArrCards - ${arrIndexes[1]})))
      result3=$(getChar $(($sizeArrCards - ${arrIndexes[2]})))
      result4=$(getChar $(($sizeArrCards - ${arrIndexes[3]})))
      result5=$(getChar $(($sizeArrCards - ${arrIndexes[4]})))

      result=$result1
      result+=$result2
      result+=$result3
      result+=$result4
      result+=$result5
   fi
   echo $result
   return
}

arrGameTypes=("texas-holdem" "omaha-holdem" "five-card-draw")
arrCards=("A" "K" "Q" "J" "T" "9" "8" "7" "6" "5" "4" "3" "2")
arrSuits=("h" "d" "c" "s")
arrChars=("A" "B" "C" "D" "E" "F" "G" "H" "I" "J" "K" "L" "M" "N")

sizeArrCards=${#arrCards[@]}

while read line; do
   IFS=" " read -ra arrWords <<<"$line" # get the array of words ...

   strError=""
   gameType=${arrWords[0]} # current game-type ...

   isOk=$(elementInArray "$gameType" "${arrGameTypes[@]}") # check the game-type ...
   if [ $isOk == false ]; then
      echo "Error: The '$gameType' game wasn't found. "
      continue
   fi

   [[ $gameType == "five-card-draw" ]] && startIndex=1 || startIndex=2
   [[ $gameType == "five-card-draw" ]] && boardCards="" || boardCards=${arrWords[1]} # get current 5 board cards for 'texas-holdem' and 'omaha-holdem' ...

   # get the number of cards in the poker hand ...
   numberPokerHands=2
   if [ $gameType == "omaha-holdem" ]; then
      numberPokerHands=4
   elif [ $gameType == "five-card-draw" ]; then
      numberPokerHands=5
   fi

   # check the board cards ...
   strCheckCards=$boardCards
   if [ "$boardCards" != "" ]; then
      strError+=$(checkDraw "5" "$boardCards" "Board cards")
   fi

   # check poker hands ...
   i=$startIndex
   while [ $i -lt ${#arrWords[@]} ]; do
      strError+=$(checkDraw "$numberPokerHands" "${arrWords[i]}" "Poker hands")
      strCheckCards+=${arrWords[i]}
      i=$(($i + 1))
   done

   # check the cards ...
   strError+=$(checkStrCards "$strCheckCards")

   if [ "$strError" != "" ]; then
      echo $strError
      continue
   fi

   # ************************************************************************

   arrPokerHands=() # array of poker hands ...

   i=$startIndex
   while [ $i -lt ${#arrWords[@]} ]; do
      arrPokerHands+=(${arrWords[i]})
      i=$(($i + 1))
   done

   strResult=""

   for curPokerHand in ${arrPokerHands[@]}; do

      # arrage the cards by suit ...
      arrCardsBySuit_h=(0 0 0 0 0 0 0 0 0 0 0 0 0) # h ...
      arrCardsBySuit_d=(0 0 0 0 0 0 0 0 0 0 0 0 0) # d ...
      arrCardsBySuit_c=(0 0 0 0 0 0 0 0 0 0 0 0 0) # c ...
      arrCardsBySuit_s=(0 0 0 0 0 0 0 0 0 0 0 0 0) # s ...

      curCards=$boardCards # all cards (board cards + current poker hand) ...
      curCards+=$curPokerHand

      j=0
      while [ $j -lt ${#curCards} ]; do
         curFullCard=${curCards:$j:2} # get the current full card (for example, 4c) ...

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

      result=""

      # *********************************************************
      #  check 'Straight Flush' ...
      for suit in ${arrSuits[@]}; do
         arrCardsBySuit_a=arrCardsBySuit_$suit[@]
         curArrCardsBySuit=${!arrCardsBySuit_a} # get current array by suit (for example, arrCardsBySuit_h ...)

         result=$(checkStraightFlush "${curArrCardsBySuit[@]}")
         if ((${#result} > 0)); then
            break
         fi
      done

      if ((${#result} > 0)); then
         strResult+="8$result"
         continue
      fi
      # *********************************************************

      # # *********************************************************
      #  check 'Four of a kind' ...
      result=$(getMainCards false 4 0) # get main cards (isCounter = false sum = 4 counter = 0) ...

      if ((${#result} > 0)); then
         # find a card of the maximum rank ...
         for i in ${!arrCards[@]}; do
            sum=$((${arrCardsBySuit_h[$i]} + ${arrCardsBySuit_d[$i]} + ${arrCardsBySuit_c[$i]} + ${arrCardsBySuit_s[$i]}))
            if (($sum > 0)) && (($sum != 4)); then
               result+=$(getChar $(($sizeArrCards - $i)))
               break
            fi
         done
      fi

      if ((${#result} > 0)); then
         strResult+=" 7$result"
         continue
      fi
      # *********************************************************

      # *********************************************************
      #  check 'Full House' ...
      result3=$(getMainCards false 3 0) # get main cards (isCounter = false sum = 3 counter = 0) ...

      #if 'Three of a kind' wasn't found then it isn't 'Full House' ...
      if ((${#result3} > 0)); then
         result2=$(getMainCards false 2 0) # get main cards (isCounter = false sum = 2 counter = 0) ...

         if ((${#result2} > 0)); then
            result+=$result3
            result+=$result2
         fi
      fi

      if ((${#result} > 0)); then
         strResult+=" 6$result"
         continue
      fi
      # *********************************************************

      # *********************************************************
      #  check 'Flush' ...
      for suit in ${arrSuits[@]}; do
         arrCardsBySuit_a=arrCardsBySuit_$suit[@]
         curArrCardsBySuit=${!arrCardsBySuit_a} # get current array by suit (for example, arrCardsBySuit_h ...)

         result=$(checkFlush "${curArrCardsBySuit[@]}")
         if ((${#result} > 0)); then
            break
         fi
      done

      if ((${#result} > 0)); then
         strResult+=" 5$result"
         continue
      fi
      # *********************************************************

      # *********************************************************
      #  check 'Straight' ...
      curArrResult=()
      for i in ${!arrCards[@]}; do
         sum=$((${arrCardsBySuit_h[$i]} + ${arrCardsBySuit_d[$i]} + ${arrCardsBySuit_c[$i]} + ${arrCardsBySuit_s[$i]}))
         curArrResult+=($sum)
      done

      curStartIndex=-1
      curSum=0
      for i in ${!curArrResult[@]}; do
         if ((${curArrResult[$i]} > 0)); then
            if (($curStartIndex < 0)); then
               curStartIndex=$i
            fi
            curSum=$(($curSum + 1))
            if (($curSum == 5)); then
               break
            fi
         else
            curStartIndex=-1
            curSum=0
         fi
      done

      if (($curSum == 5)); then
         result=$(getChar $(($sizeArrCards - $curStartIndex)))
      fi

      if ((${#result} > 0)); then
         strResult+=" 4$result"
         continue
      fi
      # *********************************************************

      # *********************************************************
      #  check 'Three of a kind' ...
      result3=$(getMainCards false 3 0) # get main cards (isCounter = false sum = 3 counter = 0) ...

      #if 'Three of a kind' was found ...
      if ((${#result3} > 0)); then
         result2=$(getMainCards true 1 2) # get main cards (isCounter = true sum = 1 counter = 2) ...

         result+=$result3
         result+=$result2
      fi

      if ((${#result} > 0)); then
         strResult+=" 3$result"
         continue
      fi
      # *********************************************************

      # *********************************************************
      #  check 'Two pairs' ...
      result2=$(getMainCards true 2 2) # get main cards (isCounter = true sum = 2 counter = 2) ...

      if ((${#result2} > 0)); then
         result1=$(getMainCards false 1 0) # get main cards (isCounter = false sum = 1 counter = 0) ...

         result+=$result2
         result+=$result1
      fi

      if ((${#result} > 0)); then
         strResult+=" 2$result"
         continue
      fi
      # *********************************************************

      # *********************************************************
      #  check 'Pair' ...
      result2=$(getMainCards false 2 0) # get main cards (isCounter = false sum = 2 counter = 0) ...

      if ((${#result2} > 0)); then
         result1=$(getMainCards true 1 3) # get main cards (isCounter = true sum = 1 counter = 3) ...

         result+=$result2
         result+=$result1
      fi

      if ((${#result} > 0)); then
         strResult+=" 1$result"
         continue
      fi
      # *********************************************************

      # *********************************************************
      #  check 'High card' ...
      result=$(getMainCards true 1 5) # get main cards (isCounter = true sum = 1 counter = 5) ...

      if ((${#result} > 0)); then
         strResult+=" 0$result"
         continue
      fi
      # *********************************************************
   done

   IFS=" " read -ra arrResult <<<"$strResult" # get the array of words ...

   # sort by value ...
   sizeArrResult=${#arrResult[@]}
   for i in ${!arrResult[@]}; do
      curSize=$(($sizeArrResult - $i - 1))
      j=0
      while [ $j -lt $curSize ]; do
         if [[ ${arrResult[$j]} > ${arrResult[$j + 1]} ]]; then
            curResult=${arrResult[j]}
            arrResult[$j]=${arrResult[$j + 1]}
            arrResult[$j + 1]=$curResult

            # sort poker hands ...
            curPokerHand=${arrPokerHands[j]}
            arrPokerHands[$j]=${arrPokerHands[$j + 1]}
            arrPokerHands[$j + 1]=$curPokerHand
         fi
         j=$(($j + 1))
      done
   done

   echo ${arrPokerHands[@]}
done