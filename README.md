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
| Target | Description | Extra step |
| --- | --- | --- |
| `01_hello_window` (default) | A simple window with cleared background (Dark Slate Gray) |
| `02_hello_triangle`         | A simple dark orange-ish triangle |
| `02_hello_triangle_ebos`    | A simple dark orange-ish rectangle using element buffer objects (indexed drawing) |
| `02_hello_triangle_ex1`     | Two triangles on different positions |
| `02_hello_triangle_ex2`     | Two triangles on different positions using different VBOs and VAOs |
| `02_hello_triangle_ex3`     | Two triangles on different positions using different VBOs and VAOs and different shaders |
| `03_shaders`     | A simple shader example | Requires you to run `zig build cdb -Dproject=03_shaders` to update the `compile_commands.json` file to detect the shader.h include path (if u are using neovim or vscode instead of vs (along with clangd)) |
| `03_shaders_ex1`     | A flipped triangle shader example | Requires you to run `zig build cdb -Dproject=03_shaders_ex1` to update the `compile_commands.json` file to detect the shader.h include path (if u are using neovim or vscode instead of vs (along with clangd)) |
| `03_shaders_ex2`     | A triangle positioned to right side of the screen with an offset provided by the vertex shader | Requires you to run `zig build cdb -Dproject=03_shaders_ex2` to update the `compile_commands.json` file to detect the shader.h include path (if u are using neovim or vscode instead of vs (along with clangd)) |
| `03_shaders_ex3`     | A triangle colored by passing its position from the vertex shader to the fragment shader | Requires you to run `zig build cdb -Dproject=03_shaders_ex3` to update the `compile_commands.json` file to detect the shader.h include path (if u are using neovim or vscode instead of vs (along with clangd)) |
| `04_textures`     | A simple textures example | Requires you to run `zig build cdb -Dproject=04_textures` to update the `compile_commands.json` file to detect the shader.h include path (if u are using neovim or vscode instead of vs (along with clangd)) |
| `04_textures_ex1`     | A flipped texture (using the vertex shader) example | Requires you to run `zig build cdb -Dproject=04_textures_ex1` to update the `compile_commands.json` file to detect the shader.h include path (if u are using neovim or vscode instead of vs (along with clangd)) |
| `04_textures_ex2`     | A clamped texture (using the vertex shader) example | Requires you to run `zig build cdb -Dproject=04_textures_ex2` to update the `compile_commands.json` file to detect the shader.h include path (if u are using neovim or vscode instead of vs (along with clangd)) |
| `05_transformations`     | A simple transformations example | Requires you to run `zig build cdb -Dproject=05_transformations` to update the `compile_commands.json` file to detect the shader.h & GLM's include path (if u are using neovim or vscode instead of vs (along with clangd)) |
| `05_transformations_ex1`     | A transformations example with two containers rotating & scaling | Requires you to run `zig build cdb -Dproject=05_transformations_ex1` to update the `compile_commands.json` file to detect the shader.h & GLM's include path (if u are using neovim or vscode instead of vs (along with clangd)) |


