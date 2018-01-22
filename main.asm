TITLE Test3
;Program Description :Game of connect three on a 4x4 matrix
;Author : Christina Tsui
;Creation Date : 4/30/17

INCLUDE Irvine32.inc

;Macros to clear all the registers
clearEAX TEXTEQU <mov eax, 0>
clearEBX TEXTEQU <mov ebx, 0>
clearECX TEXTEQU <mov ecx, 0>
clearEDX TEXTEQU <mov edx, 0>
clearESI TEXTEQU <mov esi, 0>
clearEDI TEXTEQU <mov edi, 0>

.data 

instructions1 byte  'Connect Three is a two-player connection game. ', 0ah, 0dh,
					'Take turns dropping colored discs from the top ',0ah, 0dh,
					'into a four-column, four-row vertically suspended grid. ',0ah, 0dh, 0h
					
instructions2 byte 'The pieces fall straight down, occupying the next available',0ah, 0dh,
					'space within the column. ', 0ah, 0dh, 0h
				
instructions3 byte  'The objective of the game is to be the first to form',0ah, 0dh,
					'a horizontal, vertical, or diagonal line of three of',0ah, 0dh,
					'ones own discs. Each player has eight turns, the game',0ah, 0dh,
					'is a tie after 16 turns have been taken.' ,0ah, 0dh, 0h
					
instructions4 byte  'After selecting number of perfered players, select',0ah, 0dh,
					'the column you would like to have your piece fall ',0ah, 0dh,
					'down from. Have fun!',0ah, 0dh, 0h


prompt byte 'There are three ways to play this game. To start a game select your game style: ', 0Ah, 0Dh,
			'1) Player 1 vs. Player 2', 0Ah, 0Dh,
			'2) Player 1 vs. Computer 1', 0Ah, 0Dh,
			'3) Computer 1 vs. Computer 2', 0Ah, 0Dh,
			'4) Exit, I do not want to play anymore!', 0Ah, 0Dh,  0h

oops byte 'Invalid Entry.  Please try again.', 0Ah, 0Dh, 0h
userinput BYTE 0h, 0h

beenAdded byte 'Player move has been added to the board.', 0ah, 0dh, 0h
tooMany byte 'Oops, no room in this column for the piece. This turn has been lost...', 0ah, 0dh, 0h 


connect3Banner1 byte '   _|_|_|    _|_|    _|      _|  _|      _|  _|_|_|_|    _|_|_|  _|_|_|_|_|  _|_|_|    ', 0ah, 0dh,
					 ' _|        _|    _|  _|_|    _|  _|_|    _|  _|        _|            _|            _|  ', 0h

connect3Banner2 byte ' _|        _|    _|  _|  _|  _|  _|  _|  _|  _|_|_|    _|            _|        _|_|    ', 0ah, 0dh,
					 ' _|        _|    _|  _|    _|_|  _|    _|_|  _|        _|            _|            _|  ', 0ah, 0dh,
					 '   _|_|_|    _|_|    _|      _|  _|      _|  _|_|_|_|    _|_|_|      _|      _|_|_|    ', 0ah, 0dh, 0h



;Matrix/Board data
matrixSize byte 16
x4Matrix BYTE  0h,  0h,  0h,  0h
RowSize = ($ - x4Matrix);Row major order, starts @ 5
         BYTE  0h,  0h,  0h,  0h
         BYTE  0h,  0h,  0h,  0h
         BYTE  0h,  0h,  0h,  0h

.code

;prototypes------------------------------------
createBoard PROTO, parm1:byte, parm2:ptr byte
displayBoard PROTO, parm1:byte, parm2:ptr byte
dropPiece1 PROTO, parm1:byte, parm2:ptr byte
dropPiece2 PROTO, parm1:byte, parm2:ptr byte
dropPiece3 PROTO, parm1:byte, parm2:ptr byte
dropPiece4 PROTO, parm1:byte, parm2:ptr byte
pieceOutput PROTO, parm1:byte

pvpGame PROTO,parm1:byte, parm2:ptr byte
player1Move PROTO, parm1:byte, parm2:ptr byte
player2Move PROTO, parm1:byte, parm2:ptr byte

pvcGame PROTO, parm1:byte, parm2:ptr byte
cvcGame PROTO, parm1:byte, parm2:ptr byte
PCmove1 PROTO, parm1:byte, parm2:ptr byte
PCmove2 PROTO, parm1:byte, parm2:ptr byte

check3Match PROTO, parm1:byte, parm2:ptr byte
rowSearch PROTO, parm1:byte, parm2:ptr byte
columnSearch PROTO, parm1:byte, parm2:ptr byte
diagonalRLSearch PROTO, parm1:byte, parm2:ptr byte
diagonalLRSearch PROTO, parm1:byte, parm2:ptr byte
miniDiagRL PROTO, parm1:byte, parm2:ptr byte
miniDiagRL2 PROTO, parm1:byte, parm2:ptr byte
miniDiagLR PROTO, parm1:byte, parm2:ptr byte
miniDiagLR2 PROTO, parm1:byte, parm2:ptr byte


tallyUp1 PROTO, parm1:ptr byte
tallyUp2 PROTO, parm1:ptr byte

winOutput PROTO, parm1:byte, parm2:ptr byte
theTotalWins PROTO, parm1:byte

;-----------------------------------------------

main PROC

clearEAX
clearEBX
clearECX
clearEDX
clearESI
clearEDI

mov edx, offset connect3Banner1
call writestring
call crlf
mov edx, offset connect3Banner2
call writestring
call crlf

mov edx, offset instructions1
call writestring
call crlf
mov edx, offset instructions2
call writestring
call crlf
mov edx, offset instructions3
call writestring
call crlf
mov edx, offset instructions4
call writestring
call crlf
call waitmsg

call randomize ;set seed for future PC playermove,only need once

startHere:
INVOKE createBoard, matrixSize, addr x4Matrix;create a new board game
call clrscr
mov edx, offset connect3Banner1;kewl banner output
call writestring
call crlf
mov edx, offset connect3Banner2
call writestring
call crlf

call crlf
mov edx, offset prompt
call writestring
call readdec;get users input 
mov userinput, al 

opt1:;PvP
cmp userinput, 1
jne opt2
INVOKE pvpGame, matrixSize, addr x4Matrix;pvp
call crlf
jmp startHere;return to menu 

opt2:;PVC
cmp userinput, 2
jne opt3
INVOKE pvcGame, matrixSize, addr x4Matrix;PvC
call crlf
jmp startHere;return to menu 

opt3:;CVC
cmp userinput, 3
jne done
INVOKE cvcGame, matrixSize, addr x4Matrix;CvC
call crlf
jmp startHere;return to menu 

done:;Option 4
cmp userinput, 4
je  theEnd;Leave program
mov edx, OFFSET oops;tell user mistake made
call WriteString
call waitmsg
jmp starthere;On return restart menu

theEnd:
INVOKE winOutput,  matrixSize, addr x4Matrix;display the wins and losses
call waitmsg
exit
main ENDP

;-----------------------------------------------------------------
createBoard PROC, parm1:byte, parm2:ptr byte
	;Desc: Traverses through the 2D array/matrix/board
	;	sets each piece to 0 so that it is a new game board	
	;	Will happen @ start of each new game
	;Recceives: matrixSize, 
	;			addr x4Matrix
	;Returns: esi - x4Matrix
;-----------------------------------------------------------------

.code

movzx ecx,parm1;sizeof
mov	esi,parm2;matrix


column_Index1 = 0
column_Index2 = 1
column_Index3 = 2
column_Index4 = 3

mov edx, column_Index1;0, start at begining of row 
mov ecx, RowSize ;should be 5, goes through 1 entire row

Neo:;moving through the Matrix and setting all values to 0 @ start of each game 
push ecx

mov ebx, RowSize * column_Index1
add ebx, edx;Add the colum to the rowsize
mov al, 0 
mov [ebx + esi], al ;rese value to 0 
inc edx;increases column

pop ecx
LOOP Neo

clearEDX
mov ecx, RowSize ;should be 5, goes through 1 entire row

Neo1:;moving through the Matrix and setting all values to 0 @ start of each game 
push ecx

mov ebx, RowSize * column_Index2
add ebx, edx;Add the colum to the rowsize
mov al, 0 
mov [ebx + esi], al ;rese value to 0 
inc edx;increases column

pop ecx
LOOP Neo1

clearEDX
mov ecx, RowSize ;should be 5, goes through 1 entire row

Neo2:;moving through the Matrix and setting all values to 0 @ start of each game 
push ecx

mov ebx, RowSize * column_Index3
add ebx, edx;Add the colum to the rowsize
mov al, 0 
mov [ebx + esi], al ;rese value to 0 
inc edx;increases column

pop ecx
LOOP Neo2

clearEDX
mov ecx, RowSize ;should be 5, goes through 1 entire row

Neo3:;moving through the Matrix and setting all values to 0 @ start of each game 
push ecx

mov ebx, RowSize * column_Index4
add ebx, edx;Add the colum to the rowsize
mov al, 0 
mov [ebx + esi], al ;rese value to 0 
inc edx;increases column

pop ecx
LOOP Neo3

mov player1Count, 0;reset counter
mov player2Count, 0 ;reset counter

ret
createBoard ENDP

;------------------------------------------------
dropPiece1 PROC, parm1:byte, parm2:ptr byte
	;Desc: Traverses through the 2D array/matrix/board
	;	Works up column 0 adding the players piece.
	;	At the end outputs if action was done or not. 
	;Recceives: matrixSize, 
	;			addr x4Matrix
	;Returns: esi - x4Matrix

;------------------------------------------------
.code
mov cl,parm1;player number, need to be put into place
mov	esi,parm2;offset Matrix

;check from bottom to top 
row_index3a = 3;Move to R:3
column_index3a = 0;Move to CL0

mov ebx,OFFSET x4Matrix ; table offset
add ebx,RowSize * row_index3a ; row offset
mov esi, column_index3a
mov al, [ebx + esi]

cmp al, 0;if what is currnetly on board is empty, add players piece
je addPiece;else goto next row 

;--------------next up

row_index2a = 2;Move to R:2
column_index2a = 0;Move to c:0

mov ebx,OFFSET x4Matrix ; table offset
add ebx,RowSize * row_index2a ; row offset
mov esi, column_index2a
mov al, [ebx + esi]

