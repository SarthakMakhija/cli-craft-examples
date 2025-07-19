const std = @import("std");

const CliCraft = @import("cli_craft").CliCraft;
const Command = @import("cli_craft").Command;
const ParsedFlags = @import("cli_craft").ParsedFlags;
const CommandFnArguments = @import("cli_craft").CommandFnArguments;
const CommandAlias = @import("cli_craft").CommandAlias;
const FlagType = @import("cli_craft").FlagType;
const FlagValue = @import("cli_craft").FlagValue;
const ArgumentSpecification = @import("cli_craft").ArgumentSpecification;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    var cliCraft = try CliCraft.init(.{ .allocator = gpa.allocator(), .error_options = .{
        .writer = std.io.getStdErr().writer().any(),
    }, .output_options = .{
        .writer = std.io.getStdOut().writer().any(),
    } });

    defer cliCraft.deinit();

    var command = try cliCraft.newParentCommand("arithmetic", "Performs arithmetic operations");
    try command.setAliases(&[_]CommandAlias{"math"});

    try registerSubCommandAdd(cliCraft, &command);
    try registerSubCommandSubtract(cliCraft, &command);

    try cliCraft.addCommand(&command);

    cliCraft.execute() catch {};
}

fn registerSubCommandAdd(cliCraft: CliCraft, command: *Command) !void {
    const runnable = struct {
        pub fn run(_: ParsedFlags, arguments: CommandFnArguments) anyerror!void {
            var sum: u8 = 0;
            for (arguments) |arg| {
                sum += try std.fmt.parseInt(u8, arg, 10);
            }
            std.debug.print("Sum = {d} \n", .{sum});
            return;
        }
    }.run;

    var subcommand = try cliCraft.newExecutableCommand("add", "Adds N arguments", runnable);
    try subcommand.setAliases(&[_]CommandAlias{"plus"});

    try command.addSubcommand(&subcommand);
}

fn registerSubCommandSubtract(cliCraft: CliCraft, command: *Command) !void {
    const runnable = struct {
        pub fn run(parsed_flags: ParsedFlags, _: CommandFnArguments) anyerror!void {
            std.debug.print("Difference = {d} \n", .{try parsed_flags.getInt64("b") - try parsed_flags.getInt64("a")});
        }
    }.run;

    var subcommand = try cliCraft.newExecutableCommand("sub", "Subtract b from a", runnable);
    try subcommand.setAliases(&[_]CommandAlias{"minus"});

    try subcommand.addFlag(try cliCraft.newFlagBuilder("a", "The first argument", FlagType.int64).withShortName('a').build());
    try subcommand.addFlag(try cliCraft.newFlagBuilder("b", "The second argument", FlagType.int64).withShortName('b').build());

    try command.addSubcommand(&subcommand);
}

const lib = @import("cli_craft_examples_lib");
