parse = require '../src/parser'
{finalState} = require '../src/evaluator'



describe 'The advanced looping behaviour', ->

  it 'handles self-assignment in loop', ->
    input = """
      x = 3;
      while x > 0 do
        x = x - 1
    """
    result = finalState(parse(input)).m
    expect(result.x).toBe 0


  it 'handles break statements', ->
    input = """
      x = 0;
      while x == 0 do {
        x = 1;
        break!;
        x = 2
      };
      y = 100
    """
    result = finalState(parse(input)).m
    expect(result.x).toBe 1
    expect(result.y).toBe 100


  it 'handles continue statements', ->
    input = """
      x = 0;
      while x < 2 do {
        x = x + 1;
        continue!;
        x = 0
      };
      y = 100
    """
    result = finalState(parse(input)).m
    expect(result.x).toBe 2
    expect(result.y).toBe 100


  it 'handles nested whiles', ->
    input = """
      n = 3; sum = 0;
      while n > 0 do {
        copy = n;
        while copy > 0 do {
          copy = copy - 1;
          sum = sum + 1
        };
        n = n -1
      }
    """
    result = finalState(parse(input)).m
    expect(result.n).toBe 0
    expect(result.sum).toBe 6


  it 'handles break in inner looop', ->
    input = """
      x = 1;
      while x < 3 do {
        x = x + 1;
        while true do break!
      }
    """
    result = finalState(parse(input)).m
    expect(result).toEqual
      x: 3
      # and no abnormal termination


  it 'handles continue in inner loop', ->
    input = """
      outer = 0;
      while outer != 5 do {
        outer = 5;
        inner = 0;
        while inner != 2 do {
          inner = inner + 1;
          continue!;
          outer = 100
        }
      }
    """
    result = finalState(parse(input)).m
    expect(result.outer).toBe 5
    expect(result.inner).toBe 2


  it 'handles break in outer loop', ->
    input = """
      x = 1;
      while true do {
        break!;
        while true do ();
        x = 2
      }
    """
    result = finalState(parse(input)).m
    expect(result).toEqual
      x: 1
      # and no abnormal termination


  it 'handles continue in outer loop', ->
    input = """
      x = 2;
      while x > 0 do {
        x = x - 1;
        continue!;
        while true do ()
      }
    """
    result = finalState(parse(input)).m
    expect(result).toEqual
      x: 0
      # and no abnormal termination


  it 'handles 3 levels of nesting', ->
    input = """
    outer = 5;
    while outer > 0 do {
      outer = outer - 1;
      inner = 2;
      while inner > 0 do {
        inner = inner - 1;
        break!;
        while true do ()
      }
    }
    """
    result = finalState(parse(input)).m
    expect(result).toEqual
      outer: 0
      inner: 1
      # and no abnormal termination



describe 'The Evaluator', ->

  it 'can compute minimum', ->
    input =   """
      a = 1;
      b = 24;

      if a < b then
        min = a
      else
        min = b
    """
    result = finalState(parse(input)).m
    expect(result).toEqual
      a: 1
      b: 24
      min: 1


  it 'can compute factorial', ->
    input =   """
      n = 5;
      fact = 1;

      while true do {
        fact = fact * n;
        n = n - 1;
        if n == 0 then break! else ()
      }
    """
    result = finalState(parse(input)).m
    expect(result).toEqual
      n: 0
      fact: 120

  it "can compute euclid's gcd", ->
      input = """
      a = 18;
      b = 30;

      while a != b do
      if a > b then
        a = a - b
      else
      b = b - a
      """
      result = finalState(parse(input)).m
      expect(result).toEqual
        a: 6
        b: 6

