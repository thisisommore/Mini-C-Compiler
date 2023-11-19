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
#include "ast.hpp"
#include <map>

using namespace llvm;
using namespace std;

LLVMContext *TheContext = nullptr;
IRBuilder<> *Builder = nullptr;
Module *TheModule = nullptr;
map<std::string, Value *> NamedValues;

void set_vars()
{
    TheContext = new LLVMContext();
    Builder = new IRBuilder(*TheContext);
    TheModule = new Module("mini c JIT", *TheContext);

    // Create a function to insert our variable into
    auto *funcType = llvm::FunctionType::get(Builder->getInt32Ty(), false);
    auto *mainFunc = llvm::Function::Create(funcType, llvm::Function::ExternalLinkage, "main", TheModule);

    // Create a basic block in the function
    auto *entry = llvm::BasicBlock::Create(*TheContext, "entrypoint", mainFunc);
    Builder->SetInsertPoint(entry);
}

// Test code for testing/experimenting with the api of llvm, this function is never executed
void exp()
{
    auto var = Builder->CreateAlloca(Builder->getInt32Ty(), 0, "max");
    auto if_block = BasicBlock::Create(*TheContext, "if_block", nullptr);
    Value *end_block = BasicBlock::Create(*TheContext, "end_block", nullptr);
    Builder->CreateStore(Builder->getInt32(0), var);
    auto cond = Builder->CreateICmpEQ(var, var, "cond");

    Builder->CreateCondBr(cond, if_block, (BasicBlock *)end_block);
    Builder->SetInsertPoint((BasicBlock *)if_block);
    //...
    Builder->SetInsertPoint((BasicBlock *)end_block);

    TheModule->print(llvm::outs(), nullptr);
}

Value *NumberNode::codegen()
{
    return ConstantInt::get(*TheContext, APInt(32, number, true));
}

Function *FunctionD::codegen()
{
    auto FT = FunctionType::get(returnType, argsType, false);
    auto F = Function::Create(FT, Function::ExternalLinkage, name, TheModule);
    auto idx = 0;
    for (auto &arg : F->args())
        arg.setName(argNames[idx++]);

    auto BB = BasicBlock::Create(*TheContext, "entry", F);
    Builder->SetInsertPoint(BB);
    if (auto BodyVal = body->codegen())
    {
        Builder->CreateRet(BodyVal);
        return F;
    }
    F->eraseFromParent();
    return nullptr;
}

Value *FunctionC::codegen()
{
    auto calle = TheModule->getFunction(functionName);
    // TODO error if no calle
    // TODO error if no size match of args
    vector<Value *> valueArgs;
    for (auto a : args)
    {
        valueArgs.push_back(a->codegen());
    }
    return Builder->CreateCall(calle, valueArgs, "calltmp");
}

Value *BinaryExpr::codegen()
{
    auto ValL = LHS->codegen();
    auto ValR = LHS->codegen();
    switch (OP)
    {
    case '+':
        return Builder->CreateFAdd(ValL, ValR, "addtmp");
        break;
    case '-':
        return Builder->CreateFSub(ValL, ValR, "subtmp");
        break;
    case '/':
        return Builder->CreateFDiv(ValL, ValR, "divtmp");
        break;
    case '*':
        return Builder->CreateFMul(ValL, ValR, "multmp");
        break;

    default:
        return nullptr;
        break;
    }
}

Value *CmpExpr::codegen()
{
    return nullptr;
}
