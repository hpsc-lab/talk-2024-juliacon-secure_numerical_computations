struct Semidiscretization1D
    x_span::Tuple
    nodes::Vector
    dx::Float64
    size::Int
    function Semidiscretization1D(x_span::Tuple, N::Int)
        nodes = Vector{Float64}(undef, N)
        nodes[1] = x_span[1]
        dx = (x_span[2]-x_span[1])/N
        for i in range(1, N-1)
            nodes[i+1] = nodes[i] + dx
        end
        new(x_span, nodes, dx, N)
    end
end

struct Semidiscretization2D
    x_span::Tuple
    y_span::Tuple
    nodes_x::Vector
    nodes_y::Vector
    dx::Float64
    dy::Float64
    size_x::Int
    size_y::Int
    function Semidiscretization2D(x_span::Tuple, y_span::Tuple, N_x::Int, N_y::Int)
        nodes_x = Vector{Float64}(undef, N_x)
        nodes_y = Vector{Float64}(undef, N_y)
        nodes_x[1] = x_span[1]
        nodes_x[N_x] = x_span[2]
        nodes_y[1] = y_span[1]
        nodes_y[N_y] = y_span[2]
        dx = (x_span[2]-x_span[1])/N_x
        dy = (y_span[2]-y_span[1])/N_y
        for i in range(1, N_x-1)
            nodes_x[i+1] = nodes_x[i] + dx
        end
        for i in range(1, N_y-1)
            nodes_y[i+1] = nodes_y[i] + dy
        end
        new(x_span, y_span, nodes_x, nodes_y, dx, dy, N_x, N_y)
    end
end