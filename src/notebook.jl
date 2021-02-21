### A Pluto.jl notebook ###
# v0.12.21

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

# ╔═╡ 0ade04b0-724e-11eb-2174-bb66b019de00
using PlutoUI

# ╔═╡ 88617f5e-723b-11eb-31b3-8b338783405a
md"# Hologram simulation"

# ╔═╡ ae4cae70-723b-11eb-162d-7dce1c0181de
md"## Parameters and basic variables"

# ╔═╡ 67402640-72b0-11eb-2488-2d9c4e3c5cea
@bind draw_dims html"""
<canvas width="100" height="100" style="position: relative"></canvas>

<script>
// 🐸 `currentScript` is the current script tag - we use it to select elements 🐸 //
const canvas = currentScript.closest('pluto-output').querySelector("canvas")
const ctx = canvas.getContext("2d")

var startX = 40
var startY = 20

function onmove(e){
	// 🐸 We send the value back to Julia 🐸 //
	canvas.value = [startX, e.layerX, startY, e.layerY] //e.layerX - startX, e.layerY - startY]
	canvas.dispatchEvent(new CustomEvent("input"))

	ctx.fillStyle = '#ffecec'
	ctx.fillRect(0, 0, 100, 100)
	ctx.fillStyle = '#3f3d6d'
	ctx.fillRect(startX, startY, ...[e.layerX - startX, e.layerY - startY])
}

canvas.onmousedown = e => {
	startX = e.layerX
	startY = e.layerY
	canvas.onmousemove = onmove
}

canvas.onmouseup = e => {
	canvas.onmousemove = null
}

// Fire a fake mousemoveevent to show something
onmove({layerX: 30, layerY: 60})

</script>
"""

# ╔═╡ dc30ac40-72b0-11eb-04cc-7d8f12718937
begin
	dims = draw_dims
	xdims = sort(dims[1:2]);
	ydims = sort(dims[3:4]); 
	dims[1] = xdims[1];
	dims[2] = xdims[2];
	dims[3] = 100-ydims[2];
	dims[4] = 100-ydims[1];
	dims
end

# ╔═╡ 768f9410-719c-11eb-31a7-8f26a5a7ee90
N = 100;

# ╔═╡ 1018c09c-6f14-11eb-0e0e-a5e9a11b79f1
lambda = 15;

# ╔═╡ 69cdb220-72b4-11eb-11b2-af93cd66d67a
sort(draw_dims)

# ╔═╡ 793f1450-71f7-11eb-33c6-5be3a4f0e071
@bind slider_objy Slider(1:N, default=.9*N)

# ╔═╡ 1017d4a2-6f14-11eb-29c6-e95b223ad504
Objy = slider_objy

# ╔═╡ 36076dce-72ac-11eb-2918-81b4f7f67bc7
@bind slider_objx Slider(1:N, default=.9*N)

# ╔═╡ 10044e00-6f14-11eb-2dcc-439b1f24a301
Objx = slider_objx

# ╔═╡ 004c1840-724c-11eb-2028-13dfb3eb82b0
@bind slider_obj2x Slider(1:N, default=.8*N)

# ╔═╡ be0879e0-72ac-11eb-30f8-2b111e90b758
Obj2x = slider_obj2x

# ╔═╡ 36e17bc0-724c-11eb-3dae-c38f863452b6
@bind slider_obj2y Slider(1:N, default=.1*N)

# ╔═╡ e82d0ce0-72ac-11eb-085c-39c65cb6879f
Obj2y = slider_obj2y

# ╔═╡ 0fe13ca8-6f14-11eb-0e61-1b30e672c399
Refx = N*0.01

# ╔═╡ 7d40d5a2-73e8-11eb-3fe2-3dea35e723d2
all_obj_x = [Refx Obj2x Objx 10 5]

# ╔═╡ 0ff2d2a6-6f14-11eb-3f6d-5b8c7529b543
Refy = N*0.5

# ╔═╡ 8e614b80-73e8-11eb-22d6-9fe17ad381e9
all_obj_y = [Refy Obj2y Objy 90 70]