cmp al, 0;if what is currnetly on board is empty, add players piece
je addPiece;else goto next row 

;--------------next up

row_index1a = 1;Move to R:1
column_index1a = 0;Move to C:0

mov ebx,OFFSET x4Matrix ; table offset
add ebx,RowSize * row_index1a; row offset
mov esi, column_index1a
mov al, [ebx + esi]

cmp al, 0;if what is currnetly on board is empty, add players piece
je addPiece;else goto next row 

;-----------------next up

row_index0a = 0;Move to R:0
column_index0a = 0;Move to C:0

mov ebx,OFFSET x4Matrix; table offset
add ebx,RowSize * row_index0a ; row offset
mov esi, column_index0a
mov al, [ebx + esi]
cmp al, 0;if what is currnetly on board is empty, add players piece
je addPiece;else goto next row 
jmp theEndNotAdded

addPiece:;move players piece into matrix
mov [ebx + esi], cl;player number stored in ecx @ start of function parm1
jmp theEndAdded;after move leave the function for next players move
jmp theEndNotAdded

theEndAdded:
mov edx, offset beenAdded
call writestring
jmp theEnd

theEndNotAdded:
mov edx, offset tooMany
call writestring
jmp theEnd

theEnd:

ret
dropPiece1 ENDP

;------------------------------------------------
dropPiece2 PROC, parm1:byte, parm2:ptr byte
	;Desc: Traverses through the 2D array/matrix/board
	;	Works up column 1 adding the players piece.
	;	At the end outputs if action was done or not. 
	;Recceives: matrixSize, 
	;			addr x4Matrix
	;Returns: esi - x4Matrix

;------------------------------------------------
.code
mov cl,parm1;player number, need to be put into place
mov	esi,parm2;offset Matrix

;check from bottom to top 
row_index3b = 3;Move to R:3
column_index3b = 1;Move to C:1

mov ebx,OFFSET x4Matrix ; table offset
add ebx,RowSize * row_index3b ; row offset
mov esi, column_index3b
mov al, [ebx + esi]

cmp al, 0;if what is currnetly on board is empty, add players piece
je addPiece;else goto next row 

;--------------next up

row_index2b = 2;Move to R:2
column_index2b = 1;Move to c:1

mov ebx,OFFSET x4Matrix ; table offset
add ebx,RowSize * row_index2b ; row offset
mov esi, column_index2b
mov al, [ebx + esi]

cmp al, 0;if what is currnetly on board is empty, add players piece
je addPiece;else goto next row 

;--------------next up

row_index1b = 1;Move to R:1
column_index1b = 1;Move to C:1

mov ebx,OFFSET x4Matrix ; table offset
add ebx,RowSize * row_index1b ; row offset
mov esi, column_index1b
mov al, [ebx + esi]

cmp al, 0;if what is currnetly on board is empty, add players piece
je addPiece;else goto next row 

;-----------------next up

row_index0b = 0;Move to R:0
column_index0b = 1;Move to C:0

mov ebx,OFFSET x4Matrix; table offset
add ebx,RowSize * row_index0b; row offset
mov esi, column_index0b
mov al, [ebx + esi]
cmp al, 0;if what is currnetly on board is empty, add players piece
je addPiece;else goto next row 
jmp theEndNotAdded

addPiece:;move players piece into matrix
mov [ebx + esi], cl;player number stored in ecx @ start of function parm1
jmp theEndAdded;after move leave the function for next players move
jmp theEndNotAdded

theEndAdded:
mov edx, offset beenAdded
call writestring
jmp theEnd

theEndNotAdded:
mov edx, offset tooMany
call writestring
jmp theEnd

theEnd:

ret
dropPiece2 ENDP

;------------------------------------------------
dropPiece3 PROC, parm1:byte, parm2:ptr byte
	;Desc: Traverses through the 2D array/matrix/board
	;	Works up column 2 adding the players piece.
	;	At the end outputs if action was done or not. 
	;Recceives: matrixSize, 
	;			addr x4Matrix
	;Returns: esi - x4Matrix

;------------------------------------------------

.code
mov cl,parm1;player number, need to be put into place
mov	esi,parm2;offset Matrix

;check from bottom to top 
row_index3c = 3;Move to R:3
column_index3c = 2;Move to CL0

mov ebx,OFFSET x4Matrix ; table offset
add ebx,RowSize * row_index3c ; row offset
mov esi, column_index3c
mov al, [ebx + esi]

cmp al, 0;if what is currnetly on board is empty, add players piece
je addPiece;else goto next row 

;--------------next up

row_index2c = 2;Move to R:2
column_index2c = 2;Move to c:0

mov ebx,OFFSET x4Matrix ; table offset
add ebx,RowSize * row_index2c ; row offset
mov esi, column_index2c
mov al, [ebx + esi]

cmp al, 0;if what is currnetly on board is empty, add players piece
je addPiece;else goto next row 

;----------------next up

row_index1c = 1;Move to R:1
column_index1c = 2;Move to C:0

mov ebx,OFFSET x4Matrix ; table offset
add ebx,RowSize * row_index1c ; row offset
mov esi, column_index1c
mov al, [ebx + esi]

cmp al, 0;if what is currnetly on board is empty, add players piece
je addPiece;else goto next row 

;-----------------next up

row_index0c = 0;Move to R:0
column_index0c = 2;Move to C:0

mov ebx,OFFSET x4Matrix; table offset
add ebx,RowSize * row_index0c ; row offset
mov esi, column_index0c
mov al, [ebx + esi]
cmp al, 0;if what is currnetly on board is empty, add players piece
je addPiece;else goto next row 
jmp theEndNotAdded

addPiece:;move players piece into matrix
mov [ebx + esi], cl;player number stored in ecx @ start of function parm1
jmp theEndAdded;after move leave the function for next players move
jmp theEndNotAdded

theEndAdded:
mov edx, offset beenAdded
call writestring
jmp theEnd

theEndNotAdded:
mov edx, offset tooMany
call writestring
jmp theEnd

theEnd:

ret
dropPiece3 ENDP

;------------------------------------------------
dropPiece4 PROC, parm1:byte, parm2:ptr byte
	;Desc: Traverses through the 2D array/matrix/board
	;	Works up column 3 adding the players piece.
	;	At the end outputs if action was done or not. 
	;Recceives: matrixSize, 
	;			addr x4Matrix
	;Returns: esi - x4Matrix

;------------------------------------------------

.code
mov cl, parm1;player number, need to be put into place
mov	esi, parm2;offset Matrix

;check from bottom to top 
row_index3d = 3;Move to R:3
column_index3d = 3;Move to C:1

mov ebx,OFFSET x4Matrix ; table offset
add ebx,RowSize * row_index3d ; row offset
mov esi,column_index3d
mov al, [ebx + esi]

cmp al, 0;if what is currnetly on board is empty, add players piece
je addPiece;else goto next row 

;--------------next up

row_index2d = 2;Move to R:2
column_index2d = 3;Move to c:1

mov ebx,OFFSET x4Matrix ; table offset
add ebx,RowSize * row_index2d ; row offset
mov esi, column_index2d
mov al, [ebx + esi]

cmp al, 0;if what is currnetly on board is empty, add players piece
je addPiece;else goto next row 

;--------------next up

row_index1d = 1;Move to R:1
column_index1d = 3;Move to C:1

mov ebx,OFFSET x4Matrix ; table offset
add ebx,RowSize * row_index1d ; row offset
mov esi, column_index1d
mov al, [ebx + esi]

cmp al, 0;if what is currnetly on board is empty, add players piece
je addPiece;else goto next row 

;-----------------next up

row_index0d = 0;Move to R:0
column_index0d = 3;Move to C:0

mov ebx,OFFSET x4Matrix; table offset
add ebx,RowSize * row_index0d ; row offset
mov esi,column_index0d
mov al, [ebx + esi]
cmp al, 0;if what is currnetly on board is empty, add players piece
je addPiece;else goto next row 
jmp theEndNotAdded

addPiece:;move players piece into matrix
mov [ebx + esi], cl;player number stored in ecx @ start of function parm1
jmp theEndAdded;after move leave the function for next players move
jmp theEndNotAdded

theEndAdded:
mov edx, offset beenAdded
call writestring
jmp theEnd

theEndNotAdded:
mov edx, offset tooMany
call writestring
jmp theEnd

theEnd:

ret
dropPiece4 ENDP

;-----------------------------------------------------------------
displayBoard PROC, parm1:byte, parm2:ptr byte
	;Desc: Traverses through the 2D array/matrix
	;	output the character in that element. Will also	
	;	output header and apropriate spaces between letters
	;Recceives: matrixSize, 
	;			addr x5Matrix
	;Returns: esi - x5Matrix
;-----------------------------------------------------------------

.data

matrixOutput byte 'The current game board: ', 0ah, 0dh, 0h
tabSpace byte     '              ', 0h
header byte       ' 1  2  3  4 ', 0h
baseSpace byte	  '------------', 0ah, 0dh, 0h

.code

movzx ecx,parm1;sizeof
mov	esi,parm2;offset Matrix

call clrscr;clearscreen
mov edx, offset connect3Banner1;kewl banner output
call writestring
call crlf
mov edx, offset connect3Banner2
call writestring

call crlf
mov edx, offset matrixOutput
call writestring

mov edx, offset header
call writestring 
call crlf;next line

clearEDX
mov ecx, RowSize ;should be 5, goes through 1 entire row

Neo:;moving through the Matrix
push ecx
mov al, '|'
call writechar
mov ebx, RowSize * 0
add ebx, edx
clearEAX
mov al, [ebx + esi];get the current board piece
;Function that would output a number based off value in matrix
INVOKE pieceOutput, al
mov al, '|'
call writechar
inc edx;increases column
pop ecx
LOOP Neo

call Crlf;next line
mov ecx, RowSize ;should be 5, goes through 1 entire row
clearEDX

Neo1:;moving through the Matrix
push ecx
mov al, '|'
call writechar
mov ebx, RowSize * 1
add ebx, edx
clearEAX
mov al, [ebx + esi];get the current board piece
;Function that would output a number based off value in matrix
INVOKE pieceOutput, al
mov al, '|'
call writechar
inc edx;increases column
pop ecx
LOOP Neo1

