const std = @import("std");
const c = @import("c");
const errors = @import("errors.zig");
const smi = @import("StateMachineInstance.zig");
const rive = @import("rive.zig");

///TODO: Write documentation
pub const ArtboardInstance = struct {
    value: *c.Rive_ArtboardInstance,
    pub inline fn stateMachineCount(self: ArtboardInstance) usize {
        return c.rive_artboard_stateMachineCount(self.value);
    }
    pub inline fn defaultStateMachine(self: ArtboardInstance) !smi {
        return .{ .value = try errors.wrapNull(*c.Rive_StateMachineInstance, c.rive_artboard_defaultStateMachine(self.value)) };
    }
    pub inline fn stateMachineAt(self: ArtboardInstance, index: usize) !smi {
        return .{ .value = try errors.wrapNull(*c.Rive_StateMachineInstance, c.rive_artboard_stateMachineAt(self.value, index)) };
    }
    pub inline fn setWidth(self: ArtboardInstance, width: f32) void {
        c.rive_artboardSetWidth(self.value, width);
    }

    pub inline fn setHeight(self: ArtboardInstance, height: f32) void {
        c.rive_artboardSetHeight(self.value, height);
    }
    pub inline fn bindViewModelInstance(self: ArtboardInstance, vmi: rive.data_binding.ViewModelInstance) void {
        c.rive_artboardBindViewModelInstance(self.value, vmi.value);
    }
};
