//! File rive!
const c = @import("c");
const Factory = @import("Factory.zig");
const std = @import("std");
const errors = @import("errors.zig");
const Artboard = @import("Artboard.zig");
const rive = @import("rive.zig");

value: *c.Rive_File,

const ImportResult = error{
    unsupported_version,
    malformed,
};

//TODO: provide higher level databinding functions

pub fn import(data: [:0]const u8, factory: anytype) !@This() {
    const c_factory = factory.value;
    const c_out: c.Rive_ImportResult = 0;

    // const span: []const u8 = std.mem.span(data);

    const ret = c.rive_file_import(data, data.len, @ptrCast(c_factory), c_out);

    if (c_out == c.RIVE_IMPORT_MALFORMED) {
        return ImportResult.malformed;
    } else if (c_out == c.RIVE_IMPORT_UNSUPPORTED_VERSION) {
        return ImportResult.unsupported_version;
    }

    return .{ .value = try errors.wrapNull(*c.Rive_File, ret) };
}

pub inline fn artboardDefault(self: @This()) !Artboard {
    const bindable = c.rive_file_getBindableArtboardDefault(self.value);
    const instance = c.rive_bindableArtboardGetArtboard(bindable);
    return .{
        .bindable = try errors.wrapNull(*anyopaque, bindable),
        .instance = try errors.wrapNull(*c.Rive_ArtboardInstance, instance),
    };
}

pub inline fn artboardNamed(self: @This(), name: [:0]const u8) !Artboard {
    const bindable = c.rive_file_getBindableArtboardNamed(self.value, name);
    const instance = c.rive_bindableArtboardGetArtboard(bindable);
    return .{
        .bindable = try errors.wrapNull(*anyopaque, bindable),
        .instance = try errors.wrapNull(*c.Rive_ArtboardInstance, instance),
    };
}

pub inline fn defaultArtboardViewModel(self: @This(), ab: rive.Artboard) !rive.data_binding.ViewModel {
    const ret = c.rive_defaultArtboardViewModel(self.value, @ptrCast(ab.bindable));
    if (ret) |vm| {
        return .{ .value = vm };
    } else {
        return error.CreatingViewModelInstance;
    }
}
pub inline fn viewModelByName(self: @This(), name: [:0]const u8) !rive.data_binding.ViewModel {
    const ret = c.rive_FileGetViewModelByName(self.value, name);

    if (ret) |vm| {
        return .{ .value = vm };
    } else {
        return error.GettingViewModel;
    }
}

pub inline fn defaultArtboardViewModelInstance(self: @This(), ab: rive.Artboard) !rive.data_binding.ViewModelInstance {
    const vm = try self.defaultArtboardViewModel(ab);
    return vm.createDefaultInstance();
}
