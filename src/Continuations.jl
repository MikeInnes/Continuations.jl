module Continuations

using Libtask

export shift, @reset

function reset(f)
  c = current_task()
  t = Task() do
    task_local_storage(:reset, c)
    y = f()
    yieldto(task_local_storage(:reset), y)
  end
  yieldto(t)
end

macro reset(ex)
  :(reset(() -> $(esc(ex))))
end

function shift(f)
  c = current_task()
  r = task_local_storage(:reset)
  t = Task() do
    yieldto(r, f(x -> yieldto(copy(c), (x, current_task()))))
  end
  y, ret = yieldto(t)
  task_local_storage(:reset, ret)
  return y
end

end # module