call Crlf;next line
mov ecx, RowSize ;should be 5, goes through 1 entire row
clearEDX

Neo2:;moving through the Matrix
push ecx
mov al, '|'
call writechar
mov ebx, RowSize * 2
add ebx, edx
clearEAX
mov al, [ebx + esi];get the current board piece
;Function that would output a number based off value in matrix
INVOKE pieceOutput, al
mov al, '|'
call writechar
inc edx;increases column
pop ecx
LOOP Neo2

call Crlf;next line
mov ecx, RowSize ;should be 5, goes through 1 entire row
clearEDX

Neo3:;moving through the Matrix
push ecx
mov al, '|'
call writechar
mov ebx, RowSize * 3
add ebx, edx
clearEAX
mov al, [ebx + esi];get the current board piece
;Function that would output a color based off value in matrix
INVOKE pieceOutput, al
mov al, '|'
call writechar
inc edx;increases column
pop ecx
LOOP Neo3

call Crlf
mov edx, offset baseSpace
call writestring
call Crlf


ret
displayBoard ENDP

;--------------------------------------------------
pieceOutput PROC, parm1:byte,
;Desc: This takes in the piece number and will output a yellow
	;	for 2, blue for 1 and blank for 0
	;	This is done for each slot of the game display	
	;Recceives: byte player number, 
	;			
	;Returns: - nothing, just outputs 
;--------------------------------------------------

.data

yellow = 14
lightblue = 9
black = 0
lightgrey = 7

spaceString byte ' ', 0h

.code

mov al, parm1;current piece 
push edx

cmp al, 0
je empty
cmp al, 1
je player1Piece
cmp al, 2
je player2Piece

empty:
mov al, ' '
call writechar
jmp theEnd

player1Piece:
clearEAX
mov  eax, lightblue + (lightblue);player2 color
call settextcolor
mov edx, offset spaceString
call writestring
jmp theEnd

player2Piece:
clearEAX
mov  eax, yellow + (yellow * 16) ;player 1 color
call settextcolor
mov edx, offset spaceString
call writestring
jmp theEnd

theEnd:
mov  eax, lightgray + (black);reset color
call settextcolor
pop edx

ret
pieceOutput ENDP


;----------------------------------------------------------------------
pvpGame PROC, parm1:byte, parm2:ptr byte
	;Desc: This is allow players versus player to play.
	;	The player that goes first is choses at random.
	;	Will also call function that checks for winning match 
	;Recceives: matrixSize, 
	;			addr x4Matrix
	;Returns: esi - x4Matrix
;----------------------------------------------------------------------

.data

noWinner byte 'No winner this round. This is a tied game.', 0ah, 0dh, 0h

.code

movzx ecx,parm1;sizeof
mov	esi,parm2;offset Matrix

mov ecx, 8;max number of moves that can be made with 0 matches

mov eax, 2;choose random player with 0 to n-1
call randomrange ;random number 0 or 1

cmp eax,0
je takeYourTurn1;p1first
jmp takeYourTurn2;pcfirst

takeYourTurn1:;player1 goes first 
push ecx
INVOKE displayBoard, matrixSize, addr x4Matrix ;output current board with number header
INVOKE player1move, matrixSize, addr x4Matrix 
INVOKE check3Match, matrixSize, addr x4Matrix;run function to check current board for match

;if a winner is found, stop the game
cmp endGame, 0;if 0 no winner yet, else there is winner
jne theEnd

INVOKE displayBoard, matrixSize, addr x4Matrix ;output current board with number header
INVOKE player2move, matrixSize, addr x4Matrix
INVOKE check3Match, matrixSize, addr x4Matrix;run function to check current board for match

pop ecx
;if a winner is found, stop the game
cmp endGame, 0;if 0 no winner yet, else there is winner
jne theEnd

LOOP takeYourTurn1
jmp comparing

takeYourTurn2:;pc goes first 
push ecx
INVOKE displayBoard, matrixSize, addr x4Matrix ;output current board with number header
INVOKE player2move, matrixSize, addr x4Matrix 
INVOKE check3Match, matrixSize, addr x4Matrix;run function to check current board for match
;if a winner is found, stop the game
cmp endGame, 0;if 0 no winner yet, else there is winner
jne theEnd

INVOKE displayBoard, matrixSize, addr x4Matrix ;output current board with number header
INVOKE player1move, matrixSize, addr x4Matrix
INVOKE check3Match, matrixSize, addr x4Matrix;run function to check current board for match

pop ecx
;if a winner is found, stop the game
cmp endGame, 0;if 0 no winner yet, else there is winner
jne theEnd

LOOP takeYourTurn2

comparing:
cmp ecx, 0;need to see if the ecx gets to 0, would mean no one won
je noWin
jmp theEnd

noWin:
mov edx, offset noWinner
call writestring
jmp theEnd

theEnd:
call waitmsg
mov al, endGame
INVOKE theTotalWins, al;add to Winner count depending on number sent in.
mov endGame, 0 ;reset endGame at end of game

ret
pvpGame ENDP


;-----------------------------------------------------------------
player1Move PROC, parm1:byte, parm2:ptr byte
	;Desc: This is allow players 1 to pick the column they want.
	;	their piece to fall down, depending on column chosen
	;	The switchcase will set off based on their chosen column
	;Recceives: matrixSize, 
	;			addr x4Matrix
	;Returns: esi - x4Matrix
;-----------------------------------------------------------------

.data

yourMove1 byte 'Player 1:It is your turn to make a move. Please enter the number that corresponds to the ', 0ah, 0dh,
	       'column you would like your piece to fall from. If you want to skip your turn enter any number bigger than 5.',0ah, 0dh,
	       'Remember, your pieces are blue', 0ah, 0dh, 0h

user1Move byte 0h

skiped byte 'You skipped your turn...', 0ah, 0dh, 0h

.code

movzx ecx,parm1;sizeof
mov	esi,parm2;matrix

mov edx, offset yourMove1
call writestring
call readdec;get users input 
mov user1Move, al 

cmp user1Move, 1
jne opt2
INVOKE dropPiece1, 1, addr x4Matrix;Drop piece down column 1, player 1
jmp theEnd

opt2:;if user choose column 2
cmp user1Move, 2
jne opt3
INVOKE dropPiece2, 1, addr x4Matrix;Drop piece down column 1, player 1;Drop piece down column 2
jmp theEnd

opt3:;if user choose column 3
cmp user1Move, 3
jne opt4
INVOKE dropPiece3, 1, addr x4Matrix;Drop piece down column 3
jmp theEnd 

opt4:;if user choose column 4
cmp user1Move, 4
jne done
INVOKE dropPiece4, 1, addr x4Matrix;drop piece down column 4
jmp theEnd 

done:;Move out of bounds
mov edx, OFFSET skiped;tell user mistake made
call WriteString
call waitmsg
jmp theEnd

theEnd:

ret
player1Move ENDP

;-----------------------------------------------------------------
player2Move PROC, parm1:byte, parm2:ptr byte
	;Desc: This is allow players 2 to pick the column they want.
	;	their piece to fall down, depending on column chosen
	;	The switchcase will set off based on their chosen column
	;Recceives: matrixSize, 
	;			addr x4Matrix
	;Returns: esi - x4Matrix
;-----------------------------------------------------------------

.data

yourMove2 byte 'Player 2:It is your turn to make a move. Please enter the number that corresponds to the ', 0ah, 0dh,
	       'column you would like your piece to fall from. If you want to skip your turn enter any number bigger than 5.',0ah, 0dh,
	       'Remember, your pieces are yellow', 0ah, 0dh, 0h

userMove2 byte 0h

.code

movzx ecx,parm1;sizeof
mov	esi,parm2;matrix

mov edx, offset yourMove2
call writestring
call readdec;get users input 
mov userMove2, al 

cmp userMove2, 1
jne opt2
INVOKE dropPiece1, 2, addr x4Matrix;Drop player 2 piece down column 1
jmp theEnd

opt2:;if user choose column 2
cmp userMove2, 2
jne opt3
INVOKE dropPiece2, 2, addr x4Matrix;Drop player 2 piece down column 2
jmp theEnd

opt3:;if user choose column 3
cmp userMove2, 3
jne opt4
INVOKE dropPiece3, 2, addr x4Matrix;Drop player 2 piece down column 3
jmp theEnd 

opt4:;if user choose column 4
cmp userMove2, 4
jne done
INVOKE dropPiece4, 2, addr x4Matrix;drop player 2 piece down column 4
jmp theEnd 

done:;Move out of bounds, skipped
mov edx, OFFSET skiped;tell user mistake made
call WriteString
call waitmsg
jmp theEnd

theEnd:

ret
player2Move ENDP

;----------------------------------------------------------------------
pvcGame PROC, parm1:byte, parm2:ptr byte
	;Desc: This is allow players versus computer to play.
	;	The player that goes first is choses at random.
	;	Will also call function that checks for winning match 
	;Recceives: matrixSize, 
	;			addr x4Matrix
	;Returns: esi - x4Matrix
;----------------------------------------------------------------------

.code

movzx ecx,parm1;sizeof
mov	esi,parm2;offset Matrix

mov ecx, 8;max number of moves that can be made with 0 matches

mov eax, 2;choose random player with 0 to n-1
call randomrange ;random number 0 or 1

cmp eax,0
je takeYourTurn1;p1first
jmp takeYourTurn2;pcfirst

takeYourTurn1:;player1 goes first 
push ecx
INVOKE displayBoard, matrixSize, addr x4Matrix ;output current board with number header
INVOKE player1move, matrixSize, addr x4Matrix 
INVOKE check3Match, matrixSize, addr x4Matrix;run function to check current board for match
;if a winner is found, stop the game
cmp endGame, 0;if 0 no winner yet, else there is winner
jne theEnd

INVOKE displayBoard, matrixSize, addr x4Matrix ;output current board with number header
INVOKE PCmove2, matrixSize, addr x4Matrix
INVOKE check3Match, matrixSize, addr x4Matrix;run function to check current board for match

pop ecx
;if a winner is found, stop the game
cmp endGame, 0;if 0 no winner yet, else there is winner
jne theEnd

LOOP takeYourTurn1
jmp comparing

