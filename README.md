# Continuations.jl

This is a proof-of-concept implementation of delimited continuations for Julia.

Most of the heavy lifting is done by Julia's built-in tasks (which are one-shot continuations) and [Libtask.jl](https://github.com/TuringLang/Libtask.jl), which enables task copying. Continuations.jl aims at providing a convenient interface to this for uses like backtracking.

```julia
julia> using Continuations

julia> k = @reset shift(k -> k)+1

julia> k(1)
2

julia> @reset shift(k -> k(1))+1
2

julia> @reset(2*shift(k -> k(4)))
8

julia> @reset(2*shift(k -> k(k(4))))
16

julia> @reset begin
         for i = 1:5
           _ = shift(k -> (i,k(nothing)))
         end
         ()
       end
(1, (2, (3, (4, (5, ())))))

julia> quantum_predicate(x) = shift(k -> (k(true), k(false)))

julia> function foo(x)
         quantum_predicate(x) && (x = x .+ 2)
         2 .* x
       end

julia> @reset(foo([1,2,3]))
([6, 8, 10], [2, 4, 6])
```

As an example, we can easily implement the [backtracking `amb` operator](examples/amb.jl):

```julia
julia> ambrun() do
         x = amb([1, 2, 3])
         y = amb([1, 2, 3])
         require(x^2 + y == 7)
         (x, y)
       end
(2, 3)

julia> ambrun() do
         N = 20
         i = amb(1:N)
         j = amb(i:N)
         k = amb(j:N)
         require(i*i + j*j == k*k)
         (i, j, k)
       end
(3, 4, 5)
```

Note that exception handling support is currently limited. Libtask.jl currently crashes on Julia 1.2-rc, so you'll want to use 1.1 or 1.0.
