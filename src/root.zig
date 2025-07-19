const std = @import("std");

const CliCraft = @import("cli_craft").CliCraft;
const Command = @import("cli_craft").Command;
const ParsedFlags = @import("cli_craft").ParsedFlags;
const CommandFnArguments = @import("cli_craft").CommandFnArguments;
const FlagType = @import("cli_craft").FlagType;
const FlagValue = @import("cli_craft").FlagValue;

var add_command_result: u8 = undefined;
var get_command_result: []const u8 = undefined;

test "execute an executable command with arguments" {
    var cliCraft = try CliCraft.init(.{ .allocator = std.testing.allocator, .error_options = .{
        .writer = std.io.getStdErr().writer().any(),
    }, .output_options = .{
        .writer = std.io.getStdOut().writer().any(),
    } });

    defer cliCraft.deinit();

    const runnable = struct {
        pub fn run(_: ParsedFlags, arguments: CommandFnArguments) anyerror!void {
            const augend = try std.fmt.parseInt(u8, arguments[0], 10);
            const addend = try std.fmt.parseInt(u8, arguments[1], 10);

            add_command_result = augend + addend;
            return;
        }
    }.run;

    try cliCraft.addExecutableCommand("add", "adds numbers", runnable);
    try cliCraft.executeWithArguments(&[_][]const u8{ "add", "21", "51" });

    try std.testing.expectEqual(72, add_command_result);
}

test "execute an executable command with arguments and flags" {
    var cliCraft = try CliCraft.init(.{ .allocator = std.testing.allocator, .error_options = .{
        .writer = std.io.getStdErr().writer().any(),
    }, .output_options = .{
        .writer = std.io.getStdOut().writer().any(),
    } });

    defer cliCraft.deinit();

    const runnable = struct {
        pub fn run(parsed_flags: ParsedFlags, arguments: CommandFnArguments) anyerror!void {
            const augend = try std.fmt.parseInt(u8, arguments[0], 10);
            const addend = try std.fmt.parseInt(u8, arguments[1], 10);

            try std.testing.expect(try parsed_flags.getBoolean("verbose"));
            try std.testing.expect(try parsed_flags.getBoolean("priority"));
            try std.testing.expectEqual(23, try parsed_flags.getInt64("timeout"));

            add_command_result = augend + addend;
            return;
        }
    }.run;

    var command = try cliCraft.newExecutableCommand(
        "add",
        "adds numbers",
        runnable,
    );
    try command.addFlag(
        try cliCraft.newFlagBuilder(
            "verbose",
            "Enable verbose output",
            FlagType.boolean,
        ).build(),
    );
    try command.addFlag(try cliCraft.newFlagBuilder(
        "priority",
        "Enable priority",
        FlagType.boolean,
    ).build());

    try command.addFlag(try cliCraft.newFlagBuilder(
        "timeout",
        "Define timeout",
        FlagValue.type_int64(25),
    ).withShortName('t').build());

    try cliCraft.addCommand(&command);
    try cliCraft.executeWithArguments(
        &[_][]const u8{ "add", "--timeout", "23", "2", "5", "--verbose", "--priority" },
    );

    try std.testing.expectEqual(7, add_command_result);
}

test "execute an executable command with arguments and flags with short name" {
    var cliCraft = try CliCraft.init(.{ .allocator = std.testing.allocator, .error_options = .{
        .writer = std.io.getStdErr().writer().any(),
    }, .output_options = .{
        .writer = std.io.getStdOut().writer().any(),
    } });

    defer cliCraft.deinit();

    const runnable = struct {
        pub fn run(parsed_flags: ParsedFlags, arguments: CommandFnArguments) anyerror!void {
            const augend = try std.fmt.parseInt(u8, arguments[0], 10);
            const addend = try std.fmt.parseInt(u8, arguments[1], 10);

            try std.testing.expect(try parsed_flags.getBoolean("verbose"));
            try std.testing.expect(try parsed_flags.getBoolean("priority"));
            try std.testing.expectEqual(23, try parsed_flags.getInt64("timeout"));

            add_command_result = augend + addend;
            return;
        }
    }.run;

    var command = try cliCraft.newExecutableCommand(
        "add",
        "adds numbers",
        runnable,
    );
    try command.addFlag(
        try cliCraft.newFlagBuilder(
            "verbose",
            "Enable verbose output",
            FlagType.boolean,
        ).withShortName('v').build(),
    );
    try command.addFlag(try cliCraft.newFlagBuilder(
        "priority",
        "Enable priority",
        FlagType.boolean,
    ).withShortName('p').build());

    try command.addFlag(try cliCraft.newFlagBuilder(
        "timeout",
        "Define timeout",
        FlagValue.type_int64(25),
    ).withShortName('t').build());

    try cliCraft.addCommand(&command);
    try cliCraft.executeWithArguments(
        &[_][]const u8{ "add", "-t", "23", "2", "5", "-v", "-p" },
    );

    try std.testing.expectEqual(7, add_command_result);
}

test "execute a command with subcommand" {
    var cliCraft = try CliCraft.init(.{ .allocator = std.testing.allocator, .error_options = .{
        .writer = std.io.getStdErr().writer().any(),
    }, .output_options = .{
        .writer = std.io.getStdOut().writer().any(),
    } });

    defer cliCraft.deinit();

    const runnable = struct {
        pub fn run(_: ParsedFlags, arguments: CommandFnArguments) anyerror!void {
            get_command_result = arguments[0];
        }
    }.run;

    var get_command = try cliCraft.newExecutableCommand(
        "get",
        "get objects",
        runnable,
    );
    var kubectl_command = try cliCraft.newParentCommand(
        "kubectl",
        "kubernetes entry",
    );
    try kubectl_command.addSubcommand(&get_command);

    try cliCraft.addCommand(&kubectl_command);
    try cliCraft.executeWithArguments(&[_][]const u8{ "kubectl", "get", "pods" });
    try std.testing.expectEqualStrings("pods", get_command_result);
}
