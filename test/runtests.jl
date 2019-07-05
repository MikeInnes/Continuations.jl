using Continuations, Test

k = @reset shift(k -> k)+1

@test k(1) == 2
