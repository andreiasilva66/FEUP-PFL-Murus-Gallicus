:- use_module(library(lists)).


initial_state([['X','X','X','X','X','X','X','X'],
            [' ',' ',' ',' ',' ',' ',' ',' '],
            [' ',' ',' ',' ',' ',' ',' ',' '],
            [' ',' ',' ',' ',' ',' ',' ',' '],
            [' ',' ',' ',' ',' ',' ',' ',' '],
            [' ',' ',' ',' ',' ',' ',' ',' '],
            ['O','O','O','O','O','O','O','O']
            ]).

drawLine([]) :- !.

drawLine([E1|E2]) :- print(E1), write(' | '),
                        drawLine(E2).

drawLine([E1|E2], N) :- write(N), write(' | '), write(E1), write(' | '),
                        drawLine(E2).

continueDisplayBoard([],_) :- !.

continueDisplayBoard([L1|L2], N) :- 
                        nl, drawLine(L1,N), nl,
                        write('   - - - - - - - - - - - - - - - - '),
                        N1 is N+1,
                       continueDisplayBoard(L2, N1).

display_game(GameState) :- write('\n   - - - - - - - - - - - - - - - - \n'),
                        write('  | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 |\n'),    
                        write('   - - - - - - - - - - - - - - - - '),
                        continueDisplayBoard(GameState, 1).

replace([H|T], 0, X, [X|T]) :- !.
replace([H|T], I, X, [H|R]) :- 
                    NI is I-1,
                    replace(T, NI, X, R).

placePiece(Board, Piece, X, Y, NewBoard) :- 
                        Y1 is Y-1,
                        X1 is X-1,
                        nth0(Y1, Board, Line),
                        replace(Line, X1, Piece, NewLine),
                        replace(Board, Y1, NewLine, NewBoard).


removePiece(Board, X, Y, NewBoard) :- 
                        Y1 is Y-1,
                        X1 is X-1,
                        nth0(Y1, Board, Line),
                        replace(Line, X1, ' ', NewLine),
                        replace(Board, Y1, NewLine, NewBoard).

/*
letter_to_index(Letter, Index) :-
    char_code(Letter, Code),
    Index is Code - 65.
*/
check_initial_tile(Board, Player, X, Y) :-
    nth0(Y, Board, Row),
    nth0(X, Row, Piece),
    (Player = 1, Piece = 'X') ;
    (Player = 2, Piece = 'O').


check_final_tile(Board, Player, X2, Y2) :-
    nth0(Y2, Board, Row),            
    nth0(X2, Row, Cell),               

    (Cell = ' ' -> true;
    Cell = 'X', Player = 1 -> true;
    Cell = 'O', Player = 2 -> true;
    true -> false).

getPiece(Board, X, Y, Piece):-
    nth1(Y, Board, Row),
    nth1(X, Row, Piece).

validate_move(GameState, 2, (X1,Y1)-(X2,Y2)) :-
    X1 > 0, X1 < 9,
    X2 > 0, X2 < 9,
    Y1 > 0, Y1 < 8,
    Y2 > 0, Y2 < 8,
    dx(X1, X2, DX), dy(Y1, Y2, DY),
    abs(DX, ABX), abs(DY, ABY),
    (ABX = 1, ABY = 1; ABX = 1, ABY = 0; ABX = 0, ABY = 1),
    XAdj is X2+DX, YAdj is Y2+DY,
    getPiece(GameState, X1, Y1, Org),
    (Org = 'X'),
    getPiece(GameState, X2, Y2, Dest1),
    (Dest1 = 'o';
    getPiece(GameState, XAdj, YAdj, Dest2),
    (Dest1 = ' '; Dest1 = 'x') , (Dest2 = ' ' ; Dest2 = 'x')).

validate_move(GameState, 2, (X1,Y1)-(X2,Y2)) :-
    X1 > 0, X1 < 9,
    X2 > 0, X2 < 9,
    Y1 > 0, Y1 < 8,
    Y2 > 0, Y2 < 8,
    dx(X1, X2, DX), dy(Y1, Y2, DY),
    abs(DX, ABX), abs(DY, ABY),
    (ABX = 1, ABY = 1; ABX = 1, ABY = 0; ABX = 0, ABY = 1),
    XAdj is X2+DX, YAdj is Y2+DY,
    getPiece(GameState, X1, Y1, Org),
    (Org = 'O'),
    getPiece(GameState, X2, Y2, Dest1),
    (Dest1 = 'x';
    getPiece(GameState, XAdj, YAdj, Dest2),
    (Dest1 = ' '; Dest1 = 'o') , (Dest2 = ' ' ; Dest2 = 'o')).

valid_moves(GameState, Player, ListOfMoves):-
  findall((X1,Y1)-(X2,Y2), (between(1, 8, X1), between(1, 7, Y1), between(1, 8, X2), between(1, 7, Y2), validate_move(GameState, Player, (X1,Y1)-(X2,Y2))), ListOfMoves).


execute_move(GameState, 1, (X1,Y1)-(X2,Y2), NewGameState) :-
    getPiece(GameState, X2, Y2, Dest),
   % empty cell
   (Dest = ' ' -> 
       removePiece(GameState, X1, Y1, GameState2),
       placePiece(GameState2, 'X', X2, Y2, NewGameState)
   ;
       % enemy wall
       (Dest = 'o' -> 
           removePiece(GameState, X2, Y2, GameState2),
           placePiece(GameState2, 'x', X1, Y1, NewGameState)
       ;
           % player wall
           (Dest = 'x' -> 
               dx(X1, X2, DX), dy(Y1, Y2, DY),
               XAdj is X2+DX, YAdj is Y2+DY,
               removePiece(GameState, X1, Y1, GameState2),
               placePiece(GameState2, 'X', X2, Y2, GameState3),
               placePiece(GameState3, 'x', XAdj, YAdj, NewGameState)
           )
       )
   ).

execute_move(GameState, 2, (X1,Y1)-(X2,Y2), NewGameState) :-
    getPiece(GameState, X2, Y2, Dest),
   % empty cell
   (Dest = ' ' -> 
       removePiece(GameState, X1, Y1, GameState2),
       placePiece(GameState2, 'O', X2, Y2, NewGameState)
   ;
       % enemy wall
       (Dest = 'x' -> 
           removePiece(GameState, X2, Y2, GameState2),
           placePiece(GameState2, 'o', X1, Y1, NewGameState)
       ;
           % player wall
           (Dest = 'o' -> 
               dx(X1, X2, DX), dy(Y1, Y2, DY),
               XAdj is X2+DX, YAdj is Y2+DY,
               removePiece(GameState, X1, Y1, GameState2),
               placePiece(GameState2, 'O', X2, Y2, GameState3),
               placePiece(GameState3, 'o', XAdj, YAdj, NewGameState)
           )
       )
   ).

reach_opposite_row(GameState, 1) :-
   getPiece(GameState, _ , 7, 'X').

reach_opposite_row(GameState, 2) :-
   getPiece(GameState, _ , 1, 'O').


