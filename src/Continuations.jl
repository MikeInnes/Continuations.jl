module Continuations

using Libtask

export shift, @reset

function reset(f)
  c = current_task()
  t = Task() do
    task_local_storage(:reset, c)
    yieldto(c, f())
  end
  yieldto(t)
end

macro reset(ex)
  :(reset(() -> $(esc(ex))))
end

function shift(f)
  c = current_task()
  yieldto(task_local_storage(:reset), f(x -> yieldto(c, x)))
end

end # module
