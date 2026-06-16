//! Documentation forthcoming

const c = @import("c");
const Factory = @import("Factory.zig");
const errors = @import("errors.zig");
const rive = @import("rive.zig");
const std = @import("std");

pub const RenderContext = struct {
    value: *c.Rive_RenderContext,

    pub const FrameDescriptor = c.Rive_FrameDescriptor;

    pub const FlushResources = extern struct {
        //TODO: make render_target accept rive render target, probably
        render_target: *anyopaque,
        external_command_buffer: *anyopaque,
    };

    //TODO: make this into an interface
    pub inline fn makeRenderTargetMetal(self: @This(), width: u32, height: u32) !RenderTargetMetal {
        const ret = c.rive_getMetalRenderTarget(self.value, width, height);
        return .{ .value = try errors.wrapNull(
            *c.struct_Rive_RenderTargetMetal,
            ret,
        ) };
    }
    pub inline fn makeRenderer(self: @This()) !rive.RiveRenderer {
        return .{ .value = try errors.wrapNull(
            *c.Rive_RiveRenderer,
            c.rive_getRendererFromContext(self.value),
        ) };
    }
    pub inline fn beginFrame(self: @This(), fd: FrameDescriptor) void {
        c.rive_contextBeginFrame(self.value, fd);
    }
    pub fn flush(self: @This(), to_flush: FlushResources) void {
        var fr: c.Rive_FlushResources = .{
            .externalCommandBuffer = to_flush.external_command_buffer,
            .renderTarget = @ptrCast(to_flush.render_target),
        };
        c.rive_contextFlush(self.value, &fr);
    }

    //TODO: This should really be specific to a metal implementation
    pub inline fn setMetalCommandQueue(self: @This(), m_queue: ?*anyopaque) void {
        c.rive_setMetalCommandQueue(self.value, m_queue);
    }
};

pub const ContextOptions = struct {};

pub const RenderContextMetalImpl = struct {
    //TODO: add contextOptions

    pub fn makeContext(mtl_device: *anyopaque) !RenderContext {
        return .{ .value = try errors.wrapNull(
            *c.Rive_RenderContext,
            c.rive_MakeContextMetal(mtl_device),
        ) };
    }
};

pub const RenderTargetMetal = struct {
    value: *c.Rive_RenderTargetMetal,
    pub inline fn setTargetTexture(self: RenderTargetMetal, texture: ?*anyopaque) void {
        c.rive_setMetalTargetTexture(self.value, texture);
    }
    pub inline fn deinit(self: RenderTargetMetal) void {
        _ = c.rive_metalRenderTargetRelease(self.value);
        // std.debug.print("refcount: {d} \n", .{refcount});
    }
    pub inline fn width(self: RenderTargetMetal) usize {
        return @intCast(c.rive_renderTargetGetWidth(self.value));
    }
    pub inline fn height(self: RenderTargetMetal) usize {
        return @intCast(c.rive_renderTargetGetHeight(self.value));
    }
};
