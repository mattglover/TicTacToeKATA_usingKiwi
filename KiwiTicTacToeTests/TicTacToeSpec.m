#import <Kiwi/Kiwi.h>

static NSString * const TicTacToeErrorDomain = @"com.duchysoftware.tictactoe";

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

@interface TicTacToe : NSObject
- (TicTacToePositionType)typeAtPositionIndex:(NSUInteger)index;
- (TicTacToePlayer)nextPlayer;
- (void)insertPlayer:(TicTacToePlayer)player atPositionIndex:(NSUInteger)index completion:(void(^)(TicTacToePositionOutcome outcome, NSError *error))completion;
@end

@interface TicTacToe ()
@property (nonatomic, strong) NSMutableArray *positions;
@property (nonatomic, assign) TicTacToePlayer lastPlayer;
@end

@implementation TicTacToe

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

SPEC_BEGIN(TicTacToeSpec)

describe(@"TicTacToe", ^{
    
    __block TicTacToe *sut;
    
    beforeEach(^{
        sut = [[TicTacToe alloc] init];
    });
    
    afterEach(^{
        sut = nil;
    });
    
    context(@"when created", ^{
        
        it(@"should not be nil", ^{
            [sut shouldNotBeNil];
        });
        
        it(@"should return 'TicTacToePositionTypeEmpty' for all 9 indexes", ^{
            [[theValue([sut typeAtPositionIndex:0]) should] equal:theValue(TicTacToePositionTypeEmpty)];
            [[theValue([sut typeAtPositionIndex:1]) should] equal:theValue(TicTacToePositionTypeEmpty)];
            [[theValue([sut typeAtPositionIndex:2]) should] equal:theValue(TicTacToePositionTypeEmpty)];
            [[theValue([sut typeAtPositionIndex:3]) should] equal:theValue(TicTacToePositionTypeEmpty)];
            [[theValue([sut typeAtPositionIndex:4]) should] equal:theValue(TicTacToePositionTypeEmpty)];
            [[theValue([sut typeAtPositionIndex:5]) should] equal:theValue(TicTacToePositionTypeEmpty)];
            [[theValue([sut typeAtPositionIndex:6]) should] equal:theValue(TicTacToePositionTypeEmpty)];
            [[theValue([sut typeAtPositionIndex:7]) should] equal:theValue(TicTacToePositionTypeEmpty)];
            [[theValue([sut typeAtPositionIndex:8]) should] equal:theValue(TicTacToePositionTypeEmpty)];
        });
        
        it(@"should return 'TicTacToePlayerOne' for nextPlayer", ^{
            [[theValue([sut nextPlayer]) should] equal:theValue(TicTacToePlayerOne)];
        });
    });
    
    context(@"when playerOne plays token onto empty position", ^{
        
        context(@"into index 0", ^{
            beforeEach(^{
                [sut insertPlayer:TicTacToePlayerOne atPositionIndex:0 completion:nil];
            });
            
            it(@"should return 'TicTacToePositionTypePlayerOne' for index 0", ^{
                [[theValue([sut typeAtPositionIndex:0]) should] equal:theValue(TicTacToePositionTypePlayerOne)];
            });
            
            it(@"should return 'PositionTypePlayerTwo' for nextPlayer", ^{
                [[theValue([sut nextPlayer]) should] equal:theValue(TicTacToePlayerTwo)];
            });
            
            context(@"playerTwo follows with valid move", ^{
                it(@" should return TicTacToePositionOutcomeNoWin in completion", ^{
                    [sut insertPlayer:TicTacToePlayerTwo atPositionIndex:1 completion:^(TicTacToePositionOutcome outcome, NSError *error) {
                        [[theValue(outcome) should] equal:theValue(TicTacToePositionOutcomeNoWin)];
                    }];
                });
            });
        });
    });
    
    context(@"playerTwo tries to play in already occupied position", ^{
        
        beforeEach(^{
            [sut insertPlayer:TicTacToePlayerOne atPositionIndex:0 completion:nil];
        });
        
        it(@"should return TicTacToePositionInvalid in completion", ^{
            [sut insertPlayer:TicTacToePlayerTwo atPositionIndex:0 completion:^(TicTacToePositionOutcome outcome, NSError *error) {
                [[theValue(outcome) should] equal:theValue(TicTacToePositionInvalid)];
            }];
        });
        
        it(@"should return 'TicTacToeErrorCodePositionTypeAlreadyOccupied' as Error code", ^{
            [sut insertPlayer:TicTacToePlayerTwo atPositionIndex:0 completion:^(TicTacToePositionOutcome outcome, NSError *error) {
                [[theValue(error.code) should] equal:theValue(TicTacToeErrorCodePositionTypeAlreadyOccupied)];
            }];
        });
        
        it(@"should return 'PositionTypePlayerTwo' for nextPlayer", ^{
            [[theValue([sut nextPlayer]) should] equal:theValue(TicTacToePlayerTwo)];
        });
    });
    
    context(@"player tries to play out of turn", ^{
        
        beforeEach(^{
            [sut insertPlayer:TicTacToePlayerOne atPositionIndex:0 completion:nil];
        });
        
        it(@"should return TicTacToePositionInvalid in completion", ^{
            [sut insertPlayer:TicTacToePlayerOne atPositionIndex:1 completion:^(TicTacToePositionOutcome outcome, NSError *error) {
                [[theValue(outcome) should] equal:theValue(TicTacToePositionInvalid)];
            }];
        });
        
        it(@"should return 'TicTacToeErrorCodeOutOfTurn' as Error code", ^{
            [sut insertPlayer:TicTacToePlayerOne atPositionIndex:1 completion:^(TicTacToePositionOutcome outcome, NSError *error) {
                [[theValue(error.code) should] equal:theValue(TicTacToeErrorCodeOutOfTurn)];
            }];
        });
    });
    
    context(@"last position is taken", ^{
        
        it(@"should return TicTacToePositionOutcomeNoPositionsRemaining in completion", ^{
            //    X0X
            //    XX0
            //    0X0
            [sut insertPlayer:TicTacToePlayerOne atPositionIndex:0 completion:nil];
            [sut insertPlayer:TicTacToePlayerTwo atPositionIndex:1 completion:nil];
            [sut insertPlayer:TicTacToePlayerOne atPositionIndex:2 completion:nil];
            [sut insertPlayer:TicTacToePlayerTwo atPositionIndex:5 completion:nil];
            [sut insertPlayer:TicTacToePlayerOne atPositionIndex:3 completion:nil];
            [sut insertPlayer:TicTacToePlayerTwo atPositionIndex:6 completion:nil];
            [sut insertPlayer:TicTacToePlayerOne atPositionIndex:4 completion:nil];
            [sut insertPlayer:TicTacToePlayerTwo atPositionIndex:8 completion:nil];
            [sut insertPlayer:TicTacToePlayerOne atPositionIndex:7 completion:^(TicTacToePositionOutcome outcome, NSError *error) {
                [[theValue(outcome) should] equal:theValue(TicTacToePositionOutcomeNoPositionsRemaining)];
            }];
        });
    });
    
    context(@"playerOne has Winning line on top row", ^{
        
        it(@"should return TicTacToePositionOutcomeWin in completion", ^{
            [sut insertPlayer:TicTacToePlayerOne atPositionIndex:0 completion:nil];
            [sut insertPlayer:TicTacToePlayerTwo atPositionIndex:3 completion:nil];
            [sut insertPlayer:TicTacToePlayerOne atPositionIndex:1 completion:nil];
            [sut insertPlayer:TicTacToePlayerTwo atPositionIndex:4 completion:nil];
            [sut insertPlayer:TicTacToePlayerOne atPositionIndex:2 completion:^(TicTacToePositionOutcome outcome, NSError *error) {
                [[theValue(outcome) should] equal:theValue(TicTacToePositionOutcomeWin)];
            }];
        });
    });
    
    context(@"playerTwo has Winning line on Middle row", ^{
        
        it(@"should return TicTacToePositionOutcomeWin in completion", ^{
            [sut insertPlayer:TicTacToePlayerOne atPositionIndex:8 completion:nil];
            [sut insertPlayer:TicTacToePlayerTwo atPositionIndex:3 completion:nil];
            [sut insertPlayer:TicTacToePlayerOne atPositionIndex:0 completion:nil];
            [sut insertPlayer:TicTacToePlayerTwo atPositionIndex:4 completion:nil];
            [sut insertPlayer:TicTacToePlayerOne atPositionIndex:1 completion:nil];
            [sut insertPlayer:TicTacToePlayerTwo atPositionIndex:5 completion:^(TicTacToePositionOutcome outcome, NSError *error) {
                [[theValue(outcome) should] equal:theValue(TicTacToePositionOutcomeWin)];
            }];
        });
    });
    
    context(@"playerTwo has Winning line on Bottom row", ^{
        
        it(@"should return TicTacToePositionOutcomeWin in completion", ^{
            [sut insertPlayer:TicTacToePlayerOne atPositionIndex:5 completion:nil];
            [sut insertPlayer:TicTacToePlayerTwo atPositionIndex:6 completion:nil];
            [sut insertPlayer:TicTacToePlayerOne atPositionIndex:0 completion:nil];
            [sut insertPlayer:TicTacToePlayerTwo atPositionIndex:7 completion:nil];
            [sut insertPlayer:TicTacToePlayerOne atPositionIndex:1 completion:nil];
            [sut insertPlayer:TicTacToePlayerTwo atPositionIndex:8 completion:^(TicTacToePositionOutcome outcome, NSError *error) {
                [[theValue(outcome) should] equal:theValue(TicTacToePositionOutcomeWin)];
            }];
        });
    });
    
    context(@"playerOne has Winning line on First column", ^{
        
        it(@"should return TicTacToePositionOutcomeWin in completion", ^{
            [sut insertPlayer:TicTacToePlayerOne atPositionIndex:0 completion:nil];
            [sut insertPlayer:TicTacToePlayerTwo atPositionIndex:2 completion:nil];
            [sut insertPlayer:TicTacToePlayerOne atPositionIndex:3 completion:nil];
            [sut insertPlayer:TicTacToePlayerTwo atPositionIndex:4 completion:nil];
            [sut insertPlayer:TicTacToePlayerOne atPositionIndex:6 completion:^(TicTacToePositionOutcome outcome, NSError *error) {
                [[theValue(outcome) should] equal:theValue(TicTacToePositionOutcomeWin)];
            }];
        });
    });
    
    context(@"playerOne has Winning line on Second column", ^{
        
        it(@"should return TicTacToePositionOutcomeWin in completion", ^{
            [sut insertPlayer:TicTacToePlayerOne atPositionIndex:1 completion:nil];
            [sut insertPlayer:TicTacToePlayerTwo atPositionIndex:2 completion:nil];
            [sut insertPlayer:TicTacToePlayerOne atPositionIndex:4 completion:nil];
            [sut insertPlayer:TicTacToePlayerTwo atPositionIndex:5 completion:nil];
            [sut insertPlayer:TicTacToePlayerOne atPositionIndex:7 completion:^(TicTacToePositionOutcome outcome, NSError *error) {
                [[theValue(outcome) should] equal:theValue(TicTacToePositionOutcomeWin)];
            }];
        });
    });
    
    context(@"playerOne has Winning line on Third column", ^{
        
        it(@"should return TicTacToePositionOutcomeWin in completion", ^{
            [sut insertPlayer:TicTacToePlayerOne atPositionIndex:2 completion:nil];
            [sut insertPlayer:TicTacToePlayerTwo atPositionIndex:1 completion:nil];
            [sut insertPlayer:TicTacToePlayerOne atPositionIndex:5 completion:nil];
            [sut insertPlayer:TicTacToePlayerTwo atPositionIndex:3 completion:nil];
            [sut insertPlayer:TicTacToePlayerOne atPositionIndex:8 completion:^(TicTacToePositionOutcome outcome, NSError *error) {
                [[theValue(outcome) should] equal:theValue(TicTacToePositionOutcomeWin)];
            }];
        });
    });
    
    context(@"playerOne has Winning Forward Diagonal", ^{
        
        it(@"should return TicTacToePositionOutcomeWin in completion", ^{
            [sut insertPlayer:TicTacToePlayerOne atPositionIndex:0 completion:nil];
            [sut insertPlayer:TicTacToePlayerTwo atPositionIndex:1 completion:nil];
            [sut insertPlayer:TicTacToePlayerOne atPositionIndex:4 completion:nil];
            [sut insertPlayer:TicTacToePlayerTwo atPositionIndex:3 completion:nil];
            [sut insertPlayer:TicTacToePlayerOne atPositionIndex:8 completion:^(TicTacToePositionOutcome outcome, NSError *error) {
                [[theValue(outcome) should] equal:theValue(TicTacToePositionOutcomeWin)];
            }];
        });
    });
    
    context(@"playerOne has Winning Backward Diagonal", ^{
        
        it(@"should return TicTacToePositionOutcomeWin in completion", ^{
            [sut insertPlayer:TicTacToePlayerOne atPositionIndex:2 completion:nil];
            [sut insertPlayer:TicTacToePlayerTwo atPositionIndex:1 completion:nil];
            [sut insertPlayer:TicTacToePlayerOne atPositionIndex:4 completion:nil];
            [sut insertPlayer:TicTacToePlayerTwo atPositionIndex:3 completion:nil];
            [sut insertPlayer:TicTacToePlayerOne atPositionIndex:6 completion:^(TicTacToePositionOutcome outcome, NSError *error) {
                [[theValue(outcome) should] equal:theValue(TicTacToePositionOutcomeWin)];
            }];
        });
    });
    
});

SPEC_END