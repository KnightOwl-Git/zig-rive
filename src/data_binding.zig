const rive = @import("rive.zig");
const c = @import("c");
const errors = @import("errors.zig");

pub const ViewModelRuntime = struct {
    value: *c.Rive_ViewModelRuntime,
    pub inline fn createDefaultInstance(self: ViewModelRuntime) !ViewModelInstanceRuntime {
        return .{ .value = try errors.wrapNull(
            *c.Rive_ViewModelInstanceRuntime,
            c.rive_createDefaultVMInstance(self.value),
        ) };
    }
};

pub const ViewModelInstanceRuntime = struct {
    value: *c.Rive_ViewModelInstanceRuntime,

    pub inline fn instance(self: ViewModelInstanceRuntime) !ViewModelInstance {
        return .{
            .value = try errors.wrapNull(
                *c.Rive_ViewModelInstance,
                //this can't be right
                @alignCast(c.rive_getViewModelInstance(self.value)),
            ),
        };
    }
};

pub const ViewModelInstance = struct {
    value: *c.Rive_ViewModelInstance,
};