# ╔═╡ 99073020-71b0-11eb-27b3-4b7ddb9f9836
exposure_time = 10*lambda

# ╔═╡ ec621c02-71a4-11eb-1483-35390f4d872e
xids = dims[1]:dims[2]

# ╔═╡ 02919f40-71fb-11eb-1099-bbbe0d381afb
yids = dims[3]:dims[4]

# ╔═╡ 0fcbc86e-6f14-11eb-1321-23815a2b8bd4
XY = [(i, j) for i = 1:N, j = 1:N];

# ╔═╡ 0fcc0a56-6f14-11eb-2cfe-1dbbad04c195
X = float.(first.(XY)); 

# ╔═╡ 0fccd48c-6f14-11eb-03e5-2f80509be7eb
Y = float.((x -> x[2]).(XY));

# ╔═╡ e7be7df0-723b-11eb-135a-cfc35c7c47a5
md"## Trigonometric functions"

# ╔═╡ eaf9a5d2-71b9-11eb-1ec0-5f0409b2a48e
function euclidean_distance(x1,y1,x2,y2)
	d = sqrt((x1-x2)^2 + (y1-y2)^2)
	return d
end

# ╔═╡ 8d96f660-7216-11eb-0390-955faee9d4ed
function nonlinearity_film(input)
	slope = 1000;
	threshold = 1.95; 
	output = (tanh(slope*(input-threshold))+1)/2
	return output
end

# ╔═╡ f7c4d79e-7243-11eb-2140-438d9e685896
function interference_pattern(x, y,Refx,Refy,Objx,Objy)
	R = euclidean_distance(x,y,Refx,Refy)
	J = euclidean_distance(x,y,Objx,Objy)
	# integral of: (sin(2*pi*t/lambda-2*pi*R/lambda)+sin(2*pi*t/lambda-2*pi*J/lambda))^2
	integral_from_wolfram = t -> (cos(pi*(J-R)/lambda).^2)*(2*t + lambda/(2*pi)*sin((2*pi/lambda)*(J+R-2*t)))
	tot = integral_from_wolfram(exposure_time)-integral_from_wolfram(0)
	tot / exposure_time;
end

# ╔═╡ 23690f90-71b1-11eb-08bd-717befedca10
function exposed_film(x,y,Refx,Refy,Objx,Objy)
	f = nonlinearity_film(interference_pattern(x,y,Refx,Refy,Objx,Objy));
	return f
end

# ╔═╡ 683648f0-71a6-11eb-33a4-5b4e20bde543
function xderiv(x,y,Refx,Refy,Objx,Objy)
	fx = x -> interference_pattern(x,y,Refx,Refy,Objx,Objy)
	xx = ForwardDiff.derivative(fx, x)
	return xx
end

# ╔═╡ 190e8070-71a7-11eb-23e1-aff3e245e798
function yderiv(x,y,Refx,Refy,Objx,Objy)
	fy = y -> interference_pattern(x, y,Refx,Refy,Objx,Objy)
	yy = ForwardDiff.derivative(fy, y)
	return yy
end

# ╔═╡ 7a541c82-71a4-11eb-196f-4f800ef78d2a
function angle_bounce(x,y,Refx,Refy,Objx,Objy)
	vec_in = [Refx-x, Refy-y]; 
	xd = xderiv(x,y,Refx,Refy,Objx,Objy)
	yd = yderiv(x,y,Refx,Refy,Objx,Objy)
	vec_mirr = [xd,yd]/sqrt(xd^2+yd^2);
	dot = vec_in[1]*vec_mirr[1]+vec_in[2]*vec_mirr[2]; 
	vec_out = @. vec_in - 2*(dot)*vec_mirr; 
	a = exposed_film(x,y,Refx,Refy,Objx,Objy)*atan(vec_out[2], vec_out[1])
	return a
end

# ╔═╡ 16f5bdf0-73e9-11eb-0393-af94875171c8
1:1

