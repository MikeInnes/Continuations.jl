module Continuations

using Libtask

export shift, @reset

global _reset = nothing

function reset(f)
  global _reset = current_task()
  t = Task() do
    yieldto(_reset, f())
  end
  yieldto(t)
end

macro reset(ex)
  :(reset(() -> $(esc(ex))))
end

function shift(f)
  c = current_task()
  yieldto(_reset, f(x -> yieldto(c, x)))
end

end # module