takeYourTurn2:;pc goes first 
push ecx
INVOKE displayBoard, matrixSize, addr x4Matrix ;output current board with number header
INVOKE PCmove2, matrixSize, addr x4Matrix
INVOKE check3Match, matrixSize, addr x4Matrix;run function to check current board for match
;if a winner is found, stop the game
cmp endGame, 0;if 0 no winner yet, else there is winner
jne theEnd

INVOKE displayBoard, matrixSize, addr x4Matrix ;output current board with number header
INVOKE player1move, matrixSize, addr x4Matrix
INVOKE check3Match, matrixSize, addr x4Matrix;run function to check current board for match

pop ecx
;if a winner is found, stop the game
cmp endGame, 0;if 0 no winner yet, else there is winner
jne theEnd

LOOP takeYourTurn2

comparing:
cmp ecx, 0;need to see if the ecx gets to 0, would mean no one won
je noWin
jmp theEnd

noWin:
mov edx, offset noWinner
call writestring
jmp theEnd

theEnd:
call waitmsg
mov al, endGame
INVOKE theTotalWins, al;add to Winner count depending on number sent in.
mov endGame, 0 ;reset endGame at end of game

ret
pvcGame ENDP

;----------------------------------------------------------------------
PCmove2 PROC, parm1:byte, parm2:ptr byte
	;Desc: This is allow computer 2 to pick the column they want.
	;	their piece to fall down, depending on column chosen
	;	The switchcase will set off based on their chosen column
	;Recceives: matrixSize, 
	;			addr x4Matrix
	;Returns: esi - x4Matrix
;----------------------------------------------------------------------

.data

PCMove2msg byte 'PC Player 2:Is taking their turn, their color is yellow...', 0ah, 0dh, 0h

PCuserMove2 byte 0h

.code

movzx ecx,parm1;sizeof
mov	esi,parm2;matrix

mov edx, offset PCMove2msg
call writestring

mov eax,4;Set random range 0-3
call RandomRange
add eax, 1;add 1
mov PCuserMove2, al ;set PC movers choice

cmp PCuserMove2, 1
jne opt2
INVOKE dropPiece1, 2, addr x4Matrix;Drop player 2 piece down column 1
jmp theEnd

opt2:;if user choose column 2
cmp PCuserMove2, 2
jne opt3
INVOKE dropPiece2, 2, addr x4Matrix;Drop player 2 piece down column 2
jmp theEnd

opt3:;if user choose column 3
cmp PCuserMove2, 3
jne opt4
INVOKE dropPiece3, 2, addr x4Matrix;Drop player 2 piece down column 3
jmp theEnd 

opt4:;if user choose column 4
cmp PCuserMove2, 4
jne done
INVOKE dropPiece4, 2, addr x4Matrix;drop player 2 piece down column 4
jmp theEnd 

done:;Move out of bounds, skipped
mov edx, OFFSET skiped;tell user mistake made
call WriteString
jmp theEnd

theEnd:
mov eax, 2000;2 seconds
call delay

ret
PCmove2 ENDP

;----------------------------------------------------------------------
PCmove1 PROC, parm1:byte, parm2:ptr byte
	;Desc: This is allow computer 2 to pick the column they want.
	;	their piece to fall down, depending on column chosen
	;	The switchcase will set off based on their chosen column
	;Recceives: matrixSize, 
	;			addr x4Matrix
	;Returns: esi - x4Matrix
;----------------------------------------------------------------------

.data

PCMove1msg byte 'PC Player 1:Is taking their turn, their color is blue...', 0ah, 0dh, 0h

PCuserMove1 byte 0h

.code

movzx ecx,parm1;sizeof
mov	esi,parm2;matrix

mov edx, offset PCMove1msg
call writestring

mov eax,4;Set random range 0-3
call RandomRange
add eax, 1;add 1
mov PCuserMove1, al ;set PC movers choice

cmp PCuserMove1, 1
jne opt2
INVOKE dropPiece1, 1, addr x4Matrix;Drop player 1 piece down column 1
jmp theEnd

opt2:;if user choose column 2
cmp PCuserMove1, 2
jne opt3
INVOKE dropPiece2, 1, addr x4Matrix;Drop player 1 piece down column 2
jmp theEnd

opt3:;if user choose column 3
cmp PCuserMove1, 3
jne opt4
INVOKE dropPiece3, 1, addr x4Matrix;Drop player 1 piece down column 3
jmp theEnd 

opt4:;if user choose column 4
cmp PCuserMove1, 4
jne done
INVOKE dropPiece4, 1, addr x4Matrix;drop player 1 piece down column 4
jmp theEnd 

done:;Move out of bounds, skipped
mov edx, OFFSET skiped;tell user mistake made
call WriteString
jmp theEnd

theEnd:
mov eax, 2000;2 seconds
call delay

ret
PCmove1 ENDP

;----------------------------------------------------------------------
cvcGame PROC, parm1:byte, parm2:ptr byte
	;Desc: This is allow computer versus computer to play.
	;	The player that goes first is choses at random.
	;	Will also call function that checks for winning match 
	;Recceives: matrixSize, 
	;			addr x4Matrix
	;Returns: esi - x4Matrix
;----------------------------------------------------------------------

.code

movzx ecx,parm1;sizeof
mov	esi,parm2;offset Matrix

mov ecx, 8;max number of moves that can be made with 0 matches


mov eax, 2;choose random player with 0 to n-1
call randomrange ;random number 0 or 1

cmp eax,0;based off number will go to correct function for 1st player
je takeYourTurn1;p1first
jmp takeYourTurn2;pcfirst

takeYourTurn1:;player1 goes first 
push ecx
INVOKE displayBoard, matrixSize, addr x4Matrix ;output current board with number header
INVOKE PCmove1, matrixSize, addr x4Matrix
INVOKE check3Match, matrixSize, addr x4Matrix;run function to check current board for match
;if a winner is found, stop the game
cmp endGame, 0;if 0 no winner yet, else there is winner
jne theEnd

INVOKE displayBoard, matrixSize, addr x4Matrix ;output current board with number header
INVOKE PCmove2, matrixSize, addr x4Matrix
INVOKE check3Match, matrixSize, addr x4Matrix;run function to check current board for match

pop ecx
;if a winner is found, stop the game
cmp endGame, 0;if 0 no winner yet, else there is winner
jne theEnd

LOOP takeYourTurn1
jmp comparing

takeYourTurn2:;pc goes first 
push ecx
INVOKE displayBoard, matrixSize, addr x4Matrix ;output current board with number header
INVOKE PCmove2, matrixSize, addr x4Matrix
INVOKE check3Match, matrixSize, addr x4Matrix;run function to check current board for match

;if a winner is found, stop the game
cmp endGame, 0;if 0 no winner yet, else there is winner
jne theEnd

INVOKE displayBoard, matrixSize, addr x4Matrix ;output current board with number header
INVOKE PCmove1, matrixSize, addr x4Matrix
INVOKE check3Match, matrixSize, addr x4Matrix;run function to check current board for match

pop ecx
;if a winner is found, stop the game
cmp endGame, 0;if 0 no winner yet, else there is winner
jne theEnd

LOOP takeYourTurn2

comparing:
cmp ecx, 0;need to see if the ecx gets to 0, would mean no one won
je noWin
jmp theEnd

noWin:
mov edx, offset noWinner
call writestring
jmp theEnd

theEnd:
call waitmsg
mov al, endGame
INVOKE theTotalWins, al;add to Winner count depending on number sent in.
mov endGame, 0 ;reset endGame at end of game

ret
cvcGame ENDP

;--------------------------------------------------
check3Match PROC, parm1:byte, parm2:ptr byte
	;Desc: Check the rows, then the columns, then the diagonal
	;	If the winner if found in the functions that do the work
	;	then help stops current running game.
	;Recceives: matrixSize, 
	;			addr x5Matrix
	;Returns: esi - x5Matrix
;-----------------------------------------------------------------

.data

player1Count byte 0h
player2Count byte 0h

.code

movzx ecx,parm1;sizeof
mov	esi,parm2;offset Matrix

INVOKE rowSearch, matrixSize, addr x4Matrix
;if a winner is found, stop the game, winner player number stored in endGame
cmp endGame, 0;if 0 no winner yet, else there is winner
jne theEnd

INVOKE columnSearch, matrixSize, addr x4Matrix ;invoke column search
;if a winner is found, stop the game, winner player number stored in endGame
cmp endGame, 0;if 0 no winner yet, else there is winner
jne theEnd

INVOKE diagonalRLSearch, matrixSize, addr x4Matrix;invoke diagonal search
;if a winner is found, stop the game, winner player number stored in endGame
cmp endGame, 0;if 0 no winner yet, else there is winner
jne theEnd

INVOKE diagonalLRSearch, matrixSize, addr x4Matrix;invoke other diagonal search
;if a winner is found, stop the game, winner player number stored in endGame
cmp endGame, 0;if 0 no winner yet, else there is winner
jne theEnd

INVOKE miniDiagRL, matrixSize, addr x4Matrix;invoke mini search
;if a winner is found, stop the game, winner player number stored in endGame
cmp endGame, 0;if 0 no winner yet, else there is winner
jne theEnd

INVOKE miniDiagRL2, matrixSize, addr x4Matrix;invoke mini search
;if a winner is found, stop the game, winner player number stored in endGame
cmp endGame, 0;if 0 no winner yet, else there is winner
jne theEnd

INVOKE miniDiagLR, matrixSize, addr x4Matrix;invoke mini search
;if a winner is found, stop the game, winner player number stored in endGame
cmp endGame, 0;if 0 no winner yet, else there is winner
jne theEnd

INVOKE miniDiagLR2, matrixSize, addr x4Matrix;invoke mini search
;if a winner is found, stop the game, winner player number stored in endGame
cmp endGame, 0;if 0 no winner yet, else there is winner
jne theEnd


theEnd:
mov esi, offset placeholder;reset the placeholder after it has been fully checked
mov ecx, 4
L0:;between games
mov al, 0
mov [esi], al ;Move 0 to element of placeholder
inc esi
loop L0


ret
check3Match ENDP

;-----------------------------------------------------------------
rowSearch PROC, parm1:byte, parm2:ptr byte
	;Desc: Traverses through the 2D array/matrix
	;	one row at a time. Will call a function
	;	that will test the letters to see if 2 vowel, 3 const
	;Recceives: matrixSize, 
	;			addr x5Matrix
	;Returns: esi - x5Matrix                                            
;-----------------------------------------------------------------