# ╔═╡ 62268ae0-73b5-11eb-0285-bd6ee6756732
begin
	angle_full = zeros(N,N)
	for i in xids
		for j in yids
			for ob1 in 2:size(all_obj_x)[2]
				for ob2 in 1:(ob1-1)
					angle_full[i,j] = angle_full[i,j] + angle_bounce(i,j, all_obj_x[ob2],all_obj_y[ob2],all_obj_x[ob1],all_obj_y[ob1]);
				end
			end
		end
	end
end

# ╔═╡ f7722800-73e9-11eb-19c0-e9d01223797f
begin
	exposed_full = zeros(N,N)
	for i in xids
		for j in yids
			for ob1 in 2:size(all_obj_x)[2]
				for ob2 in 1:(ob1-1)
					exposed_full[i,j] = exposed_full[i,j] + exposed_film(i,j, all_obj_x[ob2],all_obj_y[ob2],all_obj_x[ob1],all_obj_y[ob1]);
				end
			end
		end
	end
end

# ╔═╡ 26e7c5e0-723c-11eb-064d-0d684391b253
md"## Visualizations"

# ╔═╡ 64d22c20-72b3-11eb-2cea-e9449721dca7
#draw_points!(draw_all_lines!(heatmap(angle_full')))

# ╔═╡ 7b0bf770-73ec-11eb-293a-b321fd7bdb3b
alpha_lines = .1; 

# ╔═╡ 24760c60-71a9-11eb-0a93-a33521a183b4
function draw_lines_bounce!(plt,xids,yids)
	thres = .9
	for i in xids
		for j in yids
			if exposed_full[i,j]>=thres
				fxline = x -> (x-i)*tan(angle_full[i,j]) + j;
				plot!(plt,fxline,1,N; label=false, color=:white, alpha=alpha_lines, xlims=[0,N], ylims=[0,N])
			end
		end
	end
	return plt
end

# ╔═╡ a4ac65e0-71f5-11eb-1c64-df5c124606f3
function draw_lines_ref!(plt,xids,yids)
	thres = .9
	for i in xids
		for j in yids
			if exposed_full[i,j]>=thres
				fxline = x -> (x-i)*(Refy-j)/(Refx-i) + j;
				plot!(plt,fxline,Refx,i; label=false, color=:white, alpha=alpha_lines, xlims=[0,N], ylims=[0,N])
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

# ╔═╡ ee9c7010-71ae-11eb-37ad-e345c1cecf9c
function draw_points!(plt)
	scatter!(plt, all_obj_x,all_obj_y;label=false, markeralpha=0, markerstrokealpha=1, markersize=10, markerstrokecolor=:gray)
	return plt
end

