ENABLED = true

cube_orginal_rough_mip1 = .3
cube_orginal_rough_mip2 = .5
cube_orginal_rough_mip3 = .75
cube_orginal_rough_mip4 = .85
cube_orginal_rough_mip5 = 1

dataref("sun_heading", "sim/graphics/scenery/sun_heading_degrees")
dataref("sun_angle", "sim/graphics/scenery/sun_pitch_degrees")

function onEverySecond()
    tickleCubeMaps()
    updateClouds()
end

function tickleCubeMaps()
    set("sim/private/controls/ibl/update_mode", 1)
    set("sim/private/controls/ibl/update_mode", 0)
end

function scaleCubeMaps()
    cube_factor = 2
    set("sim/private/controls/cubemap/pmrem/rough_mip1", cube_orginal_rough_mip1 * cube_factor)
    set("sim/private/controls/cubemap/pmrem/rough_mip2", cube_orginal_rough_mip2 * cube_factor)
    set("sim/private/controls/cubemap/pmrem/rough_mip3", cube_orginal_rough_mip3 * cube_factor)
    set("sim/private/controls/cubemap/pmrem/rough_mip4", cube_orginal_rough_mip4 * cube_factor)
    set("sim/private/controls/cubemap/pmrem/rough_mip5", cube_orginal_rough_mip5 * cube_factor)

    set("sim/private/controls/cubemap/x_scale", 1)

    cube_count = 12
    set("sim/private/controls/cube_map/extra samples" , cube_count)

    set("sim/private/controls/photometric/interior_lit_boost", 1.5)
end

function updateClouds() 
    sun_mult = sun_angle / 90.0
    ambient_limit = 5 
    if sun_heading > 0 then ambient_limit = 10 end

    ambient = ambient_limit - sun_mult * ambient_limit * 2

    if ambient > ambient_limit then ambient = ambient_limit end
    if ambient < 1 then ambient = 1 end
    set("sim/private/controls/new_clouds/ambient", ambient)
end

function updateCloudStatic() 
    set("sim/private/controls/new_clouds/march/seg_mul", 1.5)
    set("sim/private/controls/new_clouds/march/step_len_start", 60)

    set("sim/private/controls/cloud/temporal_depth_change_limit", 0)

    density = 20
    set("sim/private/controls/new_clouds/density", density)

    ex = 0.006 * density
    set("sim/private/controls/cloud/extinction", ex)
end

function updateRainScale() 
    set("sim/private/controls/rain/scale", .4)
    set("sim/private/controls/rain/ice_scale", .4)
end

function updateAA()
    set("sim/private/controls/hdr/use_post_aa", 1)
end

function updateSSAO()
    set("sim/private/controls/ssao/exterior_curve", .5)
    set("sim/private/controls/ssao/exterior_strength", 1.1)
end

if ENABLED then
    do_often("onEverySecond()")
    scaleCubeMaps()
    updateCloudStatic()
    updateAA()
    updateRainScale()
end