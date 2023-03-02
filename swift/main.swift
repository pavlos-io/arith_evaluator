enum Token {
    case unknwown(String), number(String), 
    openParen, closeParen, plus,
    minus, mult, div

    var val: String? {
        switch self {
            case .number(let s), .unknwown(let s):
                return s
            default:
                return nil
        }
    }
}

indirect enum Expr {
    case num(Int)
    case add(Expr, Expr)
    case subtract(Expr, Expr)
    case multiply(Expr, Expr)

    var val: Int {
        switch self {
            case let .num(n):
                return n
            case let .add(lhs, rhs):
                return lhs.val + rhs.val
            case let .subtract(lhs, rhs):
                return lhs.val - rhs.val
            case let .multiply(lhs, rhs):
                return lhs.val * rhs.val
        }
    }
}

// Lexer
func tokenize(expr: String) -> [Token] {
    var i = 0
    let chars = Array(expr)
    var tokens: [Token] = []

    while(i < chars.count) {
        var tok: Token
        
        switch chars[i] {
        case _ where chars[i].isNumber:
            var num = ""
            while (i < chars.count && chars[i].isNumber) {
                num.append(chars[i])
                i += 1
            }
            tok = Token.number(num)
            i -= 1
        case "+": tok = Token.plus
        case "-": tok = Token.minus
        case "*": tok = Token.mult
        case "/": tok = Token.div
        case "(": tok = Token.openParen
        case ")": tok = Token.closeParen
        default:  tok = Token.unknwown(String(chars[i]))
        }
        
        tokens.append(tok)
        i += 1
    }

    return tokens
}

// Parser
typealias TokenIdx = Int

func parse_primary(_ tokens: [Token], _ idx: TokenIdx) -> (Expr, TokenIdx) {
    if case .openParen = tokens[idx] {
        return parse(tokens, idx + 1)
    }
    return (Expr.num(Int(tokens[idx].val!)!), idx + 1)
}

func parse(_ tokens: [Token], _ idx: TokenIdx = 0) -> (Expr, TokenIdx) {
    let (lhs, idx) = parse_primary(tokens, idx)
    
    guard idx < tokens.count else {
        return (lhs, idx)
    }

    let op: Token = tokens[idx]

    if case .closeParen = op {
        return (lhs, idx + 1)
    }
    
    let (rhs, next_idx) = parse(tokens, idx + 1)
    
    switch op {
        case .plus:
            return (Expr.add(lhs, rhs), next_idx)
        case .minus:
            return (Expr.subtract(lhs, rhs), next_idx)
        case .mult:
            return (Expr.multiply(lhs, rhs), next_idx)
        
        default:
            return (Expr.num(-100), -1)
    }
}

func main() {
    // let tokens = tokenize(expr: "(10+1)*234")
    let tokens = tokenize(expr: "1+2*3+4")

    let (ast, _) = parse(tokens)
    print(ast, "\n", ast.val)
}

main()