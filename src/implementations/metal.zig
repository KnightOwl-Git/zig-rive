const std = @import("std");
const Io = std.Io;
const c = @import("c");
const rive = @import("../rive.zig");
const objc = @import("objc");

const MetalImplementation = @This();

renderContext: rive.gpu.RenderContext,
renderTarget: rive.gpu.RenderTargetMetal,
queue: *objc.metal.CommandQueue,
swapchain: *objc.quartz_core.MetalLayer,
currentFrameSurface: ?*objc.quartz_core.MetalDrawable = null,

//TODO: Add options like vsync
//TODO: fix naming

///Takes an mtl_device and a metalView as anyopaque pointers
pub fn init(device: *anyopaque, layer: *anyopaque) !MetalImplementation {

    //Get raw objective c handle from user and cast to a Mach-objc device
    const mtl_device: *objc.metal.Device = @ptrCast(device);
    const render_context = try rive.gpu.RenderContextMetalImpl.makeContext(mtl_device);

    //init to 640x480, will be overridden so the resolution here doesn't matter
    const render_target = try render_context.makeRenderTargetMetal(640, 480);

    //get command queue from device
    const queue = mtl_device.newCommandQueue() orelse @panic("could not create command queue");

    const swapchain: *objc.quartz_core.MetalLayer = @ptrCast(layer);

    //configure swapchain texture

    swapchain.setDevice(mtl_device);
    swapchain.setPixelFormat(objc.metal.PixelFormatBGRA8Unorm);
    swapchain.setDisplaySyncEnabled(true); //Vsync
    //construct Metal implementation
    const ret: MetalImplementation = .{
        .renderContext = render_context,
        .renderTarget = render_target,
        .queue = queue,
        .swapchain = swapchain,
    };

    return ret;
}

///start metal frame, returns width and height of swapchain texture
pub fn beginFrame(self: *MetalImplementation) !struct { f32, f32 } {

    // number_write.setValue(10);
    const pool = objc.objc.autoreleasePoolPush();

    self.currentFrameSurface = objc.quartz_core.MetalLayer.nextDrawable(self.swapchain) orelse @panic("couldn't get current frame surface");
    if (self.currentFrameSurface) |drawable| {

        //set up current swapchain texture

        const width_d = drawable.texture().width();
        const height_d = drawable.texture().height();

        if (self.renderTarget.width() != width_d or self.renderTarget.height() != height_d) {
            //window size has changed
            //NOTE: this seems to cause a slight memory leak when resizing window, I'm unsure why

            self.renderTarget = try self.renderContext.makeRenderTargetMetal(@intCast(width_d), @intCast(height_d));
        }

        self.renderTarget.setTargetTexture(drawable.texture());

        self.renderContext.beginFrame(.{
            .render_target_width = @intCast(width_d),
            .render_target_height = @intCast(height_d),
            .clear_color = 0xffffff,
        });
        return .{ @floatFromInt(width_d), @floatFromInt(height_d) };
    } else {
        return error.NoSwapchain;
    }

    objc.objc.autoreleasePoolPop(pool);
}

pub fn endFrame(self: MetalImplementation) !void {
    const pool = objc.objc.autoreleasePoolPush();

    const flushCommandBuffer = self.queue.commandBuffer() orelse @panic("couldn't create flushCommandBuffer");

    self.renderContext.flush(.{
        .render_target = self.renderTarget.value,
        .external_command_buffer = flushCommandBuffer,
    });

    if (self.currentFrameSurface) |drawable| {
        flushCommandBuffer.commit();

        const presentCommandBuffer = self.queue.commandBuffer().?;
        presentCommandBuffer.presentDrawable(@ptrCast(drawable));
        presentCommandBuffer.commit();
        self.renderTarget.setTargetTexture(null);
        presentCommandBuffer.waitUntilCompleted(); //Maybe unnecessary?
    }

    objc.objc.autoreleasePoolPop(pool);
}

///Nothing for now
pub fn deinit(self: MetalImplementation) !void {
    _ = self;
}
