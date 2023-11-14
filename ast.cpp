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

static LLVMContext *TheContext = nullptr;
static IRBuilder<> *Builder = nullptr;
static Module *TheModule = nullptr;
static map<std::string, Value *> NamedValues;

void set_vars()
{
    TheContext = new LLVMContext();
    Builder = new IRBuilder(*TheContext);
    TheModule = new Module("mini c JIT", *TheContext);
}
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

    Value *codegen() override
    {
        return ConstantInt::get(*TheContext, APInt(32, number, true));
    }
};

class FunctionD : public ExprNode
{

    Type *returnType;
    string name;
    vector<Type *> argsType;
    vector<string> argNames;
    ExprNode *body;
    FunctionD(Type *returnType,
              string name,
              vector<Type *> argsType,
              vector<string> argNames,
              ExprNode *body) : returnType(returnType), name(name), argsType(argsType), argNames(argNames), body(body){};

    Value *codegen() override
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
};

class FunctionC : public ExprNode
{
    vector<NumberNode> *args;
    StringRef functionName;
    FunctionC(vector<NumberNode> *args, StringRef functionName) : args(args), functionName(functionName) {}
    Value *codegen() override
    {
        auto calle = TheModule->getFunction(functionName);
        // TODO error if no calle
        // TODO error if no size match of args
        vector<Value *> valueArgs;
        for (auto a : *args)
        {
            valueArgs.push_back(a.codegen());
        }
        return Builder->CreateCall(calle, valueArgs, "calltmp");
    }
};

class BinaryExpr : public ExprNode
{
    ExprNode *LHS;
    ExprNode *RHS;
    char OP;
    BinaryExpr(ExprNode *LHS,
               ExprNode *RHS,
               char OP) : LHS(LHS), RHS(RHS), OP(OP){};
    Value *codegen() override
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
};
