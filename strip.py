


def filter_chars(s):
    allowed_chars = "<>+-[]."
    filtered_str = ""
    for c in s:
        if c in allowed_chars:
            filtered_str += c
    return filtered_str

print(filter_chars("++++++++++ [->+++>+++++++>++++++++++>+++++++++++>++++++++++++ <<<<<]>> +++ .< ++ .>>> ++ .< +++++  .> ++++ .> + .<<<< .>>> .< - .--- .<< .>> + .> ----- ..--- .<<< + ."))


print(filter_chars("++ > +++++  Cell c1 = 5[        Start your loops with your cell pointer on the loop counter (c1 in our case)< +      Add 1 to c0> -      Subtract 1 from c1]++++ ++++  c1 = 8 and this will be our loop counter again[< +++ +++  Add 6 to c0> -        Subtract 1 from c1]< .        Print out c0 which has the value 55 which translates to 7"))