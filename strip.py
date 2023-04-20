


def filter_chars(s):
    allowed_chars = "<>+-[]."
    filtered_str = ""
    for c in s:
        if c in allowed_chars:
            filtered_str += c
    return filtered_str

print(filter_chars("++++++++++ [->+++>+++++++>++++++++++>+++++++++++>++++++++++++ <<<<<]>> +++ .< ++ .>>> ++ .< +++++  .> ++++ .> + .<<<< .>>> .< - .--- .<< .>> + .> ----- ..--- .<<< + ."))