.data

placeHolder byte 0, 0, 0, 0
endGame byte 0

.code

movzx ecx,parm1;sizeof
mov	esi,parm2;offset Matrix

mov edx, 0;0, start at begining of row 
mov ecx, RowSize ;should be 4, goes through 1 entire row

mov edi, offset placeHolder;start of the placeholder 

Neo:;moving through the Matrix, get one full row into placeholder, then check it
push ecx;save loop counter
mov ebx, RowSize * 0;Row one
add ebx, edx
mov al, [ebx + esi]
mov [edi], al;move value to the placeholder 
inc edx;increases column
inc edi ;go to next in placeholder
pop ecx;get loop counter back
LOOP Neo

INVOKE tallyUp1, addr x4Matrix;test if player 1 has a winner
;if a winner if found, stop the game
cmp endGame, 0;if 0 no winner yet, else there is winner
jne theEnd

INVOKE tallyUp2, addr x4Matrix;test if player 2 has a winner
;if a winner if found, stop the game
cmp endGame, 0;if 0 no winner yet, else there is winner
jne theEnd

;---------------------next row
clearEDX;colum mover reset
mov ecx, RowSize ;should be 5, goes through 1 entire row

mov edi, offset placeHolder;start of the placeholder 

Neo1:;moving through the Matrix, get one full row into placeholder, then check it
push ecx;save loop counter 
mov ebx, RowSize * 1;row two 
add ebx, edx
mov al, [ebx + esi]
mov [edi], al;call test function
inc edx;increases column
inc edi 
pop ecx;move loop counter back
LOOP Neo1

INVOKE tallyUp1, addr x4Matrix;test if player 1 has a winner
;if a winner if found, stop the game
cmp endGame, 0;if 0 no winner yet, else there is winner
jne theEnd

INVOKE tallyUp2, addr x4Matrix;test if player 2 has a winner
;if a winner if found, stop the game
cmp endGame, 0;if 0 no winner yet, else there is winner
jne theEnd

;------------------------next row
clearEDX;colum mover reset
mov ecx, RowSize ;should be 5, goes through 1 entire row

mov edi, offset placeHolder;start of the placeholder 

Neo2:;moving through the Matrix, get one full row into placeholder, then check it
push ecx;save  loop conter 
mov ebx, RowSize * 2;row three 
add ebx, edx
mov al, [ebx + esi]
mov [edi], al
inc edx;increases column
inc edi
pop ecx;move loop counter back
LOOP Neo2

INVOKE tallyUp1, addr x4Matrix;test if player 1 has a winner
;if a winner if found, stop the game
cmp endGame, 0;if 0 no winner yet, else there is winner
jne theEnd

INVOKE tallyUp2, addr x4Matrix;test if player 2 has a winner
;if a winner if found, stop the game
cmp endGame, 0;if 0 no winner yet, else there is winner
jne theEnd

;---------------------------next row
clearEDX;colum mover reset
mov ecx, RowSize ;should be 5, goes through 1 entire row

mov edi, offset placeHolder;start of the placeholder 

Neo3:;moving through the Matrix, get one full row into placeholder, then check it
push ecx;save the loop counter
mov ebx, RowSize * 3;row four
add ebx, edx
mov al, [ebx + esi]
mov [edi], al;call test function 
inc edx;increases column
inc edi
pop ecx;get the loop counter back
LOOP Neo3

INVOKE tallyUp1, addr x4Matrix;test if player 1 has a winner
;if a winner if found, stop the game
cmp endGame, 0;if 0 no winner yet, else there is winner
jne theEnd

INVOKE tallyUp2, addr x4Matrix;test if player 2 has a winner
;if a winner if found, stop the game
cmp endGame, 0;if 0 no winner yet, else there is winner
jne theEnd

clearEDX;column mover reset

theEnd:

ret
rowSearch ENDP

;-----------------------------------------------------------
tallyUp1 PROC, parm1:ptr byte
	;Desc: Once the placeholder had been made, it is
	;	tested against all the possible win combinations for 
	;	player 1
	;Recceives: 
	;			addr x5Matrix
	;Returns: esi - trigger 
;-----------------------------------------------------------------

.data

winning1a byte 01, 01, 01, 02
winning1b byte 01, 01, 01, 00
winning1c byte 00, 01, 01, 01
winning1d byte 02, 01, 01, 01
winning1e byte 01, 01, 01, 01

winPlayer1 byte 'Player 1 is the winner!!!', 0ah, 0dh, 0h

.code

pushad
mov	esi,parm1;offset Matrix,might need later, but didn't end up using yet.

mov esi, offset placeHolder
mov edi, offset winning1a

mov ecx, 4
L1:;Check the elements in the place holder up against the elements in the winning1 combo 
mov al, [esi]
mov dl, [edi]

inc esi;prepare next element
inc edi ;prepare next element

cmp al, dl;compare placeholder with current row/colum
jne startL2;if they donot match up, then move to next winning combo check 

Loop L1

call clrscr
mov edx, offset connect3Banner1;kewl banner output
call writestring
call crlf
mov edx, offset connect3Banner2
call writestring
call crlf

INVOKE displayBoard, matrixSize, addr x4Matrix ;output current board with number header
mov edx, offset winPlayer1;winner found 
call writestring

mov ebx, offset endGame
mov endGame, 1;game set match

jmp theEnd

;---------------------------------
startL2:
mov esi, offset placeHolder
mov edi, offset winning1b
mov ecx, 4
jmp L2

L2:;Check the elements in the place holder up against the elements in the winning1 combo 
mov al, [esi]
mov dl, [edi]

inc esi;prepare next element
inc edi ;prepare next element

cmp al, dl;compare placeholder with current row/colum
jne startL3;if they donot match up, then move to next winning combo check 

Loop L2

call clrscr
mov edx, offset connect3Banner1;kewl banner output
call writestring
call crlf
mov edx, offset connect3Banner2
call writestring
call crlf

INVOKE displayBoard, matrixSize, addr x4Matrix ;output current board with number header
mov edx, offset winPlayer1;winner found 
call writestring

mov ebx, offset endGame
mov endGame, 1;game set match

jmp theEnd

;-------------------------------------
startL3:
mov esi, offset placeHolder
mov edi, offset winning1c
mov ecx, 4
jmp L3

L3:;Check the elements in the place holder up against the elements in the winning1 combo 
mov al, [esi]
mov dl, [edi]

inc esi;prepare next element
inc edi ;prepare next element

cmp al, dl;compare placeholder with current row/colum
jne startL4;if they donot match up, then move to next winning combo check 

Loop L3

call clrscr
mov edx, offset connect3Banner1;kewl banner output
call writestring
call crlf
mov edx, offset connect3Banner2
call writestring
call crlf

INVOKE displayBoard, matrixSize, addr x4Matrix ;output current board with number header
mov edx, offset winPlayer1;winner found 
call writestring

mov ebx, offset endGame
mov endGame, 1;game set match

jmp theEnd
;-------------------------------------
startL4:
mov esi, offset placeHolder
mov edi, offset winning1e
mov ecx, 4
jmp L4

L4:;Check the elements in the place holder up against the elements in the winning1 combo 
mov al, [esi]
mov dl, [edi]

inc esi;prepare next element
inc edi ;prepare next element

cmp al, dl;compare placeholder with current row/colum
jne startL5;if they donot match up, then move to next winning combo check 

Loop L4

call clrscr
INVOKE displayBoard, matrixSize, addr x4Matrix ;output current board with number header
mov edx, offset winPlayer1;winner found 
call writestring

mov ebx, offset endGame
mov endGame, 1;game set match

jmp theEnd

;---------------------------------------
startL5:
mov esi, offset placeHolder
mov edi, offset winning1d
mov ecx, 4
jmp L5

L5:;Check the elements in the place holder up against the elements in the winning1 combo 
mov al, [esi]
mov dl, [edi]

inc esi;prepare next element
inc edi ;prepare next element

cmp al, dl;compare placeholder with current row/colum
jne theEnd;if they donot match up, then move to next winning combo check 
Loop L5

call clrscr
mov edx, offset connect3Banner1;kewl banner ouput
call writestring
call crlf
mov edx, offset connect3Banner2
call writestring
call crlf

INVOKE displayBoard, matrixSize, addr x4Matrix ;output current board with number header
mov edx, offset winPlayer1;winner found 
call writestring

mov ebx, offset endGame
mov endGame, 1;game set match

jmp theEnd

theEnd:

popad

ret
tallyUp1 ENDP

;-----------------------------------------------------------
tallyUp2 PROC, parm1:ptr byte
	;Desc: Once the placeholder had been made, it is
	;	tested against all the possible win combinations for 
	;	player 2
	;Recceives: matrixSize, 
	;			addr x5Matrix
	;Returns: esi - x5Matrix
;-----------------------------------------------------------------

.data

winning2a byte 02, 02, 02, 01
winning2b byte 02, 02, 02, 00
winning2c byte 00, 02, 02, 02
winning2d byte 01, 02, 02, 02
winning2e byte 02, 02, 02, 02

winPlayer2 byte 'Player 2 is the winner!!!', 0ah, 0dh, 0h

.code

pushad;save all registers 
mov	esi,parm1;offset Matrix,may need later, but didn't end up using.

mov esi, offset placeHolder
mov edi, offset winning2a

mov ecx, 4
L1:;Check the elements in the place holder up against the elements in the winning1 combo 
mov al, [esi]
mov dl, [edi]

inc esi;prepare next element
inc edi ;prepare next element

cmp al, dl;compare placeholder with current row/colum
jne startL2;if they donot match up, then move to next winning combo check 

Loop L1

call clrscr
mov edx, offset connect3Banner1;kewl banner output
call writestring
call crlf
mov edx, offset connect3Banner2
call writestring
call crlf

INVOKE displayBoard, matrixSize, addr x4Matrix ;output current board with number header
mov edx, offset winPlayer2;winner found 
call writestring

mov ebx, offset endGame
mov endGame, 2;game set match

jmp theEnd

;---------------------------------
startL2:
mov esi, offset placeHolder
mov edi, offset winning2b
mov ecx, 4
jmp L2

L2:;Check the elements in the place holder up against the elements in the winning1 combo 
mov al, [esi]
mov dl, [edi]

inc esi;prepare next element
inc edi ;prepare next element

