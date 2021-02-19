### A Pluto.jl notebook ###
# v0.12.20

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    quote
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : missing
        el
    end
end

# ╔═╡ dbc31590-6f13-11eb-0349-15d2522d8223
using ForwardDiff

# ╔═╡ f2706810-6f13-11eb-1a39-fb262ab776a4
using Statistics

# ╔═╡ 45f9e8e4-6f14-11eb-3104-a35164c14580
using Plots

# ╔═╡ 5a591402-71a2-11eb-26d5-efb118020d5a
pyplot()

# ╔═╡ 02a441b0-719f-11eb-3f2f-b57847237856
#draw_points!(draw_all_lines!(heatmap(@. interference_pattern(X,Y)')))

# ╔═╡ 00049980-7200-11eb-1b02-f9e9b698bdc0
#draw_points!(draw_all_lines!(heatmap(angle_bounce')))

# ╔═╡ 793f1450-71f7-11eb-33c6-5be3a4f0e071
@bind slider html"<input type=range min=N/2 max=N>"

# ╔═╡ 22524b90-71b5-11eb-0513-ed423098fe7f
#heatmap(@. interference_pattern(X,Y))

# ╔═╡ 768f9410-719c-11eb-31a7-8f26a5a7ee90
N = 100;

# ╔═╡ 1017d4a2-6f14-11eb-29c6-e95b223ad504
Objy = [N*0.1, N*.9];#slider

# ╔═╡ 10044e00-6f14-11eb-2dcc-439b1f24a301
Objx = [N*0.8,N*.9];

# ╔═╡ 0b8abeae-71ba-11eb-012f-6dd661870132


# ╔═╡ 1018c09c-6f14-11eb-0e0e-a5e9a11b79f1
lambda = 50;

# ╔═╡ eaf9a5d2-71b9-11eb-1ec0-5f0409b2a48e
function euclidean_distance(x1,y1,x2,y2)
	d = sqrt((x1-x2)^2 + (y1-y2)^2)
	return d
end

# ╔═╡ 17c91310-71f2-11eb-2cee-115b81d62168
function nonlinearity_light(input)
	slope = 100;
	threshold = 0; 
	output = @. (input-threshold/slope)/(1+exp(-slope*(input-threshold)))
	return output
end

# ╔═╡ 8d96f660-7216-11eb-0390-955faee9d4ed
function nonlinearity_film(input)
	slope = 1000;
	threshold = 0; 
	output = @. 1/(1+exp(-slope*(input-threshold)))#@. log(exp(1), 1+exp(input))
	return output
end

# ╔═╡ e95f29b0-71fb-11eb-1bab-2d693bf71a5e
plot!(plot(nonlinearity_film,-1,1),nonlinearity_light, -1,1)

# ╔═╡ 3823f562-7221-11eb-294e-254c9aa608b7


# ╔═╡ 99073020-71b0-11eb-27b3-4b7ddb9f9836
exposure_time = 3*lambda

# ╔═╡ fa1cd700-71b7-11eb-04ab-a36efb76de3d
#heatmap(angle_to_ref')

# ╔═╡ 62f48e90-721b-11eb-024d-e39cfb189a8e


# ╔═╡ ec621c02-71a4-11eb-1483-35390f4d872e
xids = convert(Int64, round(.5*N, digits=0)):convert(Int64, round(.1*N, digits=0)):convert(Int64, round(.6*N, digits=0))

# ╔═╡ 02919f40-71fb-11eb-1099-bbbe0d381afb
yids = 1:1:N

# ╔═╡ 0fcbc86e-6f14-11eb-1321-23815a2b8bd4
XY = [(i, j) for i = 1:N, j = 1:N];

# ╔═╡ 0fcc0a56-6f14-11eb-2cfe-1dbbad04c195
X = float.(first.(XY)); 

# ╔═╡ 0fccd48c-6f14-11eb-03e5-2f80509be7eb
Y = float.((x -> x[2]).(XY));

