//
//  TTTTicTacToe.h
//  KiwiTicTacToe
//
//  Created by Matt Glover on 13/06/2014.
//  Copyright (c) 2014 Duchy Software Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const TicTacToeErrorDomain;

typedef NS_ENUM(NSUInteger, TicTacToeErrorCode) {
    TicTacToeErrorCodePositionTypeAlreadyOccupied = 301,
    TicTacToeErrorCodeOutOfTurn = 302
};

typedef NS_ENUM(NSUInteger, TicTacToePositionType) {
    TicTacToePositionTypeEmpty = 0,
    TicTacToePositionTypePlayerOne,
    TicTacToePositionTypePlayerTwo
};

typedef NS_ENUM(NSUInteger, TicTacToePlayer) {
    TicTacToePlayerOne = 1,
    TicTacToePlayerTwo
};

typedef NS_ENUM(NSUInteger, TicTacToePositionOutcome) {
    TicTacToePositionInvalid = 0,
    TicTacToePositionOutcomeNoWin,
    TicTacToePositionOutcomeWin,
    TicTacToePositionOutcomeNoPositionsRemaining
};

@interface TTTTicTacToe : NSObject
- (TicTacToePositionType)typeAtPositionIndex:(NSUInteger)index;
- (TicTacToePlayer)nextPlayer;
- (void)insertPlayer:(TicTacToePlayer)player atPositionIndex:(NSUInteger)index completion:(void(^)(TicTacToePositionOutcome outcome, NSError *error))completion;
@end
