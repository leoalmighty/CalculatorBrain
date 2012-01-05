//
//  CalculatorViewController.m
//  Calculator
//
//  Created by Leo Chen on 12/3/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "CalculatorViewController.h"
#import "CalculatorBrain.h"

@interface CalculatorViewController() //private properties
@property (nonatomic) BOOL userIsInTheMiddleOfEnteringANumber;
@property (nonatomic, strong) CalculatorBrain *brain;
@end

@implementation CalculatorViewController

@synthesize display = _display;
@synthesize feedDisplay = _feedDisplay;
@synthesize userIsInTheMiddleOfEnteringANumber = _userIsInTheMiddleOfEnteringANumber;
@synthesize brain = _brain;

- (CalculatorBrain *)brain
{
    if (!_brain) _brain = [[CalculatorBrain alloc] init];
    return _brain;
}

- (IBAction)digitPressed:(UIButton *)sender
{
    NSString *digit = [sender currentTitle];
    // NSLog(@"Digit pressed = %@", digit);
    if (self.userIsInTheMiddleOfEnteringANumber) {
        
        if ([digit isEqualToString:(@".")]) {
            NSRange range = [self.display.text rangeOfString:@"."];
            if (range.location == NSNotFound) {
                self.display.text = [self.display.text stringByAppendingString:digit];
            }
        } else {
            self.display.text = [self.display.text stringByAppendingString:digit];
        }
        
    } else {
        self.display.text = digit;
        self.userIsInTheMiddleOfEnteringANumber = YES;
    }
}

- (IBAction)enterPressed
{
    NSString *digit = self.display.text;
    
    [self.brain pushOperand:[digit doubleValue]];
    self.feedDisplay.text = [[self.feedDisplay.text stringByAppendingString:digit] stringByAppendingString:@" "];
    self.userIsInTheMiddleOfEnteringANumber = NO;
}

- (IBAction)operationPressed:(UIButton *)sender 
{
    if (self.userIsInTheMiddleOfEnteringANumber) [self enterPressed];
    double result = [self.brain performOperation:sender.currentTitle];
    NSString *resultString = [NSString stringWithFormat:@"%g", result];
    if ([sender.currentTitle isEqualToString:@"π"]) {
        self.feedDisplay.text = [[self.feedDisplay.text stringByAppendingString:sender.currentTitle] stringByAppendingString:@" "];
    } else {
        self.feedDisplay.text = [[self.feedDisplay.text stringByAppendingString:sender.currentTitle] stringByAppendingString:@" = "];
    }
    self.display.text = resultString;
    self.userIsInTheMiddleOfEnteringANumber = NO;
}

- (IBAction)clearPressed {
    self.display.text = @"0";
    self.feedDisplay.text = @"";
    [self.brain clearOperandStake];
}

- (IBAction)backSpacePressed {
    NSString *string = self.display.text;
    if ([string length] > 1) {
        self.display.text = [string substringToIndex:[string length] -1];
    } else {
        self.display.text = @"0";
    }
}

- (IBAction)changeSignPressed {
    
    NSString *string = self.display.text;
    
    NSRange range = [string rangeOfString:@"-"];
    if (range.location == NSNotFound) {
        self.display.text = [@"-" stringByAppendingString:self.display.text];
        if (self.userIsInTheMiddleOfEnteringANumber == NO) [self enterPressed];
    } else {
        self.display.text = [string substringFromIndex:1];
        if (self.userIsInTheMiddleOfEnteringANumber == NO) [self enterPressed];
    }
}

@end