# ╔═╡ 0fe13ca8-6f14-11eb-0e61-1b30e672c399
Refx = N*0.01;

# ╔═╡ 0ff2d2a6-6f14-11eb-3f6d-5b8c7529b543
Refy = N*0.5;

# ╔═╡ 114a5300-71f2-11eb-2990-7f8e1fb76709
dist_obj_to_ref = @. euclidean_distance(Objx,Objy,Refx,Refy)

# ╔═╡ f2877870-6f13-11eb-0979-2b081d3374c5
function interference_pattern(x, y)
	dist_ref_to_xy = euclidean_distance(x,y,Refx,Refy)
	dist_obj_to_xy = @. euclidean_distance(x,y,Objx,Objy)
	tot = 0
	for ti = 1:exposure_time
		from_Ref = sin(2*pi*ti/lambda - dist_ref_to_xy*2*pi/lambda);
		from_Obj = @. sin(2*pi*ti/lambda - (dist_obj_to_xy+dist_obj_to_ref)*2*pi/lambda);
		from_Ref = nonlinearity_light(from_Ref); 
		from_Obj = nonlinearity_light(from_Obj);
		from_all = mean(from_Obj) + from_Ref;
		tot += (from_all).^2;
	end
	tot / exposure_time;
end

# ╔═╡ 23690f90-71b1-11eb-08bd-717befedca10
function exposed_film(x,y)
	f = nonlinearity_film(interference_pattern(x,y));
	return f
end

# ╔═╡ 683648f0-71a6-11eb-33a4-5b4e20bde543
function xderiv(x,y)
	fx = x -> interference_pattern(x,y)
	xx = ForwardDiff.derivative(fx, x)
	return xx
end

# ╔═╡ 190e8070-71a7-11eb-23e1-aff3e245e798
function yderiv(x,y)
	fy = y -> interference_pattern(x, y)
	yy = ForwardDiff.derivative(fy, y)
	return yy
end

# ╔═╡ f1adace0-719c-11eb-3e32-21e76adffd1a
mirror_angle = @. angle(xderiv(X,Y) + im.*yderiv(X,Y));

# ╔═╡ beed4202-71a3-11eb-1036-6b15fbede333
angle_to_ref = @. angle(Refx-X + im*(Refy-Y));

# ╔═╡ a4ac65e0-71f5-11eb-1c64-df5c124606f3
function draw_lines_ref!(plt,xids,yids)
	thres = .9
	for i in xids
		for j in yids
			if exposed_film(i,j)>=thres
				fxline = x -> (x-i)*tan(angle_to_ref[i,j]) + j;
				plot!(plt,fxline,Refx,i; label=false, color=:white, alpha=0.3, xlims=[0,N], ylims=[0,N])
			end
		end
	end
	return plt
end

# ╔═╡ 7a541c82-71a4-11eb-196f-4f800ef78d2a
angle_bounce = @. exposed_film(X,Y)*(mod(2*mirror_angle-angle_to_ref+pi,2*pi)-pi);

# ╔═╡ 24760c60-71a9-11eb-0a93-a33521a183b4
function draw_lines_bounce!(plt,xids,yids)
	thres = .9
	for i in xids
		for j in yids
			if exposed_film(i,j)>=thres
				fxline = x -> (x-i)*tan(angle_bounce[i,j]) + j;
				plot!(plt,fxline,i,N; label=false, color=:white, alpha=0.3, xlims=[0,N], ylims=[0,N])
			end
		end
	end
	return plt
end

# ╔═╡ fe8b2470-71f5-11eb-0272-c11c0db72115
function draw_all_lines!(plt)
	draw_lines_bounce!(draw_lines_ref!(plt,xids,yids),xids,yids)
	return(plt)
end