cmp al, dl;compare placeholder with current row/colum
jne startL3;if they donot match up, then move to next winning combo check 

Loop L2

call clrscr
mov edx, offset connect3Banner1;kewl banner output
call writestring
call crlf
mov edx, offset connect3Banner2
call writestring
call crlf

INVOKE displayBoard, matrixSize, addr x4Matrix ;output current board with number header
mov edx, offset winPlayer2;winner found 
call writestring

mov ebx, offset endGame
mov endGame, 2;game set match

jmp theEnd

;-------------------------------------
startL3:
mov esi, offset placeHolder
mov edi, offset winning2c
mov ecx, 4
jmp L3

L3:;Check the elements in the place holder up against the elements in the winning1 combo 
mov al, [esi]
mov dl, [edi]

inc esi;prepare next element
inc edi ;prepare next element

cmp al, dl;compare placeholder with current row/colum
jne startL4;if they donot match up, then move to next winning combo check 

Loop L3

call clrscr
mov edx, offset connect3Banner1;kewl banner output
call writestring
call crlf
mov edx, offset connect3Banner2
call writestring
call crlf

INVOKE displayBoard, matrixSize, addr x4Matrix ;output current board with number header
mov edx, offset winPlayer2;winner found 
call writestring

mov ebx, offset endGame
mov endGame, 2;game set match

jmp theEnd

;-------------------------------------
startL4:
mov esi, offset placeHolder
mov edi, offset winning2e
mov ecx, 4
jmp L4

L4:;Check the elements in the place holder up against the elements in the winning1 combo 
mov al, [esi]
mov dl, [edi]

inc esi;prepare next element
inc edi ;prepare next element

cmp al, dl;compare placeholder with current row/colum
jne startL5;if they donot match up, then move to next winning combo check 

Loop L4

call clrscr
mov edx, offset connect3Banner1;kewl banner output
call writestring
call crlf
mov edx, offset connect3Banner2
call writestring
call crlf

INVOKE displayBoard, matrixSize, addr x4Matrix ;output current board with number header
mov edx, offset winPlayer2;winner found 
call writestring

mov ebx, offset endGame
mov endGame, 2;game set match

jmp theEnd

;---------------------------------------
startL5:
mov esi, offset placeHolder
mov edi, offset winning2d
mov ecx, 4
jmp L5

L5:;Check the elements in the place holder up against the elements in the winning1 combo 
mov al, [esi]
mov dl, [edi]

inc esi;prepare next element
inc edi ;prepare next element 

cmp al, dl;compare placeholder with current row/colum
jne theEnd;if they donot match up, then move to next winning combo check 
Loop L5

call clrscr
mov edx, offset connect3Banner1;kewl banner output
call writestring
call crlf
mov edx, offset connect3Banner2
call writestring
call crlf

INVOKE displayBoard, matrixSize, addr x4Matrix ;output current board with number header
mov edx, offset winPlayer2;winner found 
call writestring

mov ebx, offset endGame
mov endGame, 2;game set match

jmp theEnd

theEnd:

popad;get all registers back

ret
tallyUp2 ENDP

;-------------------------------------------
theTotalWins PROC, parm1:byte
	;Desc: After a player has won or lost tied,
	;	this function will be called and will tally
	;	up what has happened. Used for end of game total output
	;Recceives: endGame
	;	
	;Returns: endGame
;------------------------------------------

.data

player2HasWon byte 0
player1HasWon byte 0 
noOneHasOne byte 0
totalGamesPlayed byte 0

.code
movzx eax, parm1;set the input

cmp al, 0
jne player1Won
add noOneHasOne, 1;add to the no one won count
jmp theEnd
	
player1Won:
cmp al, 1
jne player2Won
add player1HasWon, 1;player 1 won
jmp theEnd

player2Won:
add player2HasWon, 1;player 2 count
jmp theEnd

theEnd:
add totalGamesPlayed, 1;total games

ret
theTotalWins ENDP

;-------------------------------------------
winOutput PROC, parm1:byte, parm2:ptr byte
	;Desc: Will output the final wins and losses total
	;	this function will be called when the player wants to finish 
	;	playing this awesome game. 
	;Recceives: endGame
	;	
	;Returns: endGame
;------------------------------------------

.data

totalHeader1 byte 'Total Games Played: ', 0h
totalHeader2 byte 'Player 1 Total Win: ', 0h
totalHeader3 byte 'Player 2 Total Win: ', 0h
totalHeader4 byte 'Total Tied Games:   ', 0h

.code
movzx ecx,parm1;sizeof
mov	esi,parm2;offset Matrix

call clrscr;clearscreen

mov edx, offset connect3Banner1;kewl banner output
call writestring
call crlf
mov edx, offset connect3Banner2
call writestring
call crlf

mov edx, offset totalHeader1
call writestring
movzx eax, totalGamesPlayed 
call writedec ;output win
call crlf;next line

mov edx, offset totalHeader2
call writestring
movzx eax, player1HasWon ;player1HasWon
call writedec ;output win
call crlf;next line

mov edx, offset totalHeader3
call writestring
movzx eax, player2HasWon ;player2HasWon
call writedec ;output win
call crlf;next line

mov edx, offset totalHeader4
call writestring
movzx eax, noOneHasOne ;noOneHasWon
call writedec ;output win
call crlf;next line

ret
winOutput ENDP

;-----------------------------------------------------------------
columnSearch PROC, parm1:byte, parm2:ptr byte
	;Desc: Traverses through the 2D array/matrix
	;	go through each collum of the matrix one by one	
	;	Sends the letter into the test to see if 2 vowel ad 3 const
	;Recceives: matrixSize, 
	;			addr x5Matrix
	;Returns: esi - x5Matrix
;-----------------------------------------------------------------

.code

movzx ecx,parm1;sizeof
mov	ebx,parm2;offset Matrix

clearEDX

mov eax, 0;row number
mov ecx, RowSize
	
mul	ecx		; row index * row size
add	ebx,eax		; row offset 
mov	eax,0		; accumulator
mov	esi,0		; column index

mov edi, offset placeHolder;start of the placeholder 
mov	ecx,RowSize;set loop counter 

L1:	
push ecx;save loop conter 
movzx edx, BYTE PTR[ebx + esi]; get a byte
mov [edi], dl;move value to the placeholder 


add esi, RowSize; add to accumulator 
inc edi 
pop ecx	;retrieve the loop counter 
loop	L1; next byte in row

INVOKE tallyUp1, addr x4Matrix;test if player 1 has a winner
;if a winner if found, stop the game
cmp endGame, 0;if 0 no winner yet, else there is winner
jne theEnd

INVOKE tallyUp2, addr x4Matrix;test if player 2 has a winner
;if a winner if found, stop the game
cmp endGame, 0;if 0 no winner yet, else there is winner
jne theEnd

;-----------------------------------
mov eax, 0;row number
mov ecx, RowSize
	
mul	ecx		; row index * row size
add	ebx,eax		; row offset 
mov	eax,0		; accumulator
mov	esi,1		; column index

mov edi, offset placeHolder;start of the placeholder 
mov	ecx,RowSize;set loop counter 

L2:	
push ecx;save loop conter 
movzx edx, BYTE PTR[ebx + esi]; get a byte
mov [edi], dl;move value to the placeholder 


add esi, RowSize; add to accumulator 
inc edi 
pop ecx	;retrieve the loop counter 
loop	L2; next byte in row

INVOKE tallyUp1, addr x4Matrix;test if player 1 has a winner
;if a winner if found, stop the game
cmp endGame, 0;if 0 no winner yet, else there is winner
jne theEnd

INVOKE tallyUp2, addr x4Matrix;test if player 2 has a winner
;if a winner if found, stop the game
cmp endGame, 0;if 0 no winner yet, else there is winner
jne theEnd

;------------------------------------------------------

mov eax, 0;row number
mov ecx, RowSize
	
mul	ecx		; row index * row size
add	ebx,eax		; row offset 
mov	eax,0		; accumulator
mov	esi,2		; column index

mov edi, offset placeHolder;start of the placeholder 
mov	ecx,RowSize;set loop counter 

L3:	
push ecx;save loop conter 
movzx edx, BYTE PTR[ebx + esi]; get a byte
mov [edi], dl;move value to the placeholder 


add esi, RowSize; add to accumulator 
inc edi 
pop ecx	;retrieve the loop counter 
loop	L3; next byte in row

INVOKE tallyUp1, addr x4Matrix;test if player 1 has a winner
;if a winner if found, stop the game
cmp endGame, 0;if 0 no winner yet, else there is winner
jne theEnd

INVOKE tallyUp2, addr x4Matrix;test if player 2 has a winner
;if a winner if found, stop the game
cmp endGame, 0;if 0 no winner yet, else there is winner
jne theEnd
;--------------------------------

mov eax, 0;row number
mov ecx, RowSize
	
mul	ecx		; row index * row size
add	ebx,eax		; row offset 
mov	eax,0		; accumulator
mov	esi,3		; column index

mov edi, offset placeHolder;start of the placeholder 
mov	ecx,RowSize;set loop counter 

L4:	
push ecx;save loop conter 
movzx edx, BYTE PTR[ebx + esi]; get a byte
mov [edi], dl;move value to the placeholder 

add esi, RowSize; add to accumulator 
inc edi 
pop ecx	;retrieve the loop counter 
loop	L4; next byte in row

INVOKE tallyUp1, addr x4Matrix;test if player 1 has a winner
;if a winner if found, stop the game
cmp endGame, 0;if 0 no winner yet, else there is winner
jne theEnd

INVOKE tallyUp2, addr x4Matrix;test if player 2 has a winner
;if a winner if found, stop the game
cmp endGame, 0;if 0 no winner yet, else there is winner
jne theEnd

theEnd:
ret
columnSearch ENDP

;-----------------------------------------------------------------
diagonalRLSearch PROC, parm1:byte, parm2:ptr byte
	;Desc: Traverses through the 2D array/matrix
	;	Start at top left and goes diagonaly to the bottom right	
	;	At each correct letter, the letter is tested for set
	;Recceives: matrixSize, 
	;			addr x5Matrix
	;Returns: esi - x5Matrix
;-----------------------------------------------------------------

movzx ecx,parm1;sizeof
mov	ebx,parm2;offset Matrix

mov edi, offset placeHolder;start of the placeholder 
clearEDX

