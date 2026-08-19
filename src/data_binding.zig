const rive = @import("rive.zig");
const c = @import("c");
const errors = @import("errors.zig");
const std = @import("std");
const dataBinding = @This();

pub const ViewModel = struct {
    value: *c.Rive_ViewModelRuntime,

    pub fn createDefaultInstance(self: ViewModel) ViewModelInstance {
        return .{
            .value = c.rive_createDefaultVMInstance(self.value).?,
        };
    }
};

pub const ViewModelInstance = struct {
    value: *c.Rive_ViewModelInstanceRuntime,

    pub fn propertyNumber(self: ViewModelInstance, path: [:0]const u8) !Number {
        const ret = c.rive_VMIgetPropertyNumber(self.value, path);

        if (ret) |num| {
            return .{ .ref = num };
        } else {
            return error.PropertyNotFound;
        }
    }
    pub fn propertyBoolean(self: ViewModelInstance, path: [:0]const u8) !Boolean {
        const ret = c.rive_VMIgetPropertyBoolean(self.value, path);

        if (ret) |num| {
            return .{ .ref = num };
        } else {
            return error.PropertyNotFound;
        }
    }

    pub fn propertyString(self: ViewModelInstance, path: [:0]const u8) !String {
        const ret = c.rive_VMIgetPropertyString(self.value, path);

        if (ret) |num| {
            return .{ .ref = num };
        } else {
            return error.PropertyNotFound;
        }
    }

    pub fn propertyTrigger(self: ViewModelInstance, path: [:0]const u8) !Trigger {
        const ret = c.rive_VMIgetPropertyTrigger(self.value, path);

        if (ret) |trig| {
            return .{ .ref = trig };
        } else {
            return error.PropertyNotFound;
        }
    }

    pub fn propertyColor(self: ViewModelInstance, path: [:0]const u8) !Color {
        const ret = c.rive_VMIgetPropertyColor(self.value, path);

        if (ret) |col| {
            return .{ .ref = col };
        } else {
            return error.PropertyNotFound;
        }
    }

    pub fn propertyEnum(self: ViewModelInstance, path: [:0]const u8) !Enum {
        const ret = c.rive_VMIgetPropertyEnum(self.value, path);

        if (ret) |enm| {
            return .{ .ref = enm };
        } else {
            return error.PropertyNotFound;
        }
    }

    pub fn propertyArtboard(self: ViewModelInstance, path: [:0]const u8) !Artboard {
        const ret = c.rive_VMIgetPropertyArtboard(self.value, path);

        if (ret) |art| {
            return .{ .ref = art };
        } else {
            return error.PropertyNotFound;
        }
    }

    pub fn propertyViewModel(self: ViewModelInstance, path: [:0]const u8) !ViewModelInstance {
        const ret = c.rive_VMIgetPropertyViewModel(self.value, path);

        if (ret) |vm| {
            return .{ .value = vm };
        } else {
            return error.PropertyNotFound;
        }
    }

    pub fn propertyList(self: ViewModelInstance, path: [:0]const u8) !List {
        const ret = c.rive_VMIgetPropertyList(self.value, path);

        if (ret) |lst| {
            return .{ .ref = lst };
        } else {
            return error.PropertyNotFound;
        }
    }

    pub const Number = struct {
        ref: *anyopaque,
        callback: *const fn (self: *Number, userData: ?*anyopaque) void = undefined,

        pub inline fn getValue(self: Number) f32 {
            return c.rive_VMINumberGetValue(self.ref);
        }
        pub inline fn setValue(self: Number, value: f32) void {
            return c.rive_VMINumberSetValue(self.ref, value);
        }
        pub inline fn setOnChangedCallback(self: Number, new_callback: *const fn (ref_ptr: *anyopaque, value: f32) callconv(.c) void) void {
            c.rive_VMINumberRegisterCallback(self.ref, @ptrCast(new_callback));
        }
        pub fn registerCallback(self: *Number, callback: *const fn (self: *Number, userData: ?*anyopaque) void, user_data: ?*anyopaque) void {
            self.callback = callback;
            _ = c.rive_registerCallback(self.ref, self, user_data, &c_callback);
        }
        fn c_callback(self: ?*anyopaque, userData: ?*anyopaque) callconv(.c) void {
            const number: *Number = @ptrCast(@alignCast(self));
            number.callback(number, userData);
        }
    };

    pub const Boolean = struct {
        ref: *anyopaque,
        pub inline fn getValue(self: Boolean) bool {
            return c.rive_VMIBooleanGetValue(self.ref);
        }
        pub inline fn setValue(self: Boolean, value: bool) void {
            return c.rive_VMIBooleanSetValue(self.ref, value);
        }
        pub inline fn setOnChangedCallback(self: Boolean, new_callback: *const fn (ref_ptr: *anyopaque, new_value: bool) callconv(.c) void) !void {
            c.rive_VMIBooleanRegisterCallback(self.ref, @ptrCast(new_callback));
        }
    };

    pub const Trigger = struct {
        ref: *c.Rive_VMI_Trigger,

        pub inline fn trigger(self: Trigger) void {
            return c.rive_VMITriggerTrigger(self.ref);
        }
        pub inline fn setOnChangedCallback(self: Trigger, new_callback: *const fn (ref_ptr: *anyopaque, value: u32) callconv(.c) void) !void {
            c.rive_VMITriggerSetCallback(self.ref, @ptrCast(new_callback));
        }
    };

    pub const Color = struct {
        ref: *anyopaque,
        pub inline fn getValue(self: Color) u32 {
            return c.rive_VMIColorGetValue(self.ref);
        }
        pub inline fn setValue(self: Color, value: u32) void {
            return c.rive_VMIColorSetValue(self.ref, value);
        }
        pub inline fn setOnChangedCallback(self: Color, new_callback: *const fn (ref_ptr: *anyopaque, value: u32) callconv(.c) void) !void {
            c.rive_VMIColorRegisterCallback(self.ref, @ptrCast(new_callback));
        }
    };

    pub const String = struct {
        ref: *anyopaque,

        pub inline fn getValue(self: String) [:0]const u8 {
            return c.rive_VMIStringGetValue(self.ref);
        }
        pub inline fn setValue(self: String, value: [:0]const u8) void {
            return c.rive_VMIStringSetValue(self.ref, value);
        }

        pub inline fn setOnChangedCallback(self: String, new_callback: *const fn (ref_ptr: *anyopaque, value: u32) callconv(.c) void) !void {
            c.rive_VMIStringRegisterCallback(self.ref, @ptrCast(new_callback));
        }
    };

    pub const Artboard = struct {
        ref: *anyopaque,

        pub inline fn getName(self: Artboard) [:0]const u8 {
            return c.rive_VMIArtboardGetName(self.ref);
        }
        pub inline fn setValue(self: String, value: rive.Artboard) void {
            return c.rive_VMIArtboardSetValue(self.ref, value.bindable);
        }
    };

    pub const Enum = struct {
        ref: *anyopaque,

        pub inline fn getValue(self: Enum) [:0]const u8 {
            return c.rive_VMIEnumGetValue(self.ref);
        }
        pub inline fn setValue(self: Enum, value: [:0]const u8) void {
            return c.rive_VMIEnumSetValue(self.ref, value);
        }
        pub inline fn getValueIndex(self: Enum) c_int {
            return c.rive_VMIEnumGetValueIndex(self.ref);
        }
        pub inline fn setValueIndex(self: Enum, value: c_int) void {
            return c.rive_VMIEnum(self.ref, value);
        }
        pub inline fn getTypeName(self: Enum) [:0]const u8 {
            return c.rive_VMIEnumGetType(self.ref);
        }
        pub inline fn setOnChangedCallback(self: Enum, new_callback: *const fn (ref_ptr: *anyopaque, value: u32) callconv(.c) void) !void {
            c.rive_VMINumberRegisterCallback(self.ref, @ptrCast(new_callback));
        }
    };

    pub const List = struct {
        ref: *anyopaque,

        pub inline fn getInstanceAt(self: List, index: c_int) ViewModelInstance {
            const ret = c.rive_VMIListGetInstanceAt(self.ref, index);
            if (ret) |vmi| {
                return .{ .ref = vmi };
            } else {
                return error.ListError;
            }
        }
        pub inline fn addInstance(self: List, instance: ViewModelInstance) void {
            c.rive_VMIListAddInstance(self.ref, instance.value);
        }
        pub inline fn addInstanceAt(self: List, instance: ViewModelInstance, index: c_int) void {
            c.rive_VMIListAddInstanceAt(self.ref, instance.value, index);
        }
        pub inline fn removeAll(self: List) void {
            c.rive_VMIListRemoveAll(self.ref);
        }
        pub inline fn removeInstanceAt(self: List, index: c_int) void {
            c.rive_VMIListRemoveInstanceAt(self.ref, index);
        }
        pub inline fn removeInstance(self: List, instance: ViewModelInstance) void {
            c.rive_VMIListRemoveInstanceAt(self.ref, instance.value);
        }
        pub inline fn swap(self: List, instance: ViewModelInstance) void {
            c.rive_VMIListSwap(self.ref, instance);
        }
    };
};
