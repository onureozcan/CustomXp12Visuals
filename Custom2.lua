ENABLED = true

cube_orginal_rough_mip1 = .3
cube_orginal_rough_mip2 = .5
cube_orginal_rough_mip3 = .75
cube_orginal_rough_mip4 = .85
cube_orginal_rough_mip5 = 1

dataref("sun_heading", "sim/graphics/scenery/sun_heading_degrees")
dataref("sun_angle", "sim/graphics/scenery/sun_pitch_degrees")
dataref("ev100mid", "sim/private/controls/photometric/ev100_mtr")
dataref("is_external", "sim/graphics/view/view_is_external")
dataref("view_heading", "sim/graphics/view/view_heading")
dataref("aircraft_heading", "sim/flightmodel/position/mag_psi")
dataref("view_agl", "sim/graphics/view/view_elevation_agl_mtrs")

prev_sun_angle = 0

function onEverySecond()
    updateClouds() 
    tickleCubeMaps()
end

function updateBrightness()
    
end

function tickleCubeMaps()
    set("sim/private/controls/ibl/update_mode", 1)
    set("sim/private/controls/ibl/update_mode", 0)
end

function scaleCubeMapsStatic()
    cube_factor = 1.0
    set("sim/private/controls/cubemap/pmrem/rough_mip1", cube_orginal_rough_mip1 * cube_factor)
    set("sim/private/controls/cubemap/pmrem/rough_mip2", cube_orginal_rough_mip2 * cube_factor)
    set("sim/private/controls/cubemap/pmrem/rough_mip3", cube_orginal_rough_mip3 * cube_factor)
    set("sim/private/controls/cubemap/pmrem/rough_mip4", cube_orginal_rough_mip4 * cube_factor)
    set("sim/private/controls/cubemap/pmrem/rough_mip5", cube_orginal_rough_mip5 * cube_factor)

    set("sim/private/controls/cubemap/x_scale", 1.0)

    cube_count = 9
    set("sim/private/controls/cube_map/extra samples" , cube_count)

    set("sim/private/controls/photometric/interior_lit_boost", 2.5)

    set("sim/private/controls/ibl/update_mode", 0)
    set("sim/private/controls/ssao/interior", 1)
end

function sun_angle_interpolate(angle)
    angle = math.max(0, math.min(angle, 180))
    return (1 - math.abs(90 - angle) / 90)
end

function height_to_value(height, max_height)
    height = math.max(0, math.min(height, max_height))
    local normalized_height = height / max_height
    local value = normalized_height^3
    return value
end

function updateClouds() 
    prev_sun_angle = sun_angle
    sun_mult = sun_angle_interpolate(sun_angle)
    height_mul = height_to_value(view_agl, 10000)

    sky_darkness = sun_mult * (height_mul * 10 + 25) + 2
    
    set("sim/private/controls/atmo/ozone_b", sky_darkness)
    set("sim/private/controls/atmo/ozone_g", sky_darkness)
    set("sim/private/controls/atmo/ozone_r", sky_darkness)

    ambient = math.pow(1 - sun_mult, 3) * 10 
    set("sim/private/controls/new_clouds/ambient", ambient)

    direct = sun_mult * 1.2
    set("sim/private/controls/new_clouds/direct", direct)

    camera_brightness = (1 - sun_mult) * -2 -1.5 
    if (is_external == 0 and math.abs(view_heading - aircraft_heading) < 20) then
        camera_brightness = camera_brightness *.5
    end
    set("sim/private/controls/photometric/ev100_bias", camera_brightness)

    multi_rat = sun_mult * 2 + 1 + height_mul * 3
    set("sim/private/controls/scattering/multi_rat", multi_rat)

    single_rat = sun_mult * 5 + height_mul
    set("sim/private/controls/scattering/single_rat", single_rat)

    mie_rat = (sky_darkness * 2) * height_mul / 5 + 1
    set("sim/private/controls/scattering/mie_rat", mie_rat)

    ms_scattering = ambient / 10 + 2
    set("sim/private/controls/cloud/ms_scattering", ms_scattering)
end

function updateCloudStatic()
    set("sim/private/controls/new_clouds/density", 120)
    set("sim/private/controls/cloud/opacity_floor", 0.0)
    set("sim/private/controls/cloud/ms_extinction", 10)
    set("sim/private/controls/cloud/extinction", .175)
    set("sim/private/controls/cloud/shadow_length", 2500)
    set("sim/private/controls/cloud/ms_scattering", 2.0)
    set("sim/private/controls/new_clouds/march/seg_mul", 1.25)
    set("sim/private/controls/ibl/update_mode", 0)
    set("sim/private/controls/tonemap/white_balance_k", 7000)
end

function updateRainScale() 
    set("sim/private/controls/rain/scale", .4)
end


function updateBloom()
    set("sim/private/controls/hdr/bloom1", -8.5)
end

function updateNightLights()
    set("sim/private/controls/lights/photobb/dist_exp", -1.3)
end

if ENABLED then
    do_often("onEverySecond()")
    scaleCubeMapsStatic()
    updateCloudStatic()
    updateRainScale()
    updateBloom()
    updateNightLights()
end