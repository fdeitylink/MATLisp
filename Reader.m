classdef Reader < handle
  properties
    Tokens
    Start
    Curr
  end

  methods
    function reader = Reader(tokens)
      reader.Tokens = tokens;
      reader.Start = 1;
      reader.Curr = 1;
    end

    function res = isAtEnd(reader)
      res = reader.Curr > length(reader.Tokens);
    end

    function tok = peek(reader)
      tok = reader.Tokens(reader.Curr);
    end

    function tok = advance(reader)
      tok = reader.peek();
      reader.Curr = reader.Curr + 1;
    end

    function ast = list(reader)
      list = {};

      reader.advance();
      tok = reader.peek();

      while tok.Type ~= TokenType.CloseParen
        if tok.Type == TokenType.EOF
          error("unterminated list");
        else
          list{end + 1} = reader.form();
          tok = reader.peek();
        end
      end

      reader.advance();
      ast = list;
    end

    function ast = atom(reader)
      tok = reader.advance();

      switch tok.Type
        case TokenType.Number
          ast = tok.Literal;
        case TokenType.Character
          ast = tok.Literal;
        case TokenType.String
          ast = tok.Literal;
        case TokenType.Identifier
          ast = Symbol(tok.Lexeme{1});
        case TokenType.Nil
          ast = NaN;
        case TokenType.True
          ast = true;
        case TokenType.False
          ast = false;
      end
    end

    function ast = form(reader)
      tok = reader.peek();

      switch tok.Type
        case TokenType.EOF
          error("reached end of input");
        case TokenType.OpenParen
          ast = reader.list();
        case TokenType.Quote
          reader.advance();
          ast = {Symbol("quote") reader.form()};
        otherwise
          ast = reader.atom();
      end
    end
  end
end
