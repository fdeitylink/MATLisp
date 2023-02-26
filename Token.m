classdef Token
  properties
    Type
    Lexeme
    Literal
  end

  methods
    function tok = Token(Type, Lexeme, Literal)
      tok.Type = Type;
      tok.Lexeme = Lexeme;
      tok.Literal = Literal;
    end
  end
end
