### A Pluto.jl notebook ###
# v0.12.20

using Markdown
using InteractiveUtils

# ╔═╡ dbc31590-6f13-11eb-0349-15d2522d8223
using ForwardDiff

# ╔═╡ f1f42a98-6f13-11eb-0623-196ac709c1ac
using UnicodePlots

# ╔═╡ f2706810-6f13-11eb-1a39-fb262ab776a4
using Statistics

# ╔═╡ 45f9e8e4-6f14-11eb-3104-a35164c14580
using Plots

# ╔═╡ f2772496-6f13-11eb-1df1-cbda05cf368d
# [X,Y] = meshgrid(1:N,1:N);
iscomplex(x) = x isa Complex

# ╔═╡ f28609c2-6f13-11eb-10be-3b85fa4d55db
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

# ╔═╡ f2877870-6f13-11eb-0979-2b081d3374c5
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

# ╔═╡ f840c578-6f13-11eb-39b0-e574ae0273c4
N = 200

# ╔═╡ 0fcbc86e-6f14-11eb-1321-23815a2b8bd4
XY = [(i, j) for i = 1:N, j = 1:N]

# ╔═╡ 0fcc0a56-6f14-11eb-2cfe-1dbbad04c195
X = float.(first.(XY))

# ╔═╡ 0fccd48c-6f14-11eb-03e5-2f80509be7eb
Y = float.((x -> x[2]).(XY))

# ╔═╡ 0fe13ca8-6f14-11eb-0e61-1b30e672c399
s1x = N*0.1

# ╔═╡ 0ff2d2a6-6f14-11eb-3f6d-5b8c7529b543
s1y = N*0.5

# ╔═╡ 10044e00-6f14-11eb-2dcc-439b1f24a301
s2x = N*0.8

# ╔═╡ 1017d4a2-6f14-11eb-29c6-e95b223ad504
s2y = N*0.4

# ╔═╡ 1018c09c-6f14-11eb-0e0e-a5e9a11b79f1
lambda = 30

# ╔═╡ 22a5e636-6f14-11eb-1acc-7d08f9a7fcb8
A = f(X, Y, s1x, s1y, s2x, s2y, lambda, N)

# ╔═╡ 2b8c2da2-6f14-11eb-2863-cb62e30e6507
Plots.imshow(A)

# ╔═╡ 6e91075e-6f14-11eb-1a11-fb422cbb2750
UV = begin
	 U = zeros(N, N)
	 V = zeros(N, N)
	
	  for i = 1:N
	    for j = 1:N
	      let
	        fx = x -> @. fpw(x, Y[i, j], s1x, s1y, s2x, s2y, lambda, N)
	        fy = y -> @. fpw(X[i, j], y, s1x, s1y, s2x, s2y, lambda, N)
	        xx = ForwardDiff.derivative(fx, X[i,j])
	        yy = ForwardDiff.derivative(fy, Y[i,j])
	        U[i, j] = xx
	        V[i, j] = yy
	      end
	    end
	  end
end

# ╔═╡ d3e29b56-6f14-11eb-08c0-3f78bc6577f9
ids = 1:3:200

# ╔═╡ ec95a0c6-6f14-11eb-15fc-f320f1e13a26
Plots.quiver(X[ids, ids][:], Y[ids, ids][:], quiver=(5 .* U[ids, ids][:], 5 .* V[ids, ids][:]))

# ╔═╡ Cell order:
# ╠═dbc31590-6f13-11eb-0349-15d2522d8223
# ╠═f1f42a98-6f13-11eb-0623-196ac709c1ac
# ╠═f2706810-6f13-11eb-1a39-fb262ab776a4
# ╠═45f9e8e4-6f14-11eb-3104-a35164c14580
# ╠═f2772496-6f13-11eb-1df1-cbda05cf368d
# ╠═f28609c2-6f13-11eb-10be-3b85fa4d55db
# ╠═f2877870-6f13-11eb-0979-2b081d3374c5
# ╠═f840c578-6f13-11eb-39b0-e574ae0273c4
# ╠═0fcbc86e-6f14-11eb-1321-23815a2b8bd4
# ╠═0fcc0a56-6f14-11eb-2cfe-1dbbad04c195
# ╠═0fccd48c-6f14-11eb-03e5-2f80509be7eb
# ╠═0fe13ca8-6f14-11eb-0e61-1b30e672c399
# ╠═0ff2d2a6-6f14-11eb-3f6d-5b8c7529b543
# ╠═10044e00-6f14-11eb-2dcc-439b1f24a301
# ╠═1017d4a2-6f14-11eb-29c6-e95b223ad504
# ╠═1018c09c-6f14-11eb-0e0e-a5e9a11b79f1
# ╠═22a5e636-6f14-11eb-1acc-7d08f9a7fcb8
# ╠═2b8c2da2-6f14-11eb-2863-cb62e30e6507
# ╠═6e91075e-6f14-11eb-1a11-fb422cbb2750
# ╠═d3e29b56-6f14-11eb-08c0-3f78bc6577f9
# ╠═ec95a0c6-6f14-11eb-15fc-f320f1e13a26
