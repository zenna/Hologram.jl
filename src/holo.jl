using ForwardDiff
using UnicodePlots
using Statistics

# [X,Y] = meshgrid(1:N,1:N);
iscomplex(x) = x isa Complex

function f(X, Y, s1x, s1y, s2x, s2y, lambda, N)
   dS1 = sqrt.((X .- s1x).^2 + (Y .- s1y).^2)
   dS2 = sqrt.((X .- s2x).^2 + (Y.-s2y).^2)
  #  @show any(iscomplex.(dS1))

   Exposed = zeros(N,N,lambda)
  #  @show typeof(Exposed)
   for ti = 1:lambda
      from_s1 = @. sin(2*pi*ti/lambda - dS1*2*pi/lambda);
      from_s2 = @. sin(2*pi*ti/lambda - dS2*2*pi/lambda);
      from_all = from_s1 .+ from_s2
      Exposed[:,:,ti] .= (from_all).^2;
      # M = mean(Exposed(:,:,1:ti),3);
   end
   M = mean(Exposed[:,:,1:lambda], dims=3) 
   return M
end

function fpw(X, Y, s1x, s1y, s2x, s2y, lambda, N)
  dS1 = sqrt((X - s1x)^2 + (Y - s1y)^2)
  dS2 = sqrt((X - s2x)^2 + (Y - s2y)^2)
  tot = 0
  for ti = 1:lambda
     from_s1 = sin(2*pi*ti/lambda - dS1*2*pi/lambda);
     from_s2 = sin(2*pi*ti/lambda - dS2*2*pi/lambda);
     from_all = from_s1 + from_s2
     tot += (from_all).^2;
  end
  tot / lambda
end

function test()
  N = 200
  XY = [(i, j) for i = 1:N, j = 1:N]

  X = float.(first.(XY))
  Y = float.((x -> x[2]).(XY))

  s1x = N*0.1
  s1y = N*0.5
  s2x = N*0.8
  s2y = N*0.4
  lambda = 30

  @show f(X, Y, s1x, s1y, s2x, s2y, lambda, N)
  @show @. fpw(X, Y, s1x, s1y, s2x, s2y, lambda, N)

  U = zeros(N, N)
  V = zeros(N, N)

  for i = 1:N
    for j = 1:N
      let
        fx = x -> @. fpw(x, Y[i, j], s1x, s1y, s2x, s2y, lambda, N)
        fy = y -> @. fpw(X[i, j], y, s1x, s1y, s2x, s2y, lambda, N)
        xx = ForwardDiff.derivative(fx, X[i,j])
        yy = ForwardDiff.derivative(fy, Y[i,j])
        @show xx, yy
        U[i, j] = xx
        V[i, j] = yy
      end
    end
  end
  X, Y, U, V
  # quiver(, y, quiver=(u, v))
end