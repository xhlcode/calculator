//
//  ViewController.m
//  计算器
//
//  Created by 肖辉良 on 16/3/7.
//  Copyright © 2016年 肖辉良. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property BOOL isUseInEnterNumbe;   //是否输入完数字
@property BOOL secondEqual;  //是否 得到结果后继续运算
@property BOOL firstEqual;   //是否 输入两个数字进行运算
@property BOOL isContinue;   //是否继续计算
@property (strong,nonatomic)NSMutableArray *operandStack;  // 存储数字的数组
@property (assign,nonatomic)unichar symbol;  //接收到的符号  unichar = 两个字节
@property (assign,nonatomic) double secondNumber; //第二次输入的数字

@end




@implementation ViewController

- (NSMutableArray *)operandStack
{
    if (!_operandStack) {
        _operandStack = [NSMutableArray arrayWithCapacity:3];
    }
    return  _operandStack;
}





//接收传入的数字
- (IBAction)numberPress:(UIButton *)sender
{
    _secondEqual = NO;
    NSString *digit = sender.currentTitle;
    if(_isUseInEnterNumbe){
        //拼接字符串
        self.display.text = [self.display.text stringByAppendingString:digit];
    }else{
        self.display.text = digit;
        _isUseInEnterNumbe = YES;
    }
    
}

//接收传入的运算符
- (IBAction)operationPress:(UIButton *)sender
{
    self.firstEqual = YES;
    _secondEqual = NO;
    if(_isContinue) [self equalR]; //如果第一次输入数字没有按运算符 则执行等号操作
    NSString *operation = sender.currentTitle;  //获取输入的操作符
    [self pushOperation:operation];   //赋值给symbol
    
    [self numberInBrain];  //将数字存到数组中
    _isContinue = YES;
}


/**
 *  @author 肖辉良, 16-03-23 15:03:43
 *
 *  @brief 百分比计算
 *
 *  @param sender <#sender description#>
 */
- (IBAction)percent:(UIButton *)sender {
    if (!self.firstEqual) {  //即没有点击运算符
        double number = [self.display.text doubleValue]; //获取输入的数字
        double result = number/100;
        NSString *strResult = [NSString stringWithFormat:@"%lg",result];
        self.display.text = strResult;
        
    }
}


/**
 *  @author 肖辉良, 16-03-23 15:03:52
 *
 *  @brief 正负操作
 */
- (IBAction)negative {
    NSString *digit =self.display.text;
    NSString *negative = @"-";
    BOOL isNegative = [digit hasPrefix:negative];
    if (isNegative) {
        NSRange range = NSMakeRange(-1,1);
        NSString *strPositive = [digit stringByReplacingOccurrencesOfString:negative withString:@""];
        self.display.text = strPositive;
    }else{
        NSString *strNegative = [NSString stringWithFormat:@"-%@",digit];
        self.display.text = strNegative;
    }
    
}




/**
 *  清零操作
 */
- (IBAction)zero
{
    self.display.text = @"0";
    
    _isContinue        = NO;
    _isUseInEnterNumbe = NO;
    [self.operandStack removeAllObjects];  //清空数组
    [self pushNumberInStack:0.0 andBool:NO];
    self.secondEqual   = NO;
    self.firstEqual    = NO;
    
}




//将输入的操作符赋值给symbol
- (void)pushOperation:(NSString *)Operation
{
    self.symbol = [Operation characterAtIndex:0];
}


/**
 *  @author 肖辉良, 16-03-23 15:03:46
 *
 *  @brief 将输入的数字存入到数组中
 */
- (void)numberInBrain
{
    _isUseInEnterNumbe = NO;
    
    [self pushNumberInStack:[self.display.text doubleValue] andBool:_secondEqual];  //调用方法 将数字存到数组中
    
}


- (void)pushNumberInStack:(double)aDouble andBool:(BOOL)aBool
{
    double number     = aDouble;
    NSNumber *operand = [NSNumber numberWithDouble:number];//将传入的运算数转化成NSNumber
    [self.operandStack addObject:operand];    //将运算数 添加到数组中
    if(!aBool){      //如果 —_secondEqual = NO
        self.secondNumber = [[self.operandStack lastObject] doubleValue];
    }
    
    
}


//输入 = 计算
- (IBAction)equalR {
    if(self.firstEqual){   //如果点击了运算符  即是 输入两个数字进行计算
        _isContinue = NO;   //将继续计算 改为 NO;
        [self numberInBrain];   //将数字存储到数组中
        double resultNumber        = [self result:_secondEqual];
        NSMutableString *resultStr = [NSMutableString stringWithFormat:@"%lg",resultNumber];//将double 转换成string类型
        if (resultNumber >100000) {
            //计算它的值是几次方
            int count = 0;
            while (resultNumber >= 10) {
                resultNumber /= 10;
                count++;
            }
            [resultStr deleteCharactersInRange:NSMakeRange(0, [resultStr length])];  //清空字符
            [resultStr appendFormat:@"%lg",resultNumber];
            [resultStr appendFormat:@"^%d",count];
            
        }
        self.display.text = resultStr;     //将结果显示在UILabel上  即可实现在进行连续计算时将结果直接当做第一个数字添加到数组中 即实现连续计算
        [resultStr deleteCharactersInRange:NSMakeRange(0, [resultStr length])];  //清空字符
        _secondEqual = YES;
    }else{
        double resultNumber = [self.display.text doubleValue];
        NSMutableString *resultStr = [NSMutableString stringWithFormat:@"%lg",resultNumber];    //将double 转换成string类型
        if(resultNumber > 100000){
            int count = 0;
            while(resultNumber >=10){
                resultNumber /=10;
                count++;
            }
            [resultStr deleteCharactersInRange:NSMakeRange(0, [resultStr length])];  //清空字符
            [resultStr appendFormat:@"%lg",resultNumber];
            [resultStr appendFormat:@"^%d",count];
            
        }
        self.display.text = resultStr;
        [resultStr deleteCharactersInRange:NSMakeRange(0, [resultStr length])];  //清空字符
        
        
    }
    self.firstEqual = NO;
    float a = 23;
    NSLog(@"%f",a/100);
    
}

//具体计算过程
- (double)result:(BOOL)secondEq
{
    NSString *operation = [NSString stringWithFormat:@"%c",self.symbol];
    if (!secondEq) {   //如果_secondEqual = NO;  即是 输入两个数字进行运算
        if (self.operandStack.count>1) {
            double number2 = [self outANumber];
            double number1 = [self outANumber];
            double result= 0.0;
            if ([operation isEqualToString:@"+"]) result      = number1 + number2;
            else if ([operation isEqualToString:@"-"]) result = number1 - number2;
            else if ([operation isEqualToString:@"*"]) result = number1 * number2;
            else if ([operation isEqualToString:@"/"]) result = number1 / number2;
            return result;}
        else{
            [self zero];
            return 0;
        }
    }else{
        double number = [self outANumber];
        
        double result= 0.0;
        if ([operation isEqualToString:@"+"]) result      = number + self.secondNumber;
        else if ([operation isEqualToString:@"-"]) result = number - self.secondNumber;
        else if ([operation isEqualToString:@"*"]) result = number * self.secondNumber;
        else if ([operation isEqualToString:@"/"]) result = number / self.secondNumber;
        
        return result;
        
    }
    
}

- (double)outANumber
{
    double number = [[self.operandStack lastObject]doubleValue];  //取最后一个数
    if([self.operandStack lastObject]){
        [self.operandStack removeLastObject];  //如果有值 则移除它
    }
    return number;
    
}





@end
