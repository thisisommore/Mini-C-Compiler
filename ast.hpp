#pragma once

#include <llvm/ADT/APFloat.h>
#include <llvm/ADT/STLExtras.h>
#include <llvm/IR/BasicBlock.h>
#include <llvm/IR/Constants.h>
#include <llvm/IR/DerivedTypes.h>
#include <llvm/IR/Function.h>
#include <llvm/IR/IRBuilder.h>
#include <llvm/IR/LLVMContext.h>
#include <llvm/IR/Module.h>
#include <llvm/IR/Type.h>
#include <llvm/IR/Verifier.h>
#include <map>
using namespace llvm;
using namespace std;
extern LLVMContext *TheContext;
extern IRBuilder<> *Builder;
extern Module *TheModule;
void set_vars();

class ExprNode
{
public:
    virtual Value *codegen() = 0;
};

class NumberNode : public ExprNode
{
public:
    int number;
    NumberNode(const double &number) : number(number) {}

    Value *codegen() override;
};

class FunctionD : public ExprNode
{
public:
    Type *returnType;
    string name;
    vector<Type *> argsType;
    vector<string> argNames;
    ExprNode *body;
    FunctionD(
        Type *returnType,
        string name,
        vector<Type *> argsType,
        vector<string> argNames,
        ExprNode *body) : returnType(returnType),
                          name(name), argsType(argsType), argNames(argNames), body(body){};

    Function *codegen() override;
};

class FunctionC : public ExprNode
{
    vector<ExprNode *> args;
    StringRef functionName;
    FunctionC(vector<ExprNode *> args, StringRef functionName) : args(args), functionName(functionName) {}
    Value *codegen() override;
};

class BinaryExpr : public ExprNode
{
    ExprNode *LHS;
    ExprNode *RHS;
    char OP;
    BinaryExpr(ExprNode *LHS,
               ExprNode *RHS,
               char OP) : LHS(LHS), RHS(RHS), OP(OP){};
    Value *codegen() override;
};

class Body : public ExprNode
{
public:
    vector<ExprNode *> Exprs;
    Body(vector<ExprNode *> Exprs) : Exprs(Exprs){};
    Value *codegen() override;
};

class VariableExpr : public ExprNode
{
    BasicBlock *bb;
    ExprNode *initialValue;
    string name;
    VariableExpr(string name) : name(name), bb(bb), initialValue(initialValue){};
    AllocaInst *codegen() override;
};

class CmpExpr : public ExprNode
{
public:
    llvm::CmpInst::Predicate predicate;
    CmpExpr(llvm::CmpInst::Predicate predicate) : predicate(predicate){};
    Value *codegen() override;
};