const rive = @import("rive.zig");
const c = @import("c");
const errors = @import("errors.zig");
const std = @import("std");

value: *c.Rive_ViewModelInstance,

pub fn getNumber(self: @This(), name: [:0]const u8) !Number {
    const ret = c.rive_getVMINumber(self.value, name);

    if (ret) |num| {
        return .{ .ref = num };
    } else {
        return error.PropertyNotFound;
    }
}
pub fn getBoolean(self: @This(), name: [:0]const u8) !Boolean {
    const ret = c.rive_getVMIBoolean(self.value, name);

    if (ret) |num| {
        return .{ .ref = num };
    } else {
        return error.PropertyNotFound;
    }
}

pub fn getTrigger(self: @This(), name: [:0]const u8) !Trigger {
    const ret = c.rive_getVMITrigger(self.value, name);

    if (ret) |trig| {
        return .{ .ref = trig };
    } else {
        return error.PropertyNotFound;
    }
}

pub fn getColor(self: @This(), name: [:0]const u8) !Color {
    const ret = c.rive_getVMIColor(self.value, name);

    if (ret) |col| {
        return .{ .ref = col };
    } else {
        return error.PropertyNotFound;
    }
}

pub fn getEnum(self: @This(), name: [:0]const u8) !Enum {
    const ret = c.rive_getVMIEnum(self.value, name);

    if (ret) |enm| {
        return .{ .ref = enm };
    } else {
        return error.PropertyNotFound;
    }
}
pub fn getList(self: @This(), name: [:0]const u8) !List {
    const ret = c.rive_getVMIList(self.value, name);

    if (ret) |enm| {
        return .{ .ref = enm };
    } else {
        return error.PropertyNotFound;
    }
}
pub fn createListItem(self: @This()) !List.ListItem {
    const ret = c.rive_VMIlistItemInit(self.value);
    if (ret) |item| {
        return .{ .ref = item };
    } else {
        return error.createListItemFailed;
    }
}

//using ref instead of value so as not to conflate with view model property values

pub const Number = struct {
    ref: *c.Rive_VMI_Number,
    pub inline fn getValue(self: Number) f32 {
        return c.rive_getVMINumberValue(self.ref);
    }
    pub inline fn setValue(self: Number, value: f32) void {
        return c.rive_setVMINumberValue(self.ref, value);
    }
    pub inline fn setOnChangedCallback(self: Number, new_callback: *const fn (ref_ptr: *anyopaque, value: f32) callconv(.c) void) void {
        c.rive_VMINumberSetCallback(self.ref, @ptrCast(new_callback));
    }
};

pub const Color = struct {
    ref: *c.Rive_VMI_Color,
    pub inline fn getValue(self: Color) u32 {
        return c.rive_getVMIColorValue(self.ref);
    }
    pub inline fn setValue(self: Color, value: u32) void {
        return c.rive_setVMIColorValue(self.ref, value);
    }
    pub inline fn setOnChangedCallback(self: Color, new_callback: *const fn (ref_ptr: *anyopaque, value: u32) callconv(.c) void) !void {
        c.rive_VMIColorSetCallback(self.ref, @ptrCast(new_callback));
    }
};

pub const Enum = struct {
    ref: *c.Rive_VMI_Enum,
    pub inline fn getValue(self: Enum) u32 {
        return c.rive_getVMIEnumValue(self.ref);
    }
    pub inline fn setValue(self: Enum, value: u32) void {
        return c.rive_setVMIEnumValue(self.ref, value);
    }
    pub inline fn setOnChangedCallback(self: Enum, new_callback: *const fn (ref_ptr: *anyopaque, value: u32) callconv(.c) void) !void {
        c.rive_VMIEnumSetCallback(self.ref, @ptrCast(new_callback));
    }
};

pub const Boolean = struct {
    ref: *c.Rive_VMI_Boolean,
    pub inline fn getValue(self: Boolean) bool {
        return c.rive_getVMIBooleanValue(self.ref);
    }
    pub inline fn setValue(self: Boolean, value: bool) void {
        return c.rive_setVMIBooleanValue(self.ref, value);
    }
    pub inline fn setOnChangedCallback(self: Boolean, new_callback: *const fn (ref_ptr: *anyopaque, new_value: bool) callconv(.c) void) !void {
        c.rive_VMIBooleanSetCallback(self.ref, @ptrCast(new_callback));
    }
};
pub const List = struct {
    ref: *c.Rive_VMI_List,
    pub const ListItem = struct {
        ref: *c.Rive_VMI_ListItem,
        pub inline fn addVMI(self: ListItem, vmi: @This()) void {
            c.rive_VMIlistItemAddVMI(self.ref, vmi.ref);
        }
    };
    //Todo: error handling

    pub inline fn getListItemAt(self: List, index: u32) ListItem {
        return .{ .ref = c.rive_getVMIListItem(self.ref, index) };
    }
    pub inline fn addItem(self: List, item: ListItem) void {
        c.rive_VMIListAddItem(self.ref, item.ref);
    }
    pub inline fn addItemAt(self: List, item: ListItem, index: u32) void {
        c.rive_VMIListAddItemAt(self.ref, item.ref, index);
    }
    pub inline fn removeAll(self: List) void {
        c.rive_VMIListRemoveAll(self.ref);
    }
    pub inline fn removeItemAt(self: List, index: u32) void {
        c.rive_VMIListRemoveItemAt(self.ref, index);
    }
    pub inline fn pop(self: List) ListItem {
        return .{ .ref = c.rive_VMIListPop(self.ref) };
    }
    pub inline fn setOnChangedCallback(self: List, new_callback: *const fn (ref_ptr: *anyopaque) callconv(.c) void) !void {
        c.rive_VMIListSetCallback(self.ref, @ptrCast(new_callback));
    }
};

pub const Trigger = struct {
    ref: *c.Rive_VMI_Trigger,

    pub inline fn getValue(self: Trigger) u32 {
        return c.rive_getVMITriggerValue(self.ref);
    }
    pub inline fn trigger(self: Trigger) void {
        return c.rive_fireVMITrigger(self.ref);
    }
    pub inline fn setOnChangedCallback(self: Trigger, new_callback: *const fn (ref_ptr: *anyopaque, value: u32) callconv(.c) void) !void {
        c.rive_VMITriggerSetCallback(self.ref, @ptrCast(new_callback));
    }
};
