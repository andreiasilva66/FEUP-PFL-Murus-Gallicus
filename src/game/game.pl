
choose_game:-
    print_start_menu,
    read(Option),
    (
        Option = 1 ->
        print_mode_menu,
        read(Option2),
        (
            Option2 = 1 -> play_pvp;
            Option2 = 2 -> play_pvc;
            write("Invalid Option"), nl, choose_game

        );
        Option = 2 -> print_instructions;
        Option = 3 -> abort;
        write("Invalid Option"), nl, choose_game
    ).


play_pvp:-
    initial_state(GameState),
    display_game(GameState),
    game_cycle(GameState, 0).


game_cycle(GameState, Round):-
    Player is (Round mod 2)+1,
    check_move(GameState, Player, New_Board),
    game_cycle(New_Board, Player).

player_turn(Player) :-
    ( 
        Player = 1 -> 
            write('\nPlayer 1 Turn'), nl;
        Player = 2 -> 
            write('\nPlayer 2 Turn'), nl
    ).

check_move(GameState, Player, New_Board):-

    player_turn(Player),
    write('Piece Line: '),nl,
    read(X),
    write('Piece Column: '),nl,
    read(Y),
    write('Direction: '),nl,
    read(Dir),
    ( 
        check_valid_move(GameState, Player, X, Y, Dir) -> 
            removePiece(GameState, X, Y, New_Board),
            placePiece(New_Board, 'X', X, Y, Final_Board),
            display_game(Final_Board)
        ; 
        write('Invalid move. Please try again.'), nl,
        check_move(GameState, Player, New_Board)
    ).


check_valid_move(GameState, Player, X, Y, Dir) :-
    (
        Dir = 'T' -> New_X is X, New_Y is Y+1;
        Dir = 'L'-> New_X is X-1, New_Y is Y;
        Dir = 'D'-> New_X is X, New_Y is Y-1;
        Dir = 'R'-> New_X is X+1, New_Y is Y;
        Dir = 'TL'-> New_X is X - 1, New_Y is Y + 1;
        Dir = 'TR'-> New_X is X + 1, New_Y is Y + 1;
        Dir = 'DL'-> New_X is X - 1, New_Y is Y - 1;
        Dir = 'DR'-> New_X is X + 1, New_Y is Y - 1
    ),
    New_X > 0, New_X < 8, New_Y > 0, New_Y < 8,
    getPiece(GameState, X, Y, Piece),
    Player = 1 -> (
        Piece = 'X' -> (
            getPiece(GameState, New_X, New_Y, Dest),
            Dest = ' ' -> (
                removePiece(GameState, X, Y, New_Board),
                placePiece(New_Board, 'X', New_X, New_Y, Final_Board),
                displayBoard(Final_Board)
            ),
            Dest = 'O'-> (write('Invalid Move'), nl),
            Dest = 'o' -> (
                removePiece(GameState, X, Y, New_Board),
                placePiece(New_Board, 'x', New_X, New_Y, Final_Board),
                displayBoard(Final_Board)
            )
        ),
        Piece = 'x' -> (
         write('Invalid Move'),  nl   
        )
    ),
    Player = 2 -> (
        Piece = 'O' -> (
            getPiece(GameState, New_X, New_Y, Dest),
            Dest = ' ' -> (
                removePiece(GameState, X, Y, New_Board),
                placePiece(New_Board, 'O', New_X, New_Y, Final_Board),
                displayBoard(Final_Board)
            ),
            Dest = 'X'-> (write('Invalid Move'), nl),
            Dest = 'x' -> (
                removePiece(GameState, X, Y, New_Board),
                placePiece(New_Board, 'o', New_X, New_Y, Final_Board),
                displayBoard(Final_Board)
            )
        ),
        Piece = 'o' -> (
            write('Invalid Move')      
        )
    ).



move(GameState, Player, Move, NewGameState) :-
    validate_move(GameState, Player, Move),
    execute_move(GameState,Player, Move, NewGameState).
    

game_over(GameState, Winner) :-
   reach_opposite_row(GameState, Winner).

game_over(GameState, Winner) :-
   valid_moves(GameState, 1, []),
   Winner = 2.

game_over(GameState, Winner) :-
   valid_moves(GameState, 2, []),
   Winner = 1.