row_index0 = 0;Move to R:0
column_index0 = 0;Move to C:0

mov ebx,OFFSET x4Matrix; table offset
add ebx,RowSize * row_index0 ; row offset
mov esi,column_index0
mov al, [ebx + esi]
mov [edi], al;move value to the placeholder 

;------------------------------------------------

row_index1 = 1;Move to R:1
column_index1 = 1;Move to C:1
inc edi

mov ebx,OFFSET x4Matrix ; table offset
add ebx,RowSize * row_index1 ; row offset
mov esi,column_index1
mov al, [ebx + esi]
mov [edi], al;move value to the placeholder 

;--------------------------------

row_index2 = 2;Move to R:2
column_index2 = 2;Move to c:2
inc edi

mov ebx,OFFSET x4Matrix ; table offset
add ebx,RowSize * row_index2 ; row offset
mov esi,column_index2
mov al, [ebx + esi]
mov [edi], al;move value to the placeholder 

;----------------------------------------------------

row_index3 = 3;Move to R:3
column_index3 = 3;Move to C:3
inc edi

mov ebx,OFFSET x4Matrix ; table offset
add ebx,RowSize * row_index3 ; row offset
mov esi,column_index3
mov al, [ebx + esi]
mov [edi], al;move value to the placeholder 

;---------------------------------------

INVOKE tallyUp1, addr x4Matrix;test if player 1 has a winner
;if a winner if found, stop the game
cmp endGame, 0;if 0 no winner yet, else there is winner
jne theEnd

INVOKE tallyUp2, addr x4Matrix;test if player 2 has a winner
;if a winner if found, stop the game
cmp endGame, 0;if 0 no winner yet, else there is winner
jne theEnd

theEnd:

ret
diagonalRLSearch ENDP

;-----------------------------------------------------------------
diagonalLRSearch PROC, parm1:byte, parm2:ptr byte
	;Desc: Traverses through the 2D array/matrix
	;	Start at top left and goes diagonaly to the bottom right	
	;	At each correct letter, the letter is tested for set
	;Recceives: matrixSize, 
	;			addr x5Matrix
	;Returns: esi - x5Matrix
;-----------------------------------------------------------------

movzx ecx,parm1;sizeof
mov	ebx,parm2;offset Matrix

mov edi, offset placeHolder;start of the placeholder 
clearEDX

row_index0a = 3;Move to R:3
column_index0a = 0;Move to C:0

mov ebx,OFFSET x4Matrix; table offset
add ebx,RowSize * row_index0a ; row offset
mov esi,column_index0a
mov al, [ebx + esi]
mov [edi], al;move value to the placeholder 

;------------------------------------------------

row_index1a = 2;Move to R:2
column_index1a = 1;Move to C:1
inc edi

mov ebx,OFFSET x4Matrix ; table offset
add ebx,RowSize * row_index1a ; row offset
mov esi,column_index1a
mov al, [ebx + esi]
mov [edi], al;move value to the placeholder 

;--------------------------------

row_index2a = 1;Move to R:1
column_index2a = 2;Move to c:2
inc edi

mov ebx,OFFSET x4Matrix ; table offset
add ebx,RowSize * row_index2a ; row offset
mov esi,column_index2a
mov al, [ebx + esi]
mov [edi], al;move value to the placeholder 

;----------------------------------------------------

row_index3a = 0;Move to R:0
column_index3a = 3;Move to C:3
inc edi

mov ebx,OFFSET x4Matrix ; table offset
add ebx,RowSize * row_index3a ; row offset
mov esi,column_index3a
mov al, [ebx + esi]
mov [edi], al;move value to the placeholder 

;---------------------------------------

INVOKE tallyUp1, addr x4Matrix;test if player 1 has a winner
;if a winner if found, stop the game
cmp endGame, 0;if 0 no winner yet, else there is winner
jne theEnd

INVOKE tallyUp2, addr x4Matrix;test if player 2 has a winner
;if a winner if found, stop the game
cmp endGame, 0;if 0 no winner yet, else there is winner
jne theEnd

theEnd:

ret
diagonalLRSearch ENDP

;------------------------------------------
miniDiagRL PROC, parm1:byte, parm2:ptr byte
	;Desc: Will check for a small area of diagonal
	;	this function will put info into placeholder
	;	if a winner will found will set trigger to compelte turn
	;Recceives: matrixSize, 
	;			addr x5Matrix
	;Returns: esi - x5Matrix
;------------------------------------------

.data

miniDiag1 byte 1, 1, 1
miniplaceHolder byte 0,0,0

.code

movzx ecx,parm1;sizeof
mov	esi,parm2;offset Matrix

mov edi, offset miniplaceHolder

row_indexmini = 2;Move to R:2
column_indexmini = 0;Move to C:0

mov ebx,OFFSET x4Matrix ; table offset
add ebx,RowSize * row_indexmini ; row offset
mov esi,column_indexmini
mov al, [ebx + esi]
mov [edi], al;move value to the placeholder 
inc edi;next element

;---------------------------------------

row_indexmini1 = 1;Move to R:1
column_indexmini1 = 1;Move to C:1

mov ebx,OFFSET x4Matrix ; table offset
add ebx,RowSize * row_indexmini1 ; row offset
mov esi,column_indexmini1
mov al, [ebx + esi]
mov [edi], al;move value to the placeholder 
inc edi;next element

;---------------------------------------

row_indexmini2 = 0;Move to R:3
column_indexmini2 = 2;Move to CL3

mov ebx,OFFSET x4Matrix ; table offset
add ebx,RowSize * row_indexmini2 ; row offset
mov esi,column_indexmini2
mov al, [ebx + esi]
mov [edi], al;move value to the placeholder 

;---------------------------------------

;get everything and now compare it
mov edi, offset miniplaceHolder
mov esi, offset miniDiag1 
mov ecx, 3

L1:;compare the mini
mov bl, [esi] 
mov al, [edi]
cmp al, bl;compare the placeholder with the match
jne theNext
inc esi;next element
inc edi;next element
loop L1

call clrscr
mov edx, offset connect3Banner1;kewl banner ouput
call writestring
call crlf
mov edx, offset connect3Banner2
call writestring
call crlf

INVOKE displayBoard, matrixSize, addr x4Matrix ;output current board with number header
mov edx, offset winPlayer1;winner found 
call writestring

mov ebx, offset endGame
mov endGame, 1;game set match

jmp theEnd
;---------------------------------------------------------------------------
theNext:
mov edi, offset miniplaceHolder

row_indexmini3 = 3;Move to R:3
column_indexmini3 = 1;Move to C:1

mov ebx,OFFSET x4Matrix ; table offset
add ebx,RowSize * row_indexmini3 ; row offset
mov esi,column_indexmini3
mov al, [ebx + esi]
mov [edi], al;move value to the placeholder 
inc edi;next element

;---------------------------------------

row_indexmini4 = 2;Move to R:2
column_indexmini4 = 2;Move to C:2

mov ebx,OFFSET x4Matrix ; table offset
add ebx,RowSize * row_indexmini4 ; row offset
mov esi,column_indexmini4
mov al, [ebx + esi]
mov [edi], al;move value to the placeholder 
inc edi;next element

;---------------------------------------

row_indexmini5 = 1;Move to R:1
column_indexmini5 = 3;Move to C:3

mov ebx,OFFSET x4Matrix ; table offset
add ebx,RowSize * row_indexmini5 ; row offset
mov esi,column_indexmini5
mov al, [ebx + esi]
mov [edi], al;move value to the placeholder 

;---------------------------------------

;get everything and now compare it
mov edi, offset miniplaceHolder
mov esi, offset miniDiag1 
mov ecx, 3

L2:;compare the mini
mov bl, [esi] 
mov al, [edi]
cmp al, bl;compare the placeholder with the match
jne theEnd
inc esi;next element
inc edi;next element
loop L2

call clrscr
mov edx, offset connect3Banner1;kewl banner ouput
call writestring
call crlf
mov edx, offset connect3Banner2
call writestring
call crlf

INVOKE displayBoard, matrixSize, addr x4Matrix ;output current board with number header
mov edx, offset winPlayer1;winner found 
call writestring

mov ebx, offset endGame
mov endGame, 1;game set match

jmp theEnd

theEnd:

ret
miniDiagRL ENDP


;------------------------------------------
miniDiagRL2 PROC, parm1:byte, parm2:ptr byte
	;Desc: Will check for a small area of diagonal
	;	this function will put info into placeholder
	;	if a winner will found will set trigger to compelte turn
	;Recceives: matrixSize, 
	;			addr x5Matrix
	;Returns: esi - x5Matrix
;------------------------------------------

.data

miniDiag2 byte 2, 2, 2

.code

movzx ecx, parm1 ;sizeof
mov	esi, parm2 ;offset Matrix

mov edi, offset miniplaceHolder

row_indexmini6 = 2;Move to R:2
column_indexmini6 = 0;Move to C:0

mov ebx,OFFSET x4Matrix ; table offset
add ebx,RowSize * row_indexmini6 ; row offset
mov esi,column_indexmini6
mov al, [ebx + esi]
mov [edi], al;move value to the placeholder 
inc edi;next

;---------------------------------------

row_indexmini7 = 1;Move to R:1
column_indexmini7 = 1;Move to C:1

mov ebx,OFFSET x4Matrix ; table offset
add ebx,RowSize * row_indexmini7 ; row offset
mov esi,column_indexmini7
mov al, [ebx + esi]
mov [edi], al;move value to the placeholder 
inc edi;next

;---------------------------------------

row_indexmini8 = 0;Move to R:0
column_indexmini8 = 2;Move to C:2

mov ebx,OFFSET x4Matrix ; table offset
add ebx,RowSize * row_indexmini8 ; row offset
mov esi,column_indexmini8
mov al, [ebx + esi]
mov [edi], al;move value to the placeholder 

;---------------------------------------

;get everything and compare it

mov edi, offset miniplaceHolder
mov esi, offset miniDiag2
mov ecx, 3

L1:;compare the mini
mov bl, [esi] 
mov al, [edi]
cmp al, bl;compare the placeholder with match
jne theNext
inc esi;next element
inc edi;next element
loop L1

call clrscr
mov edx, offset connect3Banner1;kewl banner ouput
call writestring
call crlf
mov edx, offset connect3Banner2
call writestring
call crlf

