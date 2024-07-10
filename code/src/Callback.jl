mutable struct StandartCallback
    norm
    exact::Any
    private_key::Any
    run
    frequency::Int
    result_step
    time_step
    steps
    sample_size
    start_time
    function StandartCallback(norm, exact, private_key, run, frequency)
        new(norm, exact, private_key, run, frequency, Float64[], Float64[], Float64[], 0, 0)
    end
end