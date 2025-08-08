const std = @import("std");
const zcc = @import("compile_commands");
const mem = std.mem;

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    const use_wayland = b.option(bool, "use_wayland", "Use wayland instead of x11") orelse false;
    const project_name = b.option([]const u8, "project", "The name of the project to build") orelse "01_hello_window";

    const glfw = b.addStaticLibrary(.{
        .name = "glfw",
        .target = target,
        .optimize = optimize,
    });

    const glfw_include = "glfw-3.4/include";
    glfw.addIncludePath(.{ .cwd_relative = glfw_include });

    glfw.addCSourceFiles(.{
        .files = &.{
            "glfw-3.4/src/context.c",
            "glfw-3.4/src/init.c",
            "glfw-3.4/src/input.c",
            "glfw-3.4/src/monitor.c",
            "glfw-3.4/src/platform.c",
            "glfw-3.4/src/vulkan.c",
            "glfw-3.4/src/window.c",
            "glfw-3.4/src/egl_context.c",
            "glfw-3.4/src/osmesa_context.c",

            "glfw-3.4/src/null_init.c",
            "glfw-3.4/src/null_joystick.c",
            "glfw-3.4/src/null_monitor.c",
            "glfw-3.4/src/null_window.c",
        },
        .flags = if (target.query.os_tag == .windows) &.{ "-DWIN32", "-D_GLFW_WIN32", "-D_WINDOWS", "-DUNICODE", "-D_UNICODE" } else &.{},
    });

    if (target.query.os_tag == .linux) {
        if (use_wayland) {
            glfw.addCSourceFiles(.{
                .files = &.{
                    "glfw-3.4/src/wayland_init.c",
                    "glfw-3.4/src/wayland_monitor.c",
                    "glfw-3.4/src/wayland_window.c",
                    "glfw-3.4/src/xkb_unicode.c",
                    "glfw-3.4/src/posix_time.c",
                    "glfw-3.4/src/posix_thread.c",
                    "glfw-3.4/src/posix_poll.c",
                    "glfw-3.4/src/linux_joystick.c",
                    "glfw-3.4/src/egl_context.c",
                },
                .flags = &.{
                    "-D_GLFW_WAYLAND",
                    "-pthread",
                },
            });
        } else {
            glfw.addCSourceFiles(.{
                .files = &.{
                    "glfw-3.4/src/x11_init.c",
                    "glfw-3.4/src/x11_monitor.c",
                    "glfw-3.4/src/x11_window.c",
                    "glfw-3.4/src/xkb_unicode.c",
                    "glfw-3.4/src/posix_time.c",
                    "glfw-3.4/src/posix_thread.c",
                    "glfw-3.4/src/posix_poll.c",
                    "glfw-3.4/src/linux_joystick.c",
                    "glfw/src/glx_context.c",
                },
                .flags = &.{
                    "-D_GLFW_X11",
                    "-pthread",
                },
            });
        }
    }

    if (target.query.os_tag == .windows) {
        glfw.addCSourceFiles(.{
            .files = &.{
                "glfw-3.4/src/win32_init.c",
                "glfw-3.4/src/win32_joystick.c",
                "glfw-3.4/src/win32_module.c",
                "glfw-3.4/src/win32_monitor.c",
                "glfw-3.4/src/win32_thread.c",
                "glfw-3.4/src/win32_time.c",
                "glfw-3.4/src/win32_window.c",
                "glfw-3.4/src/wgl_context.c",
            },
            .flags = &.{
                "-DWIN32",
                "-D_GLFW_WIN32",
                "-D_WINDOWS",
                "-DUNICODE",
                "-D_UNICODE",
            },
        });
    }

    glfw.linkLibC();
    if (target.query.os_tag == .windows) {
        glfw.linkSystemLibrary("gdi32");
    }

    b.installArtifact(glfw);

    var targets = std.ArrayList(*std.Build.Step.Compile).init(b.allocator);

    if (mem.eql(u8, project_name, "01_hello_window")) {
        const hello_window = b.addExecutable(.{
            .name = "LearnOpenGL",
            .optimize = optimize,
            .target = target,
        });

        hello_window.addIncludePath(.{ .cwd_relative = "./glfw-3.4/include/" });
        hello_window.addIncludePath(.{ .cwd_relative = "./glad/include/" });
        hello_window.addCSourceFiles(.{
            .files = &.{
                "src/01_hello_window/main.cxx",
                "glad/src/glad.c",
            },
        });
        hello_window.linkLibrary(glfw);
        hello_window.linkLibCpp();

        b.installArtifact(hello_window);

        const run_cmd = b.addRunArtifact(hello_window);
        const run_step = b.step("run", "Run the app");
        run_step.dependOn(&run_cmd.step);

        targets.append(hello_window) catch @panic("OOM"); // used once, not necessary to add other projects
    }

    if (mem.eql(u8, project_name, "02_hello_triangle")) {
        const hello_triangle = b.addExecutable(.{
            .name = "LearnOpenGL",
            .optimize = optimize,
            .target = target,
        });

        hello_triangle.addIncludePath(.{ .cwd_relative = "./glfw-3.4/include/" });
        hello_triangle.addIncludePath(.{ .cwd_relative = "./glad/include/" });
        hello_triangle.addCSourceFiles(.{
            .files = &.{
                "src/02_hello_triangle/main.cxx",
                "glad/src/glad.c",
            },
        });
        hello_triangle.linkLibrary(glfw);
        hello_triangle.linkLibCpp();

        b.installArtifact(hello_triangle);

        const run_cmd = b.addRunArtifact(hello_triangle);
        const run_step = b.step("run", "Run the app");
        run_step.dependOn(&run_cmd.step);
    }

    if (mem.eql(u8, project_name, "02_hello_triangle_ebos")) {
        const hello_triangle_ebos = b.addExecutable(.{
            .name = "LearnOpenGL",
            .optimize = optimize,
            .target = target,
        });

        hello_triangle_ebos.addIncludePath(.{ .cwd_relative = "./glfw-3.4/include/" });
        hello_triangle_ebos.addIncludePath(.{ .cwd_relative = "./glad/include/" });
        hello_triangle_ebos.addCSourceFiles(.{
            .files = &.{
                "src/02_hello_triangle_EBOs/main.cxx",
                "glad/src/glad.c",
            },
        });
        hello_triangle_ebos.linkLibrary(glfw);
        hello_triangle_ebos.linkLibCpp();

        b.installArtifact(hello_triangle_ebos);

        const run_cmd = b.addRunArtifact(hello_triangle_ebos);
        const run_step = b.step("run", "Run the app");
        run_step.dependOn(&run_cmd.step);
    }

    if (mem.eql(u8, project_name, "02_hello_triangle_ex1")) {
        const hello_triangle_exercise_1 = b.addExecutable(.{
            .name = "LearnOpenGL",
            .optimize = optimize,
            .target = target,
        });

        hello_triangle_exercise_1.addIncludePath(.{ .cwd_relative = "./glfw-3.4/include/" });
        hello_triangle_exercise_1.addIncludePath(.{ .cwd_relative = "./glad/include/" });
        hello_triangle_exercise_1.addCSourceFiles(.{
            .files = &.{
                "src/02_hello_triangle_ex1_two_triangles/main.cxx",
                "glad/src/glad.c",
            },
        });
        hello_triangle_exercise_1.linkLibrary(glfw);
        hello_triangle_exercise_1.linkLibCpp();

        b.installArtifact(hello_triangle_exercise_1);

        const run_cmd = b.addRunArtifact(hello_triangle_exercise_1);
        const run_step = b.step("run", "Run the app");
        run_step.dependOn(&run_cmd.step);
    }

    if (mem.eql(u8, project_name, "02_hello_triangle_ex2")) {
        const hello_triangle_exercise_2 = b.addExecutable(.{
            .name = "LearnOpenGL",
            .optimize = optimize,
            .target = target,
        });

        hello_triangle_exercise_2.addIncludePath(.{ .cwd_relative = "./glfw-3.4/include/" });
        hello_triangle_exercise_2.addIncludePath(.{ .cwd_relative = "./glad/include/" });
        hello_triangle_exercise_2.addCSourceFiles(.{
            .files = &.{
                "src/02_hello_triangle_ex2_diff_VAO_VBO/main.cxx",
                "glad/src/glad.c",
            },
        });
        hello_triangle_exercise_2.linkLibrary(glfw);
        hello_triangle_exercise_2.linkLibCpp();

        b.installArtifact(hello_triangle_exercise_2);

        const run_cmd = b.addRunArtifact(hello_triangle_exercise_2);
        const run_step = b.step("run", "Run the app");
        run_step.dependOn(&run_cmd.step);
    }
    
    if (mem.eql(u8, project_name, "02_hello_triangle_ex3")) {
        const hello_triangle_exercise_3 = b.addExecutable(.{
            .name = "LearnOpenGL",
            .optimize = optimize,
            .target = target,
        });

        hello_triangle_exercise_3.addIncludePath(.{ .cwd_relative = "./glfw-3.4/include/" });
        hello_triangle_exercise_3.addIncludePath(.{ .cwd_relative = "./glad/include/" });
        hello_triangle_exercise_3.addCSourceFiles(.{
            .files = &.{
                "src/02_hello_triangle_ex3_diff_shaders/main.cxx",
                "glad/src/glad.c",
            },
        });
        hello_triangle_exercise_3.linkLibrary(glfw);
        hello_triangle_exercise_3.linkLibCpp();

        b.installArtifact(hello_triangle_exercise_3);

        const run_cmd = b.addRunArtifact(hello_triangle_exercise_3);
        const run_step = b.step("run", "Run the app");
        run_step.dependOn(&run_cmd.step);
    }
    
    if (mem.eql(u8, project_name, "03_shaders")) {
        const shaders = b.addExecutable(.{
            .name = "LearnOpenGL",
            .optimize = optimize,
            .target = target,
        });

        shaders.addIncludePath(.{ .cwd_relative = "./glfw-3.4/include/" });
        shaders.addIncludePath(.{ .cwd_relative = "./glad/include/" });
        shaders.addIncludePath(.{ .cwd_relative = "./include/" });
        shaders.addCSourceFiles(.{
            .files = &.{
                "src/03_shaders/main.cxx",
                "glad/src/glad.c",
            },
        });
        shaders.linkLibrary(glfw);
        shaders.linkLibCpp();

        b.installArtifact(shaders);

        const run_cmd = b.addRunArtifact(shaders);
        const run_step = b.step("run", "Run the app");
        run_step.dependOn(&run_cmd.step);

        targets.append(shaders) catch @panic("OOM");
    }
    
    if (mem.eql(u8, project_name, "03_shaders_ex1")) {
        const shaders_exercise_1 = b.addExecutable(.{
            .name = "LearnOpenGL",
            .optimize = optimize,
            .target = target,
        });

        shaders_exercise_1.addIncludePath(.{ .cwd_relative = "./glfw-3.4/include/" });
        shaders_exercise_1.addIncludePath(.{ .cwd_relative = "./glad/include/" });
        shaders_exercise_1.addIncludePath(.{ .cwd_relative = "./include/" });
        shaders_exercise_1.addCSourceFiles(.{
            .files = &.{
                "src/03_shaders_ex1/main.cxx",
                "glad/src/glad.c",
            },
        });
        shaders_exercise_1.linkLibrary(glfw);
        shaders_exercise_1.linkLibCpp();

        b.installArtifact(shaders_exercise_1);

        const run_cmd = b.addRunArtifact(shaders_exercise_1);
        const run_step = b.step("run", "Run the app");
        run_step.dependOn(&run_cmd.step);

        targets.append(shaders_exercise_1) catch @panic("OOM");
    }
    
    if (mem.eql(u8, project_name, "03_shaders_ex2")) {
        const shaders_exercise_2 = b.addExecutable(.{
            .name = "LearnOpenGL",
            .optimize = optimize,
            .target = target,
        });

        shaders_exercise_2.addIncludePath(.{ .cwd_relative = "./glfw-3.4/include/" });
        shaders_exercise_2.addIncludePath(.{ .cwd_relative = "./glad/include/" });
        shaders_exercise_2.addIncludePath(.{ .cwd_relative = "./include/" });
        shaders_exercise_2.addCSourceFiles(.{
            .files = &.{
                "src/03_shaders_ex2/main.cxx",
                "glad/src/glad.c",
            },
        });
        shaders_exercise_2.linkLibrary(glfw);
        shaders_exercise_2.linkLibCpp();

        b.installArtifact(shaders_exercise_2);

        const run_cmd = b.addRunArtifact(shaders_exercise_2);
        const run_step = b.step("run", "Run the app");
        run_step.dependOn(&run_cmd.step);

        targets.append(shaders_exercise_2) catch @panic("OOM");
    }

    if (mem.eql(u8, project_name, "03_shaders_ex3")) {
        const shaders_exercise_3 = b.addExecutable(.{
            .name = "LearnOpenGL",
            .optimize = optimize,
            .target = target,
        });

        shaders_exercise_3.addIncludePath(.{ .cwd_relative = "./glfw-3.4/include/" });
        shaders_exercise_3.addIncludePath(.{ .cwd_relative = "./glad/include/" });
        shaders_exercise_3.addIncludePath(.{ .cwd_relative = "./include/" });
        shaders_exercise_3.addCSourceFiles(.{
            .files = &.{
                "src/03_shaders_ex3/main.cxx",
                "glad/src/glad.c",
            },
        });
        shaders_exercise_3.linkLibrary(glfw);
        shaders_exercise_3.linkLibCpp();

        b.installArtifact(shaders_exercise_3);

        const run_cmd = b.addRunArtifact(shaders_exercise_3);
        const run_step = b.step("run", "Run the app");
        run_step.dependOn(&run_cmd.step);

        targets.append(shaders_exercise_3) catch @panic("OOM");
    } 
     
    // generate compile_commands.json (for clang)
    _ = zcc.createStep(b, "cdb", targets.toOwnedSlice() catch @panic("OOM"));
}
