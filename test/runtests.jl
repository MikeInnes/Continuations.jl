using Continuations, Test

k = @reset shift(k -> k)+1

@test k(1) == 2
@test k(1) == 2

@test @reset(2*shift(k -> k(4))) == 8
@test @reset(2*shift(k -> k(k(4)))) == 16

@test @reset(begin
  for i = 1:5
    _ = shift(k -> (i,k(nothing)))
  end
  ()
end) == (1, (2, (3, (4, (5, ())))))

quantum_predicate(x) = shift(k -> (k(true), k(false)))

function foo(x)
  quantum_predicate(x) && (x = x .+ 2)
  2 .* x
end

@test @reset(foo([1,2,3])) == ([6, 8, 10], [2, 4, 6])
