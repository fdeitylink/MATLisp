classdef Scanner < handle
  properties
    Input
    Start
    Curr
    Tokens
  end

  methods (Static)
    function res = isIdentChar(c)
      res = ischar(c) && (isstrprop(c, 'alpha') || contains("!#$%&*+-./:<=>?@_`~", c));
    end
  end

  methods
    function scanner = Scanner(input)
      scanner.Input = input;
      scanner.Start = 1;
      scanner.Curr = 1;
      scanner.Tokens = Token.empty;
    end

    function res = isAtEnd(scanner)
      res = scanner.Curr > strlength(scanner.Input);
    end

    function c = peek(scanner)
      if scanner.isAtEnd()
        c = sprintf('\0')
      else
        c = scanner.Input{1}(scanner.Curr);
      end
    end

    function c = advance(scanner)
      c = scanner.peek();
      scanner.Curr = scanner.Curr + 1;
    end

    function lex = lexeme(scanner)
      lex = convertCharsToStrings(scanner.Input{1}(scanner.Start:scanner.Curr - 1));
    end

    function addToken(scanner, type, literal)
      scanner.Tokens(end + 1) = Token(type, scanner.lexeme(), literal);
    end

    function skipComment(scanner)
      c = scanner.peek();
      while ~scanner.isAtEnd() && c ~= newline
        c = scanner.advance();
      end
    end

    function scanString(scanner)
      c = scanner.peek();
      while ~scanner.isAtEnd() && c ~= '"'
        scanner.advance();
        c = scanner.peek();
      end

      if scanner.isAtEnd()
        error("unterminated string literal");
      else
        scanner.advance();
        lex = scanner.lexeme();
        scanner.addToken(TokenType.String, convertCharsToStrings(lex{1}(2:end - 1)))
      end
    end

    function scanNumber(scanner)
      c = scanner.peek();
      while isstrprop(c, 'digit')
        scanner.advance();
        c = scanner.peek();
      end

      if scanner.peek() == '.'
        scanner.advance();
        c = scanner.peek();
        while isstrprop(c, 'digit')
          scanner.advance();
          c = scanner.peek();
        end
      end

      n = str2double(scanner.lexeme());
      if isnan(n)
          error("expected a number")
      else
        scanner.addToken(TokenType.Number, n);
      end
    end

    function scanIdent(scanner)
      c = scanner.peek();
      while Scanner.isIdentChar(c) || isstrprop(c, 'digit')
        scanner.advance();
        c = scanner.peek();
      end

      scanner.addToken(TokenType.Identifier, NaN);
    end

    function scanToken(scanner)
      c = scanner.advance();

      switch c
        case '('
          scanner.addToken(TokenType.OpenParen, NaN);
        case ')'
          scanner.addToken(TokenType.CloseParen, NaN);
        case ''''
          scanner.addToken(TokenType.Quote, NaN);
        case '\'
          char = scanner.advance();
          scanner.addToken(TokenType.Character, char);
        case '"'
          scanner.scanString();
        case ';'
          scanner.skipComment();
        otherwise
          if isstrprop(c, 'wspace') || c == ','
          elseif isstrprop(c, 'digit')
            scanner.scanNumber();
          elseif Scanner.isIdentChar(c)
            scanner.scanIdent();
          else
            error("unexpected character: %c", c);
          end
      end
    end
  
    function scan(scanner)
      while ~scanner.isAtEnd()
        scanner.scanToken();
        scanner.Start = scanner.Curr;
      end

      scanner.addToken(TokenType.EOF, NaN);
    end
  end
end