# ╔═╡ d4176030-721a-11eb-0cd0-0f63f3387541
heatmap(angle_bounce')

# ╔═╡ ee9c7010-71ae-11eb-37ad-e345c1cecf9c
function draw_points!(plt)
	scatter!(plt, [Refx],[Refy];label=false)
	scatter!(plt, Objx,Objy;label=false)
	return plt
end

# ╔═╡ 3bad7110-71af-11eb-0177-b3cf7c9241de
#draw_points!(plot())

# ╔═╡ d3e29b56-6f14-11eb-08c0-3f78bc6577f9


# ╔═╡ ec95a0c6-6f14-11eb-15fc-f320f1e13a26


# ╔═╡ Cell order:
# ╠═dbc31590-6f13-11eb-0349-15d2522d8223
# ╠═f2706810-6f13-11eb-1a39-fb262ab776a4
# ╠═45f9e8e4-6f14-11eb-3104-a35164c14580
# ╠═5a591402-71a2-11eb-26d5-efb118020d5a
# ╠═02a441b0-719f-11eb-3f2f-b57847237856
# ╠═00049980-7200-11eb-1b02-f9e9b698bdc0
# ╠═fe8b2470-71f5-11eb-0272-c11c0db72115
# ╠═1017d4a2-6f14-11eb-29c6-e95b223ad504
# ╠═10044e00-6f14-11eb-2dcc-439b1f24a301
# ╠═793f1450-71f7-11eb-33c6-5be3a4f0e071
# ╠═24760c60-71a9-11eb-0a93-a33521a183b4
# ╠═a4ac65e0-71f5-11eb-1c64-df5c124606f3
# ╠═22524b90-71b5-11eb-0513-ed423098fe7f
# ╠═768f9410-719c-11eb-31a7-8f26a5a7ee90
# ╟─0b8abeae-71ba-11eb-012f-6dd661870132
# ╠═1018c09c-6f14-11eb-0e0e-a5e9a11b79f1
# ╠═eaf9a5d2-71b9-11eb-1ec0-5f0409b2a48e
# ╠═114a5300-71f2-11eb-2990-7f8e1fb76709
# ╠═17c91310-71f2-11eb-2cee-115b81d62168
# ╠═8d96f660-7216-11eb-0390-955faee9d4ed
# ╠═e95f29b0-71fb-11eb-1bab-2d693bf71a5e
# ╠═f2877870-6f13-11eb-0979-2b081d3374c5
# ╠═23690f90-71b1-11eb-08bd-717befedca10
# ╠═3823f562-7221-11eb-294e-254c9aa608b7
# ╠═99073020-71b0-11eb-27b3-4b7ddb9f9836
# ╠═d4176030-721a-11eb-0cd0-0f63f3387541
# ╠═683648f0-71a6-11eb-33a4-5b4e20bde543
# ╠═190e8070-71a7-11eb-23e1-aff3e245e798
# ╠═fa1cd700-71b7-11eb-04ab-a36efb76de3d
# ╠═f1adace0-719c-11eb-3e32-21e76adffd1a
# ╠═62f48e90-721b-11eb-024d-e39cfb189a8e
# ╠═beed4202-71a3-11eb-1036-6b15fbede333
# ╠═7a541c82-71a4-11eb-196f-4f800ef78d2a
# ╠═ec621c02-71a4-11eb-1483-35390f4d872e
# ╠═02919f40-71fb-11eb-1099-bbbe0d381afb
# ╠═0fcbc86e-6f14-11eb-1321-23815a2b8bd4
# ╠═0fcc0a56-6f14-11eb-2cfe-1dbbad04c195
# ╠═0fccd48c-6f14-11eb-03e5-2f80509be7eb
# ╠═0fe13ca8-6f14-11eb-0e61-1b30e672c399
# ╠═0ff2d2a6-6f14-11eb-3f6d-5b8c7529b543
# ╠═ee9c7010-71ae-11eb-37ad-e345c1cecf9c
# ╠═3bad7110-71af-11eb-0177-b3cf7c9241de
# ╟─d3e29b56-6f14-11eb-08c0-3f78bc6577f9
# ╟─ec95a0c6-6f14-11eb-15fc-f320f1e13a26