# ╔═╡ 00049980-7200-11eb-1b02-f9e9b698bdc0
draw_points!(draw_all_lines!(heatmap(@. mod(angle_full',2*pi))))

# ╔═╡ e95f29b0-71fb-11eb-1bab-2d693bf71a5e
plot(nonlinearity_film,-1,2)

# ╔═╡ 3823f562-7221-11eb-294e-254c9aa608b7
#heatmap(@. interference_pattern(X,Y,Refx,Refy,Objx,Objy)')

# ╔═╡ d4176030-721a-11eb-0cd0-0f63f3387541
#heatmap(angle_bounce')

# ╔═╡ 9c416360-723b-11eb-2cb3-216d0e5d9f58
md"## Setting up packages"

# ╔═╡ 0e8c8dc0-724e-11eb-1df1-275b15dd6de2
import Pkg; Pkg.add("PlutoUI")

# ╔═╡ 13a6b4c0-724e-11eb-200b-4f794ccff8f2


# ╔═╡ 5a591402-71a2-11eb-26d5-efb118020d5a
pyplot();

# ╔═╡ Cell order:
# ╟─88617f5e-723b-11eb-31b3-8b338783405a
# ╠═00049980-7200-11eb-1b02-f9e9b698bdc0
# ╟─ae4cae70-723b-11eb-162d-7dce1c0181de
# ╟─67402640-72b0-11eb-2488-2d9c4e3c5cea
# ╟─dc30ac40-72b0-11eb-04cc-7d8f12718937
# ╠═768f9410-719c-11eb-31a7-8f26a5a7ee90
# ╠═1018c09c-6f14-11eb-0e0e-a5e9a11b79f1
# ╠═69cdb220-72b4-11eb-11b2-af93cd66d67a
# ╠═7d40d5a2-73e8-11eb-3fe2-3dea35e723d2
# ╠═8e614b80-73e8-11eb-22d6-9fe17ad381e9
# ╟─1017d4a2-6f14-11eb-29c6-e95b223ad504
# ╟─793f1450-71f7-11eb-33c6-5be3a4f0e071
# ╟─10044e00-6f14-11eb-2dcc-439b1f24a301
# ╟─36076dce-72ac-11eb-2918-81b4f7f67bc7
# ╟─be0879e0-72ac-11eb-30f8-2b111e90b758
# ╟─004c1840-724c-11eb-2028-13dfb3eb82b0
# ╟─e82d0ce0-72ac-11eb-085c-39c65cb6879f
# ╟─36e17bc0-724c-11eb-3dae-c38f863452b6
# ╟─0fe13ca8-6f14-11eb-0e61-1b30e672c399
# ╟─0ff2d2a6-6f14-11eb-3f6d-5b8c7529b543
# ╟─99073020-71b0-11eb-27b3-4b7ddb9f9836
# ╠═ec621c02-71a4-11eb-1483-35390f4d872e
# ╠═02919f40-71fb-11eb-1099-bbbe0d381afb
# ╠═0fcbc86e-6f14-11eb-1321-23815a2b8bd4
# ╠═0fcc0a56-6f14-11eb-2cfe-1dbbad04c195
# ╠═0fccd48c-6f14-11eb-03e5-2f80509be7eb
# ╟─e7be7df0-723b-11eb-135a-cfc35c7c47a5
# ╠═eaf9a5d2-71b9-11eb-1ec0-5f0409b2a48e
# ╠═8d96f660-7216-11eb-0390-955faee9d4ed
# ╠═f7c4d79e-7243-11eb-2140-438d9e685896
# ╠═23690f90-71b1-11eb-08bd-717befedca10
# ╠═683648f0-71a6-11eb-33a4-5b4e20bde543
# ╠═190e8070-71a7-11eb-23e1-aff3e245e798
# ╠═7a541c82-71a4-11eb-196f-4f800ef78d2a
# ╠═16f5bdf0-73e9-11eb-0393-af94875171c8
# ╠═62268ae0-73b5-11eb-0285-bd6ee6756732
# ╠═f7722800-73e9-11eb-19c0-e9d01223797f
# ╟─26e7c5e0-723c-11eb-064d-0d684391b253
# ╠═64d22c20-72b3-11eb-2cea-e9449721dca7
# ╠═fe8b2470-71f5-11eb-0272-c11c0db72115
# ╠═7b0bf770-73ec-11eb-293a-b321fd7bdb3b
# ╠═24760c60-71a9-11eb-0a93-a33521a183b4
# ╠═a4ac65e0-71f5-11eb-1c64-df5c124606f3
# ╠═ee9c7010-71ae-11eb-37ad-e345c1cecf9c
# ╠═e95f29b0-71fb-11eb-1bab-2d693bf71a5e
# ╠═3823f562-7221-11eb-294e-254c9aa608b7
# ╠═d4176030-721a-11eb-0cd0-0f63f3387541
# ╟─9c416360-723b-11eb-2cb3-216d0e5d9f58
# ╠═dbc31590-6f13-11eb-0349-15d2522d8223
# ╠═f2706810-6f13-11eb-1a39-fb262ab776a4
# ╠═45f9e8e4-6f14-11eb-3104-a35164c14580
# ╠═0ade04b0-724e-11eb-2174-bb66b019de00
# ╠═0e8c8dc0-724e-11eb-1df1-275b15dd6de2
# ╠═13a6b4c0-724e-11eb-200b-4f794ccff8f2
# ╠═5a591402-71a2-11eb-26d5-efb118020d5a