INVOKE displayBoard, matrixSize, addr x4Matrix ;output current board with number header
mov edx, offset winPlayer2;winner found 
call writestring

mov ebx, offset endGame
mov endGame, 2;game set match

jmp theEnd
;---------------------------------------------------------------------------
theNext:
mov edi, offset miniplaceHolder

row_indexmini9 = 3;Move to R:3
column_indexmini9 = 1;Move to C:1

mov ebx,OFFSET x4Matrix ; table offset
add ebx,RowSize * row_indexmini9 ; row offset
mov esi,column_indexmini9
mov al, [ebx + esi]
mov [edi], al;move value to the placeholder 
inc edi;next

;---------------------------------------

row_indexmini10 = 2;Move to R:2
column_indexmini10 = 2;Move to C:2

mov ebx,OFFSET x4Matrix ; table offset
add ebx,RowSize * row_indexmini10 ; row offset
mov esi,column_indexmini10
mov al, [ebx + esi]
mov [edi], al;move value to the placeholder 
inc edi;next element

;---------------------------------------

row_indexmini11 = 1;Move to R:1
column_indexmini11 = 3;Move to C:3

mov ebx,OFFSET x4Matrix ; table offset
add ebx,RowSize * row_indexmini11 ; row offset
mov esi,column_indexmini11
mov al, [ebx + esi]
mov [edi], al;move value to the placeholder 

;---------------------------------------

;get everything and now compare it
mov edi, offset miniplaceHolder
mov esi, offset miniDiag2
mov ecx, 3

L2:;compare the mini
mov bl, [esi] 
mov al, [edi]
cmp al, bl;compare the placeholder with the correct
jne theEnd
inc esi;next element
inc edi;next element
loop L2

call clrscr
mov edx, offset connect3Banner1;kewl banner ouput
call writestring
call crlf
mov edx, offset connect3Banner2
call writestring
call crlf

INVOKE displayBoard, matrixSize, addr x4Matrix ;output current board with number header
mov edx, offset winPlayer2;winner found 
call writestring

mov ebx, offset endGame
mov endGame, 2;game set match

jmp theEnd

theEnd:

ret
miniDiagRL2 ENDP

;------------------------------------------
miniDiagLR PROC, parm1:byte, parm2:ptr byte
	;Desc: Will check for a small area of diagonal
	;	this function will put info into placeholder
	;	if a winner will found will set trigger to compelte turn
	;Recceives: matrixSize, 
	;			addr x5Matrix
	;Returns: esi - x5Matrix
;------------------------------------------

movzx ecx,parm1;sizeof
mov	esi,parm2;offset Matrix

mov edi, offset miniplaceHolder

row_Imini = 1;Move to R:1
column_Imini = 0;Move to C:0

mov ebx,OFFSET x4Matrix ; table offset
add ebx,RowSize * row_Imini ; row offset
mov esi,column_Imini
mov al, [ebx + esi]
mov [edi], al;move value to the placeholder 
inc edi;next

;---------------------------------------

row_Imini1 = 2;Move to R:2
column_Imini1 = 1;Move to C:1

mov ebx,OFFSET x4Matrix ; table offset
add ebx,RowSize * row_Imini1 ; row offset
mov esi,column_Imini1
mov al, [ebx + esi]
mov [edi], al;move value to the placeholder 
inc edi;next

;---------------------------------------

row_Imini2 = 3;Move to R:3
column_Imini2 = 2;Move to C:2

mov ebx,OFFSET x4Matrix ; table offset
add ebx,RowSize * row_Imini2 ; row offset
mov esi,column_Imini2
mov al, [ebx + esi]
mov [edi], al;move value to the placeholder 

;---------------------------------------

;get everything, now compare it
mov edi, offset miniplaceHolder
mov esi, offset miniDiag1 
mov ecx, 3

L1:;compare the mini
mov bl, [esi] 
mov al, [edi]
cmp al, bl;compare the placeholder to the correct match
jne theNext
inc esi;next element
inc edi;next element
loop L1

call clrscr
mov edx, offset connect3Banner1;kewl banner ouput
call writestring
call crlf
mov edx, offset connect3Banner2
call writestring
call crlf

INVOKE displayBoard, matrixSize, addr x4Matrix ;output current board with number header
mov edx, offset winPlayer1;winner found 
call writestring

mov ebx, offset endGame
mov endGame, 1;game set match

jmp theEnd
;---------------------------------------------------------------------------
theNext:
mov edi, offset miniplaceHolder

row_Imini3 = 0;Move to R:0
column_Imini3 = 1;Move to C:1

mov ebx,OFFSET x4Matrix ; table offset
add ebx,RowSize * row_Imini3 ; row offset
mov esi,column_Imini3
mov al, [ebx + esi]
mov [edi], al;move value to the placeholder 
inc edi;next

;---------------------------------------

row_Imini4 = 1;Move to R:1
column_Imini4 = 2;Move to C:2

mov ebx,OFFSET x4Matrix ; table offset
add ebx,RowSize * row_Imini4 ; row offset
mov esi,column_Imini4
mov al, [ebx + esi]
mov [edi], al;move value to the placeholder 
inc edi;next

;---------------------------------------

row_Imini5 = 2;Move to R:2
column_Imini5 = 3;Move to C:3

mov ebx,OFFSET x4Matrix ; table offset
add ebx,RowSize * row_Imini5 ; row offset
mov esi,column_Imini5
mov al, [ebx + esi]
mov [edi], al;move value to the placeholder 

;---------------------------------------

;get everything, now compare it
mov edi, offset miniplaceHolder
mov esi, offset miniDiag1 
mov ecx, 3

L2:;compare the mini
mov bl, [esi] 
mov al, [edi]
cmp al, bl;compare the placeholder to the correct match
jne theEnd
inc esi;next lement
inc edi;next element
loop L2

call clrscr
mov edx, offset connect3Banner1;kewl banner ouput
call writestring
call crlf
mov edx, offset connect3Banner2
call writestring
call crlf

INVOKE displayBoard, matrixSize, addr x4Matrix ;output current board with number header
mov edx, offset winPlayer1;winner found 
call writestring

mov ebx, offset endGame
mov endGame, 1;game set match

jmp theEnd

theEnd:

ret
miniDiagLR ENDP

;------------------------------------------
miniDiagLR2 PROC, parm1:byte, parm2:ptr byte
	;Desc: Will check for a small area of diagonal
	;	this function will put info into placeholder
	;	if a winner will found will set trigger to compelte turn
	;Recceives: matrixSize, 
	;			addr x5Matrix
	;Returns: esi - x5Matrix
;------------------------------------------

movzx ecx, parm1 ;sizeof
mov	esi, parm2 ;offset Matrix

mov edi, offset miniplaceHolder

row_Imini6 = 1;Move to R:1
column_Imini6 = 0;Move to C:0

mov ebx,OFFSET x4Matrix ; table offset
add ebx,RowSize * row_Imini6 ; row offset
mov esi,column_Imini6
mov al, [ebx + esi]
mov [edi], al;move value to the placeholder 
inc edi;next

;---------------------------------------

row_Imini7 = 2;Move to R:2
column_Imini7 = 1;Move to C:1

mov ebx,OFFSET x4Matrix ; table offset
add ebx,RowSize * row_Imini7 ; row offset
mov esi,column_Imini7
mov al, [ebx + esi]
mov [edi], al;move value to the placeholder 
inc edi;next

;---------------------------------------

row_Imini8 = 3;Move to R:3
column_Imini8 = 2;Move to C:2

mov ebx,OFFSET x4Matrix ; table offset
add ebx,RowSize * row_Imini8 ; row offset
mov esi,column_Imini8
mov al, [ebx + esi]
mov [edi], al;move value to the placeholder 

;---------------------------------------

;get everything, now compare it
mov edi, offset miniplaceHolder
mov esi, offset miniDiag2
mov ecx, 3

L1:;compare the mini
mov bl, [esi] 
mov al, [edi]
cmp al, bl;compare the placeholder to the correct match
jne theNext
inc esi;next element
inc edi;next element
loop L1

call clrscr
mov edx, offset connect3Banner1;kewl banner ouput
call writestring
call crlf
mov edx, offset connect3Banner2
call writestring
call crlf

INVOKE displayBoard, matrixSize, addr x4Matrix ;output current board with number header
mov edx, offset winPlayer2;winner found 
call writestring

mov ebx, offset endGame
mov endGame, 2;game set match

jmp theEnd
;---------------------------------------------------------------------------
theNext:
mov edi, offset miniplaceHolder

row_Imini9 = 0;Move to R:3
column_Imini9 = 1;Move to CL3

mov ebx,OFFSET x4Matrix ; table offset
add ebx,RowSize * row_Imini9 ; row offset
mov esi,column_Imini9
mov al, [ebx + esi]
mov [edi], al;move value to the placeholder 
inc edi;next

;---------------------------------------

row_Imini10 = 1;Move to R:1
column_Imini10 = 2;Move to C:2

mov ebx,OFFSET x4Matrix ; table offset
add ebx,RowSize * row_Imini10 ; row offset
mov esi,column_Imini10
mov al, [ebx + esi]
mov [edi], al;move value to the placeholder 
inc edi;next

;---------------------------------------

row_Imini11 = 2;Move to R:2
column_Imini11 = 3;Move to C:3

mov ebx,OFFSET x4Matrix ; table offset
add ebx,RowSize * row_Imini11 ; row offset
mov esi,column_Imini11
mov al, [ebx + esi]
mov [edi], al;move value to the placeholder 

;---------------------------------------

;got everything, now compare it
mov edi, offset miniplaceHolder
mov esi, offset miniDiag2
mov ecx, 3

L2:;compare the mini
mov bl, [esi] 
mov al, [edi]
cmp al, bl;compare the placeholder to the correct match
jne theEnd
inc esi;next element
inc edi;next element
loop L2

call clrscr
mov edx, offset connect3Banner1;kewl banner ouput
call writestring
call crlf
mov edx, offset connect3Banner2
call writestring
call crlf

INVOKE displayBoard, matrixSize, addr x4Matrix ;output current board with number header
mov edx, offset winPlayer2;winner found 
call writestring

mov ebx, offset endGame
mov endGame, 2;game set match

jmp theEnd

theEnd:

ret
miniDiagLR2 ENDP

END main