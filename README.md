# LearnOpenGL

A collection repository of the tutorials to learn the OpenGL API following the tutorials at learnopengl.com

## Compiling

I use zig to build the project, so you will need to install the zig compiler.

You can get it here: https://ziglang.org/download/index.html

Once installed, you can build the project by running `zig build`

GLFW is a dependency, I compile it with zig too but this is only tested on windows at the moment.

## Development

I use [Neonvim](https://neovim.io/) for development (on windows yeah, i.e WSL) and we'll have to tell clang to use the correct include paths.

I use [zig-compile-commands](https://github.com/the-argus/zig-compile-commands) for that, all you need is to run `zig build cdb` and it will generate a `compile_commands.json` file in the root directory which is read by clang.

## Running the projects

Each tutorial has its own dedicated build target and you can run them by running `zig build -Dproject=<target> run`
where `<target>` is the name of the target mapped to the build target it build.zig file.

Available targets:
| Target | Description |
| --- | --- |
| `01_hello_window` (default) | A simple window |
