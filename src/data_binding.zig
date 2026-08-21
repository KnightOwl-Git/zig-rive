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

    ///swap a nested view model property with another view model instance
    pub inline fn replaceNestedViewModel(self: ViewModelInstance, path: [:0]const u8, new_value: ViewModelInstance) void {
        c.rive_VMIReplaceViewModel(self.value, path, new_value.value);
    }

    //TODO: make interface for properties to reuse code more

    pub const Number = struct {
        ref: *anyopaque,
        callback: *const fn (self: *Number, userData: ?*anyopaque) void = undefined,

        pub inline fn getValue(self: Number) f32 {
            return c.rive_VMINumberGetValue(self.ref);
        }
        pub inline fn setValue(self: Number, value: f32) void {
            return c.rive_VMINumberSetValue(self.ref, value);
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
        callback: *const fn (self: *Boolean, userData: ?*anyopaque) void = undefined,

        pub inline fn getValue(self: Boolean) bool {
            return c.rive_VMIBooleanGetValue(self.ref);
        }
        pub inline fn setValue(self: Boolean, value: bool) void {
            return c.rive_VMIBooleanSetValue(self.ref, value);
        }

        pub fn registerCallback(self: *Boolean, callback: *const fn (self: *Boolean, userData: ?*anyopaque) void, user_data: ?*anyopaque) void {
            self.callback = callback;
            _ = c.rive_registerCallback(self.ref, self, user_data, &c_callback);
        }
        fn c_callback(self: ?*anyopaque, userData: ?*anyopaque) callconv(.c) void {
            const boolean: *Boolean = @ptrCast(@alignCast(self));
            boolean.callback(boolean, userData);
        }
    };

    pub const Trigger = struct {
        ref: *c.Rive_VMI_Trigger,
        callback: *const fn (self: *Trigger, userData: ?*anyopaque) void = undefined,

        pub inline fn trigger(self: Trigger) void {
            return c.rive_VMITriggerTrigger(self.ref);
        }
        //TODO: make sure callback doesn't fire twice per trigger
        pub fn registerCallback(self: *Trigger, callback: *const fn (self: *Trigger, userData: ?*anyopaque) void, user_data: ?*anyopaque) void {
            self.callback = callback;
            _ = c.rive_registerCallback(self.ref, self, user_data, &c_callback);
        }
        fn c_callback(self: ?*anyopaque, userData: ?*anyopaque) callconv(.c) void {
            const trig: *Trigger = @ptrCast(@alignCast(self));
            trig.callback(trig, userData);
        }
    };

    pub const Color = struct {
        ref: *anyopaque,
        callback: *const fn (self: *Color, userData: ?*anyopaque) void = undefined,

        pub inline fn getValue(self: Color) c_int {
            return c.rive_VMIColorGetValue(self.ref);
        }
        pub inline fn setValue(self: Color, value: c_int) void {
            return c.rive_VMIColorSetValue(self.ref, value);
        }
        pub fn registerCallback(self: *Color, callback: *const fn (self: *Color, userData: ?*anyopaque) void, user_data: ?*anyopaque) void {
            self.callback = callback;
            _ = c.rive_registerCallback(self.ref, self, user_data, &c_callback);
        }
        fn c_callback(self: ?*anyopaque, userData: ?*anyopaque) callconv(.c) void {
            const color: *Color = @ptrCast(@alignCast(self));
            color.callback(color, userData);
        }
    };

    pub const String = struct {
        ref: *anyopaque,
        callback: *const fn (self: *String, userData: ?*anyopaque) void = undefined,

        pub inline fn getValue(self: String) [:0]const u8 {
            return c.rive_VMIStringGetValue(self.ref);
        }
        pub inline fn setValue(self: String, value: [:0]const u8) void {
            return c.rive_VMIStringSetValue(self.ref, value);
        }

        pub fn registerCallback(self: *String, callback: *const fn (self: *String, userData: ?*anyopaque) void, user_data: ?*anyopaque) void {
            self.callback = callback;
            _ = c.rive_registerCallback(self.ref, self, user_data, &c_callback);
        }
        fn c_callback(self: ?*anyopaque, userData: ?*anyopaque) callconv(.c) void {
            const string: *String = @ptrCast(@alignCast(self));
            string.callback(string, userData);
        }
    };

    pub const Artboard = struct {
        ref: *anyopaque,
        callback: *const fn (self: *Artboard, userData: ?*anyopaque) void = undefined,

        pub inline fn getName(self: Artboard) [:0]const u8 {
            return c.rive_VMIArtboardGetName(self.ref);
        }
        pub inline fn setValue(self: Artboard, value: rive.Artboard) void {
            return c.rive_VMIArtboardSetValue(self.ref, value.bindable);
        }
        pub inline fn bindViewModelInstance(self: Artboard, to_bind: ViewModelInstance) void {
            c.rive_VMIArtboardBindVM(self.ref, to_bind.value);
        }

        pub fn registerCallback(self: *Artboard, callback: *const fn (self: *Artboard, userData: ?*anyopaque) void, user_data: ?*anyopaque) void {
            self.callback = callback;
            _ = c.rive_registerCallback(self.ref, self, user_data, &c_callback);
        }
        fn c_callback(self: ?*anyopaque, userData: ?*anyopaque) callconv(.c) void {
            const artboard: *Artboard = @ptrCast(@alignCast(self));
            artboard.callback(artboard, userData);
        }
    };

    pub const Enum = struct {
        ref: *anyopaque,
        callback: *const fn (self: *Enum, userData: ?*anyopaque) void = undefined,

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
        pub fn registerCallback(self: *Enum, callback: *const fn (self: *Enum, userData: ?*anyopaque) void, user_data: ?*anyopaque) void {
            self.callback = callback;
            _ = c.rive_registerCallback(self.ref, self, user_data, &c_callback);
        }
        fn c_callback(self: ?*anyopaque, userData: ?*anyopaque) callconv(.c) void {
            const enum_prop: *Enum = @ptrCast(@alignCast(self));
            enum_prop.callback(enum_prop, userData);
        }
    };

    pub const List = struct {
        ref: *anyopaque,
        callback: *const fn (self: *List, userData: ?*anyopaque) void = undefined,

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

        pub fn registerCallback(self: *List, callback: *const fn (self: *List, userData: ?*anyopaque) void, user_data: ?*anyopaque) void {
            self.callback = callback;
            _ = c.rive_registerCallback(self.ref, self, user_data, &c_callback);
        }
        fn c_callback(self: ?*anyopaque, userData: ?*anyopaque) callconv(.c) void {
            const list: *List = @ptrCast(@alignCast(self));
            list.callback(list, userData);
        }
    };
};
