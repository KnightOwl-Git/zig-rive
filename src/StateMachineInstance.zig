const c = @import("c");
const errors = @import("errors.zig");
const RiveRenderer = @import("RiveRenderer.zig");
const rive = @import("rive.zig");

value: *c.Rive_StateMachineInstance,

pub inline fn advanceAndApply(self: @This(), secs: f32) void {
    c.rive_SMIadvanceAndApply(self.value, secs);
}

pub inline fn draw(self: @This(), renderer: RiveRenderer) void {
    c.rive_SMIdraw(self.value, renderer.value);
}
pub inline fn bindViewModelInstance(self: @This(), vmi: rive.data_binding.ViewModelInstance) void {
    c.rive_stateMachineBindViewModelInstance(self.value, vmi.value);
}

pub inline fn pointerDown(self: @This(), x: f32, y: f32) void {
    c.rive_pointerDown(self.value, x, y);
}

pub inline fn pointerUp(self: @This(), x: f32, y: f32) void {
    c.rive_pointerUp(self.value, x, y);
}

pub inline fn pointerMove(self: @This(), x: f32, y: f32) void {
    c.rive_pointerMove(self.value, x, y);
}
