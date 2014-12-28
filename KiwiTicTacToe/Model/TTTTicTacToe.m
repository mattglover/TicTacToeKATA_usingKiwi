//
//  TTTTicTacToe.m
//  KiwiTicTacToe
//
//  Created by Matt Glover on 13/06/2014.
//  Copyright (c) 2014 Duchy Software Ltd. All rights reserved.
//

#import "TTTTicTacToe.h"

NSString * const TicTacToeErrorDomain = @"com.duchysoftware.tictactoe";

@interface TTTTicTacToe ()
@property (nonatomic, strong) NSMutableArray *positions;
@property (nonatomic, assign) TicTacToePlayer lastPlayer;
@end

@implementation TTTTicTacToe



- (instancetype)init {
    if (self = [super init]) {
        _positions = [NSMutableArray array];
        
        for (int loop = 0; loop < 9; loop++) {
            [_positions addObject:@(TicTacToePositionTypeEmpty)];
        }
    }
    return self;
}

- (TicTacToePositionType)typeAtPositionIndex:(NSUInteger)index {
    NSUInteger positionType = [self.positions[index] integerValue];
    return positionType;
}

- (void)insertPlayer:(TicTacToePlayer)player atPositionIndex:(NSUInteger)index completion:(void(^)(TicTacToePositionOutcome outcome, NSError *error))completion {
    
    if (player == self.lastPlayer) {
        completion(TicTacToePositionInvalid, [NSError errorWithDomain:TicTacToeErrorDomain
                                                                 code:TicTacToeErrorCodeOutOfTurn
                                                             userInfo:nil]);
        return;
    }
    
    if (![self.positions[index] isEqual: @(TicTacToePositionTypeEmpty)] && completion) {
        completion(TicTacToePositionInvalid, [NSError errorWithDomain:TicTacToeErrorDomain
                                                                 code:TicTacToeErrorCodePositionTypeAlreadyOccupied
                                                             userInfo:nil]);
        return;
    }
    
    TicTacToePositionType positionType;
    switch (player) {
        case TicTacToePlayerOne:
            positionType = TicTacToePositionTypePlayerOne;
            break;
            
        case TicTacToePlayerTwo:
            positionType = TicTacToePositionTypePlayerTwo;
            break;
            
        default:
            positionType = TicTacToePositionTypeEmpty;
            break;
    }
    
    [self.positions replaceObjectAtIndex:index withObject:@(positionType)];
    self.lastPlayer = player;
    
    if (completion) {
        TicTacToePositionOutcome outcome = [self currentOutcome];
        completion(outcome, nil);
    }
}

- (TicTacToePositionOutcome)currentOutcome {
    
    TicTacToePositionOutcome outcome;
    
    if ([self haveWinner]) {
        outcome = TicTacToePositionOutcomeWin;
    }
    
    // if no winners then check for available positions then 'EndGame'
    if (outcome != TicTacToePositionOutcomeWin && ![self hasPositionsAvailable]) {
        outcome = TicTacToePositionOutcomeNoPositionsRemaining;
    }
    
    // if available positions and no winner then 'No Win'
    if (outcome != TicTacToePositionOutcomeNoPositionsRemaining && outcome != TicTacToePositionOutcomeWin) {
        outcome = TicTacToePositionOutcomeNoWin;
    }
    
    return outcome;
}

- (BOOL)hasPositionsAvailable {
    
    __block BOOL hasPositionsAvailable = NO;
    [self.positions enumerateObjectsUsingBlock:^(NSNumber *obj, NSUInteger idx, BOOL *stop) {
        if ([obj integerValue] == TicTacToePositionTypeEmpty) {
            hasPositionsAvailable = YES;
            *stop = YES;
        }
    }];
    
    return hasPositionsAvailable;
}

- (BOOL)haveWinner {
    BOOL haveWinner = [self topRowWinner] || [self middleRowWinner] || [self bottomRowWinner] || [self firstColumnWinner] || [self secondColumnWinner] || [self thirdColumnWinner] || [self forwardDiagonalWinner] || [self backwardDiagonalWinner];
    return haveWinner;
}

- (BOOL)topRowWinner {
    return [self arePlayersInThreePositionsTheSamePositionOne:0 positionTwo:1 positionThree:2];
}

- (BOOL)middleRowWinner {
    return [self arePlayersInThreePositionsTheSamePositionOne:3 positionTwo:4 positionThree:5];
}

- (BOOL)bottomRowWinner {
    return [self arePlayersInThreePositionsTheSamePositionOne:6 positionTwo:7 positionThree:8];
}

- (BOOL)firstColumnWinner {
    return [self arePlayersInThreePositionsTheSamePositionOne:0 positionTwo:3 positionThree:6];
}

- (BOOL)secondColumnWinner {
    return [self arePlayersInThreePositionsTheSamePositionOne:1 positionTwo:4 positionThree:7];
}

- (BOOL)thirdColumnWinner {
    return [self arePlayersInThreePositionsTheSamePositionOne:2 positionTwo:5 positionThree:8];
}

- (BOOL)forwardDiagonalWinner {
    return [self arePlayersInThreePositionsTheSamePositionOne:0 positionTwo:4 positionThree:8];
}

- (BOOL)backwardDiagonalWinner {
    return [self arePlayersInThreePositionsTheSamePositionOne:2 positionTwo:4 positionThree:6];
}

- (BOOL)arePlayersInThreePositionsTheSamePositionOne:(NSUInteger)positionOneIndex positionTwo:(NSUInteger)positionTwoIndex positionThree:(NSUInteger)positionThreeIndex {
    
    NSMutableSet *playersSet = [[NSMutableSet alloc] init];
    
    if ([self.positions[positionOneIndex] integerValue] != TicTacToePositionTypeEmpty) {
        [playersSet addObject:self.positions[positionOneIndex]];
        [playersSet addObject:self.positions[positionTwoIndex]];
        [playersSet addObject:self.positions[positionThreeIndex]];
    }
    
    return [playersSet count] == 1;
}

- (TicTacToePlayer)nextPlayer {
    
    if (self.lastPlayer == 0) {
        return TicTacToePlayerOne;
    }
    
    TicTacToePlayer nextPlayer = (self.lastPlayer == TicTacToePlayerOne) ? TicTacToePlayerTwo : TicTacToePlayerOne;
    return nextPlayer;
}

@end
