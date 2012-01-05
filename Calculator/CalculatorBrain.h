//
//  CalculatorBrain.h
//  Calculator
//
//  Created by Leo Chen on 12/3/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CalculatorBrain : NSObject

- (void)pushOperand:(double)operand;
- (double)performOperation:(NSString *)operation;
- (void)clearOperandStake;

@property (readonly) id program;

+ (double)runProgram:(id)program; //takes program and runs it (pop top element in stack & run it)
+ (NSString *)descriptionOfProgram:(id)program;

@end
