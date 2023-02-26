classdef Evaluator
    methods(Static)
    function res = truthy(ast, env)
      res = ast ~= Symbol("nil") && ast ~= NaN;
    end

    function ast = evalAST(ast, env)
      if strcmp(class(ast), 'Symbol') && ast ~= Symbol("t") && ast ~= Symbol("nil")
        ast = env.get(ast);
      elseif strcmp(class(ast), 'cell')
        list = {};
        for i = 1:length(ast)
          list{end + 1} = Evaluator.eval(ast{i}, env);
        end
        ast = list;
      end
    end

    function ast = def(ast, env)

    end

    function ast = let(ast, env)
      if length(ast) ~= 3
        error("let requires bindings and body");
      else
        bindings = ast{2};
        body = ast{3};

        if mod(length(bindings), 2) ~= 0
          error("bindings list must have even length");
        else
          env2 = Environment();
          env2.Parent = env;
          for i=1:2:length(bindings)
            value = Evaluator.eval(bindings{i + 1}, env);
            env2.set(bindings{i}, value);
          end

          ast = Evaluator.eval(body, env2);
        end
      end
    end

    function ast = do(ast, env)
      for i = 2:length(ast)
        res = Evaluator.eval(ast{i}, env);
      end
      ast = res;
    end

    function ast = if0(ast, env)
      if length(ast) ~= 3 && length(ast) ~= 4
        error("if requires test, then, and optional else expression");
      else
        test = ast{2};
        then = ast{3};

        if Evaluator.truthy(Evaluator.eval(test), env)
          ast = Evaluator.eval(then, env);
        elseif length(ast) == 4
          els = ast{4};
          ast = Evaluator.eval(els, env);
        else
          ast = NaN;
        end
      end
    end

    function ast = fn(ast, env)

    end

    function ast = quote(ast, env)
      if length(ast) ~= 2
        error("quote requires exactly one argument");
      else
        ast = ast{2};
      end
    end

    function ast = defmacro(ast, env)

    end

    function ast = macroexpand(ast, env)

    end

    function ast = eval(ast, env)
      if ~strcmp(class(ast), 'cell')
        ast = Evaluator.evalAST(ast, env);
      elseif length(ast) == 0
      else
        ast = Evaluator.macroexpand(ast, env);
        if strcmp(class(ast{1}), 'Symbol')
          switch ast{1}
            case Symbol("def")
              ast = Evaluator.def(ast, env);
            case Symbol("let")
              ast = Evaluator.let(ast, env);
            case Symbol("do")
              ast = Evaluator.do(ast, env);
            case Symbol("if")
              ast = Evaluator.if0(ast, env);
            case Symbol("fn")
              ast = Evaluator.fn(ast, env);
            case Symbol("quote")
              ast = Evaluator.quote(ast, env);
            case Symbol("defmacro")
              ast = Evaluator.defmacro(ast, env);
            case Symbol("macroexpand")
              ast = Evaluator.macroexpand(ast, env);
            otherwise
          end
        else

        end
      end
    end
  end
end
