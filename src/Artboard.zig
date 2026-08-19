const std = @import("std");
const c = @import("c");
const errors = @import("errors.zig");
const smi = @import("StateMachineInstance.zig");
const rive = @import("rive.zig");
const ArtboardInstance = @This();

bindable: *anyopaque,
instance: *c.Rive_ArtboardInstance,

pub inline fn stateMachineCount(self: ArtboardInstance) usize {
    return c.rive_artboard_stateMachineCount(self.instance);
}
pub inline fn defaultStateMachine(self: ArtboardInstance) !smi {
    return .{ .value = try errors.wrapNull(*c.Rive_StateMachineInstance, c.rive_artboard_defaultStateMachine(self.instance)) };
}
pub inline fn stateMachineAt(self: ArtboardInstance, index: usize) !smi {
    return .{ .value = try errors.wrapNull(*c.Rive_StateMachineInstance, c.rive_artboard_stateMachineAt(self.instance, index)) };
}
pub inline fn setWidth(self: ArtboardInstance, width: f32) void {
    c.rive_artboardSetWidth(self.instance, width);
}

pub inline fn setHeight(self: ArtboardInstance, height: f32) void {
    c.rive_artboardSetHeight(self.instance, height);
}

pub inline fn bindViewModelInstance(self: ArtboardInstance, vmi: rive.data_binding.ViewModelInstance) void {
    c.rive_artboardBindViewModelInstance(self.instance, vmi.value);
}
