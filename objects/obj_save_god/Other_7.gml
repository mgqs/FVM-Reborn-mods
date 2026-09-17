/*
DECOMPILER FAILED!

Underanalyzer.Decompiler.DecompilerException: Decompiler error during AST building: Free-floating expression found
 ---> Underanalyzer.Decompiler.DecompilerException: Free-floating expression found
   at Underanalyzer.Decompiler.AST.BlockSimulator.SimulatePopDelete(ASTBuilder builder, List`1 output)
   at Underanalyzer.Decompiler.AST.BlockSimulator.Simulate(ASTBuilder builder, List`1 output, Block block)
   at Underanalyzer.Decompiler.ControlFlow.Block.BuildAST(ASTBuilder builder, List`1 output)
   at Underanalyzer.Decompiler.AST.ASTBuilder.BuildArbitrary(IControlFlowNode startNode, List`1 output, Int32 numAllowedExpressions)
   at Underanalyzer.Decompiler.ControlFlow.ShortCircuit.BuildAST(ASTBuilder builder, List`1 output)
   at Underanalyzer.Decompiler.AST.ASTBuilder.BuildBlock(IControlFlowNode startNode)
   at Underanalyzer.Decompiler.ControlFlow.BinaryBranch.BuildAST(ASTBuilder builder, List`1 output)
   at Underanalyzer.Decompiler.AST.ASTBuilder.BuildBlock(IControlFlowNode startNode)
   at Underanalyzer.Decompiler.AST.IFragmentNode.Create(ASTBuilder builder, Fragment fragment)
   at Underanalyzer.Decompiler.ControlFlow.Fragment.BuildAST(ASTBuilder builder, List`1 output)
   at Underanalyzer.Decompiler.AST.ASTBuilder.Build()
   at Underanalyzer.Decompiler.DecompileContext.DecompileAST()
   --- End of inner exception stack trace ---
   at Underanalyzer.Decompiler.DecompileContext.DecompileAST()
   at Underanalyzer.Decompiler.DecompileContext.DecompileToAST()
   at Underanalyzer.Decompiler.DecompileContext.DecompileToString()
   at Submission#0.DumpCode(UndertaleCode code) in C:\Users\18203\Desktop\UndertaleModTool_v0.9.2.0-Windows-SingleFile\Scripts\Resource Exporters\ExportAllCode.csx:line 49
*/