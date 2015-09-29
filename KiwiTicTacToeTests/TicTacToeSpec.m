#import <Kiwi/Kiwi.h>

#import "TTTTicTacToe.h"

SPEC_BEGIN(TicTacToeSpec)

describe(@"TTTTicTacToe", ^{
    
    __block TTTTicTacToe *sut;
    
    beforeEach(^{
        sut = [[TTTTicTacToe alloc] init];
    });
    
    afterEach(^{
        sut = nil;
    });
    
    context(@"when created", ^{
        
        it(@"should not be nil", ^{
            [sut shouldNotBeNil];
        });
        
        it(@"should return 'TicTacToePositionTypeEmpty' for all 9 indexes", ^{
            
            for (NSInteger loop = 0; loop <= 8; loop++) {
                 [[theValue([sut typeAtPositionIndex:loop]) should] equal:theValue(TicTacToePositionTypeEmpty)];
            }
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
                [[theValue(outcome) shouldNot] equal:theValue(TicTacToePositionOutcomeWin)];
            }];
        });
    });
});

SPEC_END