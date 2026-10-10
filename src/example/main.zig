const std = @import("std");
const Io = std.Io;
const c = @import("c");
const g = @import("g");
const objc = @import("objc");
const metal = objc.metal;
const rive = @import("rive");

pub fn main() !void {
    const gpu = objc.metal.createSystemDefaultDevice() orelse @panic("couldn't create metal device");
    const swapchain = objc.quartz_core.MetalLayer.new();

    //initialize GLFW

    if (g.glfwInit() != 1) {
        @panic("couldn't init glfw");
    }

    defer g.glfwTerminate();

    const window = g.glfwCreateWindow(640, 480, "Rive Example", null, null) orelse @panic("couldn't create glfw window");

    // Specific steps for metal, eventdtually add support for more APIs
    const ns_window: *objc.app_kit.Window = @ptrCast(g.glfwGetCocoaWindow(window));
    ns_window.contentView().?.setLayer(@ptrCast(swapchain));
    ns_window.contentView().?.setWantsLayer(true);

    var metal_impl = try rive.MetalImpl.init(gpu, swapchain);
    const riv = @embedFile("databinding_testing.riv");
    const file = try rive.File.import(riv, metal_impl.renderContext);
    const artboard = try file.artboardDefault();

    //just for testing
    const SMcount = artboard.stateMachineCount();
    std.debug.print("state machine count: {d}\n", .{SMcount});
    //
    const state_machine = try artboard.defaultStateMachine();

    const renderer = try metal_impl.renderContext.makeRenderer();
    //
    // // bind default view model instance to artboard. if one exists
    const vm = try file.defaultArtboardViewModel(artboard);
    const vmi = vm.createDefaultInstance();
    artboard.bindViewModelInstance(vmi);

    var last_time: f64 = 0;

    while (g.glfwWindowShouldClose(window) != 1) {
        g.glfwSwapBuffers(window);
        g.glfwPollEvents();

        //time measurement
        const current_time = g.glfwGetTime();
        const delta_time = current_time - last_time;
        last_time = current_time;

        const pool = objc.objc.autoreleasePoolPush();
        const dtFloat: f32 = @floatCast(delta_time);

        //get pixel density from macos window backing for retina displays
        var xscale: f32 = 0;
        var yscale: f32 = 0;

        g.glfwGetWindowContentScale(window, &xscale, &yscale);

        const width_f, const height_f = try metal_impl.beginFrame();

        //set artboard width and height to match render target size
        artboard.setWidth(width_f / xscale);
        artboard.setHeight(height_f / yscale);

        renderer.save();
        renderer.DPIScale(xscale);
        state_machine.advanceAndApply(dtFloat / 1000); // this is where trigger callbacks get called
        state_machine.draw(renderer);
        renderer.restore();
        try metal_impl.endFrame();
        objc.objc.autoreleasePoolPop(pool);
    }
}
//view model property change callbacks must be defined like this. I'd like to improve upon this in the future to allow for uder-defined date

pub fn numberChange(prop: *anyopaque, new_value: f32) callconv(.c) void {
    _ = prop; // autofix
    // _ = prop;
    std.debug.print("new value: {d}\n", .{new_value});
}
