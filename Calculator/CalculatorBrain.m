//
//  CalculatorBrain.m
//  Calculator
//
//  Created by Leo Chen on 12/3/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "CalculatorBrain.h"

@interface CalculatorBrain()
@property (nonatomic, strong) NSMutableArray *programStack;

+ (NSString *)descriptionOfStack:(NSMutableArray *)stack;
+ (BOOL)isOperation:(id)stackElement;
@end

@implementation CalculatorBrain

@synthesize programStack = _programStack;

- (NSMutableArray *)programStack
{
    // make sure operandStack is never nil, allocate if nil (lazy instantiation)
    if (_programStack == nil) _programStack = [[NSMutableArray alloc] init];
    return _programStack;
}

- (void)pushVariable:(NSString *)variable
{
    [self.programStack addObject:variable];
}

- (void)pushOperand:(double)operand
{
    [self.programStack addObject:[NSNumber numberWithDouble:operand]];
}

//- (double)popOperand
//{
//    NSNumber *operandObject = [self.operandStack lastObject];
//    if (operandObject) [self.operandStack removeLastObject];
//    return [operandObject doubleValue];
//}

- (double)performOperation:(NSString *)operation
{
    [self.programStack addObject:operation];
    return [CalculatorBrain runProgram:self.program];
}

- (id)program
{
    return [self.programStack copy];
}

+ (BOOL)isOperation:(id)stackElement
{
    if ([stackElement isKindOfClass:[NSString class]] == NO)
        return NO;
    
    NSSet *operations = 
    [NSSet setWithObjects:@"+",@"-",@"/",@"*",@"sqrt",@"+/-",@"cos",@"sin",
     @"π",nil];
    
    if ([operations member:stackElement])
        return YES;
    else 
        return NO;
}

// ***start: description of program helper functions***

+ (NSSet *)multiplicationAndDivision
{
    return [NSSet setWithObjects:@"*", @"/", nil];
}

+ (BOOL)isMultiplicationOrDivision:(NSString *)operation
{
    return [[self multiplicationAndDivision] containsObject:operation];
}

+ (NSSet *)twoOperandOperators
{
    NSMutableSet *mutableSet = [[self multiplicationAndDivision] mutableCopy];
    [mutableSet unionSet:[NSSet setWithObjects:@"+", @"-", nil]];
    return mutableSet;
}

+ (BOOL)isTwoOperandOperation:(NSString *)operation
{
    return [[self twoOperandOperators] containsObject:operation];
}

+ (NSSet *)oneOperandOperators
{
    return [NSSet setWithObjects:@"sin", @"cos", @"sqrt", @"+/-", nil];
}

+ (BOOL)isOneOperandOperation:(NSString *)operation
{
    return [[self oneOperandOperators] containsObject:operation];
}

+ (NSSet *)zeroOperandOperators
{
    return [NSSet setWithObject:@"π", nil];
}

+ (BOOL)isZeroOperandOperation:(NSString *)operation
{
    return [[self zeroOperandOperators] containsObject:operation];
}

// ***end: description of program helper functions***

+ (NSString *)descriptionofTopOfStack:(NSMutableArray *)stack
{
    NSString *description;
    
    id topOfStack = [stack lastObject];
    if (topOfStack) [stack removeLastObject];
    
    if ([topOfStack isKindOfClass:[NSNumber class]]) {
        description = [topOfStack stringValue];
    }
    else if ([topOfStack isKindOfClass:[NSString class]]) {
        NSString *operation = topOfStack;
        if ([self isOperation:operation] && [self isTwoOperandOperation:operation]) {
            NSString *secondOperand = [self descriptionofTopOfStack:stack];
            NSString *format = @"(%@ %@ %@)";
            if ([self isMultiplicationOrDivision:operation]) {
                format = @"%@ %@ %@";
            }
            NSString *firstOperand = [self descriptionofTopOfStack:stack];
            description = [NSString stringWithFormat:format, firstOperand, operation, secondOperand];
        } else if ([self isOneOperandOperation:operation]) {
            NSString *topDescription = [self descriptionofTopOfStack:stack];
            NSString *format = @"%@ (%@)";
            description = [NSString stringWithFormat:format, operation, topDescription];
        }
    }
    
    return description;
}

+ (NSString *)descriptionOfProgram:(id)program
{
    NSMutableArray *stack;
    if ([program isKindOfClass:[NSArray class]]) {
        stack = [program mutableCopy];
    }
    return [self descriptionofTopOfStack:stack];
}

+ (double)popOperandOffStack:(NSMutableArray *)stack
{
    double result = 0;
    
    id topOfStack = [stack lastObject];
    if (topOfStack) [stack removeLastObject];
    
    if ([topOfStack isKindOfClass:[NSNumber class]]) {
        result = [topOfStack doubleValue];
    } 
    else if ([topOfStack isKindOfClass:[NSString class]]) {
        NSString *operation = topOfStack;
        if ([operation isEqualToString:@"+"]) {
            result = [self popOperandOffStack:stack] + [self popOperandOffStack:stack];
        } else if ([@"*" isEqualToString:operation]) {
            result = [self popOperandOffStack:stack] * [self popOperandOffStack:stack];
        } else if ([@"-" isEqualToString:operation]) {
            double subtrahend = [self popOperandOffStack:stack];
            result = [self popOperandOffStack:stack] - subtrahend;
        } else if ([@"/" isEqualToString:operation]) {
            double divisor = [self popOperandOffStack:stack];
            if (divisor != 0) {
                result = [self popOperandOffStack:stack] / divisor;
            }
        } else if ([@"π" isEqualToString:operation]) {
            result = M_PI;
        } else if ([@"sin" isEqualToString:operation]) {
            double theta = [self popOperandOffStack:stack] * M_PI / 180;
            result = sin(theta);
        } else if ([@"cos" isEqualToString:operation]) {
            double theta = [self popOperandOffStack:stack] * M_PI / 180;
            result = cos(theta);
        } else if ([@"sqrt" isEqualToString:operation]) {
            result = sqrt([self popOperandOffStack:stack]);
        }
    }
    
    return result;
}

+ (double)runProgram:(id)program
{
    NSMutableArray *stack;
    if ([program isKindOfClass:[NSArray class]]) {
        stack = [program mutableCopy];
    }
    return [self popOperandOffStack:stack];
}

+ (double)runProgram:(id)program usingVariableValues:(NSDictionary *)variableValues
{
    NSMutableArray *stack;
    NSSet *variables = [self variablesUsedInProgram:program];
    
    if (variables) {
        stack = [program mutableCopy];
        for (int i = 0; i < [stack count]; i++) {
            id element = [stack objectAtIndex:i];
            
            if ([variables containsObject:element] && [variableValues objectForKey:element]) {
                [stack replaceObjectAtIndex:i withObject:[variableValues objectForKey:element]];
            }
        }
    }
    
    return [self runProgram:stack];
}

// scans the program stack for variables used
+ (NSSet *)variablesUsedInProgram:(id)program {
    // create set of know variable names
    NSSet *variableNames = [NSMutableSet setWithObjects:@"a",@"b",@"c",nil];
    NSSet *variables;
    if ([program isKindOfClass:[NSArray class]]) {
        NSArray *stack = [program copy];
        for (id element in stack) {
            if ([element isKindOfClass:[NSString class]]) {
                NSString *stringElement = element;
                if ([variableNames containsObject:stringElement]) {
                    variables = [variables setByAddingObject:stringElement];
                }
            }
        }
    }
    return variables;
}

- (void)clearOperandStake
{
    [self.programStack removeAllObjects];
}

@end
