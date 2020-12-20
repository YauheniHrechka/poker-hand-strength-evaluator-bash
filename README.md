
## Implementation

* `"texas-holdem"` - done
* `"omaha-holdem"` - works like `"texas-holdem"` (without from 3 out of 5 board cards and 2 out of 4 hand cards)
* `"five-card-draw"` - done

### `Start project`

```
run.sh < test-cases.txt > solutions.txt
```

## Description

To solve the task, I used the matrix.
Each row contains cards of the same suit (from "A" to "2").

A matrix is created for each poker hand and board cards.
In the beginning, each value is "0".
For each card, the value is "1".

For example, `4cKs4h8s7s Ad4s`

```
     "A" "K" "Q" "J" "T" "9" "8" "7" "6" "5" "4" "3" "2")
"h"   0   0   0   0   0   0   0   0   0   0   1   0   0
"d"   1   0   0   0   0   0   0   0   0   0   0   0   0
"c"   0   0   0   0   0   0   0   0   0   0   1   0   0
"s"   0   1   0   0   0   0   1   1   0   0   1   0   0
```

## Search for combinations

Search for combinations from `"Straight Flush"` to `"High card"`.

### `Straight Flush`

The sum of 5 consecutive numbers of the same suit (row) is 5 (including "5" "4" "3" "2" "A").

### `Four of a kind`

The sum of 4 consecutive numbers of the same rank (column) is 4
and the highest card of any suit (value "1").

### `Full House`

The sum of 4 consecutive numbers of the same rank (column) is 3
and the sum of 4 consecutive numbers of the same rank (column) is 2.

### `Flush`

The sum of the numbers of the same suit (row) is 5.

### `Straight`

The sum of 5 consecutive numbers of the different suits (row) is 5 (including "5" "4" "3" "2" "A").

### `Three of a kind`

The sum of 4 consecutive numbers of the same rank (column) is 3
and two highest cards of any suit (value "1").

### `Two pairs`

Two sums of 4 consecutive numbers of the same rank (column) are 2
and the highest card of any suit (value "1").

### `Pair`

The sum of 4 consecutive numbers of the same rank (column) is 2
and three highest cards of any suit (value "1").

### `High card`

The sum of the 5 highest cards of any suit (row) is 5.

* After that, each result is added to `strResult` in the following form:
```
[combination number (from "8" to "0")][value by index of the highest card of the combination]
```

```
arrChars=("A" "B" "C" "D" "E" "F" "G" "H" "I" "J" "K" "L" "M" "N")
```

For example, `4cKs4h8s7s Ad4s`
```
4c4h4sAdKs ("Three of a kind")
strResult = 3DNM

3 - "Three of a kind"
D - 4c4h4s
N - Ad
M - Ks
```

For example, `4cKs4h8s7s Ad4s Ac4d As9s KhKd 5d6d`

```
 arrPokerHands = Ad4s Ac4d As9s KhKd 5d6d
     strResult = 3DNM 3DNM 5NMIHG 6MD 4H
```

* Convert the string `strResult` to the array `arrResult`

* Ascending sort

```    
arrPokerHands = Ad4s Ac4d 5d6d As9s KhKd
    arrResult = 3DNM 3DNM 4H 5NMIHG 6MD
```
* Put '=' between the same poker 

```
Ad4s=Ac4d 5d6d As9s KhKd
```

## Errors

The following checks are implemented:

* checking the number of cards on the board
* checking the number of cards in a poker hand
* checking an already added card