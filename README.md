# cli-craft-examples
This repository serves as an example collection for [cli-craft](https://github.com/SarthakMakhija/cli-craft), a command-line interface (CLI) client builder written in Zig. Its primary purpose is to showcase various functionalities and usage patterns of the cli-craft library.

### Project Structure
The examples are located within the [src](https://github.com/SarthakMakhija/cli-craft-examples/tree/main/src) directory, demonstrating different aspects of **cli-craft** usage.

- [root.zig](https://github.com/SarthakMakhija/cli-craft-examples/blob/main/src/root.zig) features a suite of tests that illustrate various **cli-craft** usage patterns and examples.
- [main.zig](https://github.com/SarthakMakhija/cli-craft-examples/blob/main/src/main.zig) contains the primary entry point for a demonstration of hierarchical commands built with **cli-craft**.

### Zig version
This project is built with Zig version **0.14.1**.

### Example commands and outputs

1. **No command provided**

```zig
./cli_craft_examples

Error: No command provided to execute.

Usage: [app-name] [command] [flags] [arguments] 

Available Commands:
 arithmetic  (math)  Perform arithmetic operations 
 help                Display help for commands 

Global flags:
 --help, -h  Display help for command 
```

2. **No subcommand provided**

```zig
/cli_craft_examples arithmetic

Error: No subcommand provided for command 'arithmetic'.

arithmetic - Perform arithmetic operations

Usage: arithmetic [subcommand] [flags] [arguments] 

Aliases:
 math 

Flags:
 --help, -h  Show help for command (boolean) 

Available Commands:
 add  (plus)   Add N arguments 
 sub  (minus)  Subtract b from a
```

3. **Arithmetic command (parent command) help**

```zig
./cli_craft_examples arithmetic -h

arithmetic - Perform arithmetic operations

Usage: arithmetic [subcommand] [flags] [arguments] 

Aliases:
 math 

Flags:
 --help, -h  Show help for command (boolean) 

Available Commands:
 add  (plus)   Add N arguments 
 sub  (minus)  Subtract b from a 
```

4. **Add command (child command) help**

```zig
./cli_craft_examples math add -h

add - Add N arguments

Usage: add [flags] [arguments] 

Aliases:
 plus 

Flags:
 --help, -h  Show help for command (boolean) 
```







