const std = @import("std");
const zcc = @import("compile_commands");
const mem = std.mem;
const builtin = @import("builtin");

const zig_version = builtin.zig_version;
fn lazy_from_path(path_chars: []const u8, owner: *std.Build) std.Build.LazyPath {
    if (zig_version.major > 0 or zig_version.minor >= 13) {
        return std.Build.LazyPath{ .src_path = .{ .sub_path = path_chars, .owner = owner } };
    } else if (zig_version.minor >= 12) {
        return std.Build.LazyPath{ .path = path_chars };
    } else unreachable;
}

pub fn build(b: *std.Build) !void {
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

    if (mem.eql(u8, project_name, "04_textures")) {
        const textures = b.addExecutable(.{
            .name = "LearnOpenGL",
            .optimize = optimize,
            .target = target,
        });

        textures.addIncludePath(.{ .cwd_relative = "./glfw-3.4/include/" });
        textures.addIncludePath(.{ .cwd_relative = "./glad/include/" });
        textures.addIncludePath(.{ .cwd_relative = "./include/" });
        textures.addCSourceFiles(.{
            .files = &.{
                "src/04_textures/main.cxx",
                "glad/src/glad.c",
            },
        });
        textures.linkLibrary(glfw);
        textures.linkLibCpp();

        b.installArtifact(textures);

        const run_cmd = b.addRunArtifact(textures);
        const run_step = b.step("run", "Run the app");
        run_step.dependOn(&run_cmd.step);

        targets.append(textures) catch @panic("OOM");
    }

    if (mem.eql(u8, project_name, "04_textures_ex1")) {
        const textures_exercise_1 = b.addExecutable(.{
            .name = "LearnOpenGL",
            .optimize = optimize,
            .target = target,
        });

        textures_exercise_1.addIncludePath(.{ .cwd_relative = "./glfw-3.4/include/" });
        textures_exercise_1.addIncludePath(.{ .cwd_relative = "./glad/include/" });
        textures_exercise_1.addIncludePath(.{ .cwd_relative = "./include/" });
        textures_exercise_1.addCSourceFiles(.{
            .files = &.{
                "src/04_textures_ex1/main.cxx",
                "glad/src/glad.c",
            },
        });
        textures_exercise_1.linkLibrary(glfw);
        textures_exercise_1.linkLibCpp();

        b.installArtifact(textures_exercise_1);

        const run_cmd = b.addRunArtifact(textures_exercise_1);
        const run_step = b.step("run", "Run the app");
        run_step.dependOn(&run_cmd.step);

        targets.append(textures_exercise_1) catch @panic("OOM");
    }

    if (mem.eql(u8, project_name, "04_textures_ex2")) {
        const textures_exercise_2 = b.addExecutable(.{
            .name = "LearnOpenGL",
            .optimize = optimize,
            .target = target,
        });

        textures_exercise_2.addIncludePath(.{ .cwd_relative = "./glfw-3.4/include/" });
        textures_exercise_2.addIncludePath(.{ .cwd_relative = "./glad/include/" });
        textures_exercise_2.addIncludePath(.{ .cwd_relative = "./include/" });
        textures_exercise_2.addCSourceFiles(.{
            .files = &.{
                "src/04_textures_ex2/main.cxx",
                "glad/src/glad.c",
            },
        });
        textures_exercise_2.linkLibrary(glfw);
        textures_exercise_2.linkLibCpp();

        b.installArtifact(textures_exercise_2);

        const run_cmd = b.addRunArtifact(textures_exercise_2);
        const run_step = b.step("run", "Run the app");
        run_step.dependOn(&run_cmd.step);

        targets.append(textures_exercise_2) catch @panic("OOM");
    }

    if (mem.eql(u8, project_name, "04_textures_ex2")) {
        const textures_exercise_2 = b.addExecutable(.{
            .name = "LearnOpenGL",
            .optimize = optimize,
            .target = target,
        });

        textures_exercise_2.addIncludePath(.{ .cwd_relative = "./glfw-3.4/include/" });
        textures_exercise_2.addIncludePath(.{ .cwd_relative = "./glad/include/" });
        textures_exercise_2.addIncludePath(.{ .cwd_relative = "./include/" });
        textures_exercise_2.addCSourceFiles(.{
            .files = &.{
                "src/04_textures_ex2/main.cxx",
                "glad/src/glad.c",
            },
        });
        textures_exercise_2.linkLibrary(glfw);
        textures_exercise_2.linkLibCpp();

        b.installArtifact(textures_exercise_2);

        const run_cmd = b.addRunArtifact(textures_exercise_2);
        const run_step = b.step("run", "Run the app");
        run_step.dependOn(&run_cmd.step);

        targets.append(textures_exercise_2) catch @panic("OOM");
    }

    if (mem.eql(u8, project_name, "05_transformations")) {
        const transformations = b.addExecutable(.{
            .name = "LearnOpenGL",
            .optimize = optimize,
            .target = target,
        });

        transformations.addIncludePath(.{ .cwd_relative = "./glfw-3.4/include/" });
        transformations.addIncludePath(.{ .cwd_relative = "./glad/include/" });
        transformations.addIncludePath(.{ .cwd_relative = "./include/" });
        transformations.addCSourceFiles(.{
            .files = &.{
                "src/05_transformations/main.cxx",
                "glad/src/glad.c",
            },
        });
        transformations.linkLibrary(glfw);
        transformations.linkLibCpp();

        b.installArtifact(transformations);

        const run_cmd = b.addRunArtifact(transformations);
        const run_step = b.step("run", "Run the app");
        run_step.dependOn(&run_cmd.step);

        targets.append(transformations) catch @panic("OOM");
    }

    if (mem.eql(u8, project_name, "05_transformations_ex1")) {
        const transformations_ex1 = b.addExecutable(.{
            .name = "LearnOpenGL",
            .optimize = optimize,
            .target = target,
        });

        transformations_ex1.addIncludePath(.{ .cwd_relative = "./glfw-3.4/include/" });
        transformations_ex1.addIncludePath(.{ .cwd_relative = "./glad/include/" });
        transformations_ex1.addIncludePath(.{ .cwd_relative = "./include/" });
        transformations_ex1.addCSourceFiles(.{
            .files = &.{
                "src/05_transformations_ex1/main.cxx",
                "glad/src/glad.c",
            },
        });
        transformations_ex1.linkLibrary(glfw);
        transformations_ex1.linkLibCpp();

        b.installArtifact(transformations_ex1);

        const run_cmd = b.addRunArtifact(transformations_ex1);
        const run_step = b.step("run", "Run the app");
        run_step.dependOn(&run_cmd.step);

        targets.append(transformations_ex1) catch @panic("OOM");
    }

    if (mem.eql(u8, project_name, "06_coordinate_systems")) {
        const coordinate_systems = b.addExecutable(.{
            .name = "LearnOpenGL",
            .optimize = optimize,
            .target = target,
        });

        coordinate_systems.addIncludePath(.{ .cwd_relative = "./glfw-3.4/include/" });
        coordinate_systems.addIncludePath(.{ .cwd_relative = "./glad/include/" });
        coordinate_systems.addIncludePath(.{ .cwd_relative = "./include/" });
        coordinate_systems.addCSourceFiles(.{
            .files = &.{
                "src/06_coordinate_systems/main.cxx",
                "glad/src/glad.c",
            },
        });
        coordinate_systems.linkLibrary(glfw);
        coordinate_systems.linkLibCpp();

        b.installArtifact(coordinate_systems);

        const run_cmd = b.addRunArtifact(coordinate_systems);
        const run_step = b.step("run", "Run the app");
        run_step.dependOn(&run_cmd.step);

        targets.append(coordinate_systems) catch @panic("OOM");
    }

    if (mem.eql(u8, project_name, "06_coordinate_systems_ex1")) {
        const coordinate_systems_ex1 = b.addExecutable(.{
            .name = "LearnOpenGL",
            .optimize = optimize,
            .target = target,
        });

        coordinate_systems_ex1.addIncludePath(.{ .cwd_relative = "./glfw-3.4/include/" });
        coordinate_systems_ex1.addIncludePath(.{ .cwd_relative = "./glad/include/" });
        coordinate_systems_ex1.addIncludePath(.{ .cwd_relative = "./include/" });
        coordinate_systems_ex1.addCSourceFiles(.{
            .files = &.{
                "src/06_coordinate_systems_ex1/main.cxx",
                "glad/src/glad.c",
            },
        });
        coordinate_systems_ex1.linkLibrary(glfw);
        coordinate_systems_ex1.linkLibCpp();

        b.installArtifact(coordinate_systems_ex1);

        const run_cmd = b.addRunArtifact(coordinate_systems_ex1);
        const run_step = b.step("run", "Run the app");
        run_step.dependOn(&run_cmd.step);

        targets.append(coordinate_systems_ex1) catch @panic("OOM");
    }

    if (mem.eql(u8, project_name, "07_camera")) {
        const camera = b.addExecutable(.{
            .name = "LearnOpenGL",
            .optimize = optimize,
            .target = target,
        });

        camera.addIncludePath(.{ .cwd_relative = "./glfw-3.4/include/" });
        camera.addIncludePath(.{ .cwd_relative = "./glad/include/" });
        camera.addIncludePath(.{ .cwd_relative = "./include/" });
        camera.addCSourceFiles(.{
            .files = &.{
                "src/07_camera/main.cxx",
                "glad/src/glad.c",
            },
        });
        camera.linkLibrary(glfw);
        camera.linkLibCpp();

        b.installArtifact(camera);

        const run_cmd = b.addRunArtifact(camera);
        const run_step = b.step("run", "Run the app");
        run_step.dependOn(&run_cmd.step);

        targets.append(camera) catch @panic("OOM");
    }

    if (mem.eql(u8, project_name, "08_colors")) {
        const colors = b.addExecutable(.{
            .name = "LearnOpenGL",
            .optimize = optimize,
            .target = target,
        });

        colors.addIncludePath(.{ .cwd_relative = "./glfw-3.4/include/" });
        colors.addIncludePath(.{ .cwd_relative = "./glad/include/" });
        colors.addIncludePath(.{ .cwd_relative = "./include/" });
        colors.addCSourceFiles(.{
            .files = &.{
                "src/08_colors/main.cxx",
                "glad/src/glad.c",
            },
        });
        colors.linkLibrary(glfw);
        colors.linkLibCpp();

        b.installArtifact(colors);

        const run_cmd = b.addRunArtifact(colors);
        const run_step = b.step("run", "Run the app");
        run_step.dependOn(&run_cmd.step);

        targets.append(colors) catch @panic("OOM");
    }

    if (mem.eql(u8, project_name, "09_basic_lighting")) {
        const basic_lighting = b.addExecutable(.{
            .name = "LearnOpenGL",
            .optimize = optimize,
            .target = target,
        });

        basic_lighting.addIncludePath(.{ .cwd_relative = "./glfw-3.4/include/" });
        basic_lighting.addIncludePath(.{ .cwd_relative = "./glad/include/" });
        basic_lighting.addIncludePath(.{ .cwd_relative = "./include/" });
        basic_lighting.addCSourceFiles(.{
            .files = &.{
                "src/09_basic_lighting/main.cxx",
                "glad/src/glad.c",
            },
        });
        basic_lighting.linkLibrary(glfw);
        basic_lighting.linkLibCpp();

        b.installArtifact(basic_lighting);

        const run_cmd = b.addRunArtifact(basic_lighting);
        const run_step = b.step("run", "Run the app");
        run_step.dependOn(&run_cmd.step);

        targets.append(basic_lighting) catch @panic("OOM");
    }

    if (mem.eql(u8, project_name, "10_materials")) {
        const materials = b.addExecutable(.{
            .name = "LearnOpenGL",
            .optimize = optimize,
            .target = target,
        });

        materials.addIncludePath(.{ .cwd_relative = "./glfw-3.4/include/" });
        materials.addIncludePath(.{ .cwd_relative = "./glad/include/" });
        materials.addIncludePath(.{ .cwd_relative = "./include/" });
        materials.addCSourceFiles(.{
            .files = &.{
                "src/10_materials/main.cxx",
                "glad/src/glad.c",
            },
        });
        materials.linkLibrary(glfw);
        materials.linkLibCpp();

        b.installArtifact(materials);

        const run_cmd = b.addRunArtifact(materials);
        const run_step = b.step("run", "Run the app");
        run_step.dependOn(&run_cmd.step);

        targets.append(materials) catch @panic("OOM");
    }

    if (mem.eql(u8, project_name, "11_lighting_maps")) {
        const lighting_maps = b.addExecutable(.{
            .name = "LearnOpenGL",
            .optimize = optimize,
            .target = target,
        });

        lighting_maps.addIncludePath(.{ .cwd_relative = "./glfw-3.4/include/" });
        lighting_maps.addIncludePath(.{ .cwd_relative = "./glad/include/" });
        lighting_maps.addIncludePath(.{ .cwd_relative = "./include/" });
        lighting_maps.addCSourceFiles(.{
            .files = &.{
                "src/11_lighting_maps/main.cxx",
                "glad/src/glad.c",
            },
        });
        lighting_maps.linkLibrary(glfw);
        lighting_maps.linkLibCpp();

        b.installArtifact(lighting_maps);

        const run_cmd = b.addRunArtifact(lighting_maps);
        const run_step = b.step("run", "Run the app");
        run_step.dependOn(&run_cmd.step);

        targets.append(lighting_maps) catch @panic("OOM");
    }

    if (mem.eql(u8, project_name, "12_light_casters")) {
        const light_casters = b.addExecutable(.{
            .name = "LearnOpenGL",
            .optimize = optimize,
            .target = target,
        });

        light_casters.addIncludePath(.{ .cwd_relative = "./glfw-3.4/include/" });
        light_casters.addIncludePath(.{ .cwd_relative = "./glad/include/" });
        light_casters.addIncludePath(.{ .cwd_relative = "./include/" });
        light_casters.addCSourceFiles(.{
            .files = &.{
                "src/12_light_casters/main.cxx",
                "glad/src/glad.c",
            },
        });
        light_casters.linkLibrary(glfw);
        light_casters.linkLibCpp();

        b.installArtifact(light_casters);

        const run_cmd = b.addRunArtifact(light_casters);
        const run_step = b.step("run", "Run the app");
        run_step.dependOn(&run_cmd.step);

        targets.append(light_casters) catch @panic("OOM");
    }

    if (mem.eql(u8, project_name, "13_multiple_lights")) {
        const multiple_lights = b.addExecutable(.{
            .name = "LearnOpenGL",
            .optimize = optimize,
            .target = target,
        });

        multiple_lights.addIncludePath(.{ .cwd_relative = "./glfw-3.4/include/" });
        multiple_lights.addIncludePath(.{ .cwd_relative = "./glad/include/" });
        multiple_lights.addIncludePath(.{ .cwd_relative = "./include/" });
        multiple_lights.addCSourceFiles(.{
            .files = &.{
                "src/13_multiple_lights/main.cxx",
                "glad/src/glad.c",
            },
        });
        multiple_lights.linkLibrary(glfw);
        multiple_lights.linkLibCpp();

        b.installArtifact(multiple_lights);

        const run_cmd = b.addRunArtifact(multiple_lights);
        const run_step = b.step("run", "Run the app");
        run_step.dependOn(&run_cmd.step);

        targets.append(multiple_lights) catch @panic("OOM");
    }

    const formats = b.option([]const u8, "formats", "Comma separated list of enabled formats or \"all\", for example: STL,3MF,Obj") orelse "";
    const use_double_precision = b.option(bool, "double", "All data will be stored as double values") orelse false;
    const assimp = b.dependency("assimp", .{});

    const lib = b.addStaticLibrary(.{
        .name = "assimp",
        .optimize = optimize,
        .target = target,
    });

    if (target.result.os.tag == .windows) {
        lib.root_module.addCMacro("_WINDOWS", "");
        // lib.root_module.addCMacro("_WIN32", ""); // gives redefined error
        lib.root_module.addCMacro("OPENDDL_STATIC_LIBARY", "");
    }

    lib.linkLibC();
    if (target.result.abi != .msvc) {
        lib.linkLibCpp();
    }

    const config_h = b.addConfigHeader(
        .{
            .style = .{ .cmake = assimp.path("include/assimp/config.h.in") },
            .include_path = "assimp/config.h",
        },
        .{ .ASSIMP_DOUBLE_PRECISION = use_double_precision },
    );
    lib.addConfigHeader(config_h);
    lib.addIncludePath(assimp.path("include"));
    lib.addIncludePath(lazy_from_path("include", b));

    lib.addIncludePath(assimp.path(""));
    lib.addIncludePath(assimp.path("contrib"));
    lib.addIncludePath(assimp.path("code"));
    lib.addIncludePath(assimp.path("contrib/pugixml/src/"));
    lib.addIncludePath(assimp.path("contrib/rapidjson/include"));
    lib.addIncludePath(assimp.path("contrib/unzip"));
    lib.addIncludePath(assimp.path("contrib/zlib"));
    lib.addIncludePath(assimp.path("contrib/openddlparser/include"));

    lib.root_module.addCMacro("RAPIDJSON_HAS_STDSTRING", "1");

    lib.installConfigHeader(config_h);
    lib.installHeadersDirectory(
        assimp.path("include"),
        "",
        .{ .include_extensions = &.{ ".h", ".inl", ".hpp" } },
    );

    lib.installHeadersDirectory(
        lazy_from_path("include", b),
        "",
        .{ .include_extensions = &.{ ".h", ".inl", ".hpp" } },
    );

    lib.addCSourceFiles(.{
        .root = assimp.path(""),
        .files = &sources.common,
        .flags = &.{},
    });

    inline for (comptime std.meta.declarations(sources.libraries)) |ext_lib| {
        lib.addCSourceFiles(.{
            .root = assimp.path(""),
            .files = &@field(sources.libraries, ext_lib.name),
            .flags = &.{},
        });
    }

    var enable_all = false;
    var enabled_formats = std.BufSet.init(b.allocator);
    defer enabled_formats.deinit();
    var tokenizer = std.mem.tokenizeAny(u8, formats, ",");
    while (tokenizer.next()) |format| {
        if (std.mem.eql(u8, format, "all")) {
            enable_all = true;
            break;
        }

        var found: bool = false;
        inline for (comptime std.meta.declarations(sources.formats)) |format_files| {
            if (std.mem.eql(u8, format_files.name, format)) {
                try enabled_formats.insert(format);
                found = true;
            }
        }
        if (!found) {
            std.debug.print("Unsupported format: {s}\n", .{format});
            std.debug.print("Supported formats:\n", .{});
            inline for (comptime std.meta.declarations(sources.formats)) |format_files| {
                std.debug.print("    {s}\n", .{format_files.name});
            }
            return error.InvalidFormat;
        }
    }

    inline for (comptime std.meta.declarations(sources.formats)) |format_files| {
        const enabled = enable_all or enabled_formats.contains(format_files.name);

        if (enabled) {
            lib.addCSourceFiles(.{
                .root = assimp.path(""),
                .files = &@field(sources.formats, format_files.name),
                .flags = &.{},
            });
        } else {
            const define_importer = b.fmt("ASSIMP_BUILD_NO_{}_IMPORTER", .{fmtUpperCase(format_files.name)});
            const define_exporter = b.fmt("ASSIMP_BUILD_NO_{}_EXPORTER", .{fmtUpperCase(format_files.name)});

            lib.root_module.addCMacro(define_importer, "");
            lib.root_module.addCMacro(define_exporter, "");
        }
    }

    for (unsupported_formats) |unsupported_format| {
        const define_importer = b.fmt("ASSIMP_BUILD_NO_{}_IMPORTER", .{fmtUpperCase(unsupported_format)});
        const define_exporter = b.fmt("ASSIMP_BUILD_NO_{}_EXPORTER", .{fmtUpperCase(unsupported_format)});

        lib.root_module.addCMacro(define_importer, "");
        lib.root_module.addCMacro(define_exporter, "");
    }

    b.installArtifact(lib);
    targets.append(lib) catch @panic("OOM");

    if (mem.eql(u8, project_name, "14_model")) {
        const model = b.addExecutable(.{
            .name = "LearnOpenGL",
            .optimize = optimize,
            .target = target,
        });
        model.addIncludePath(assimp.path("include"));
        model.addIncludePath(.{ .cwd_relative = "./glfw-3.4/include/" });
        model.addIncludePath(.{ .cwd_relative = "./glad/include/" });
        model.addIncludePath(.{ .cwd_relative = "./include/" });
        model.addCSourceFiles(.{
            .files = &.{
                "src/14_model/main.cxx",
                "glad/src/glad.c",
            },
        });
        model.linkLibrary(lib);
        model.linkLibrary(glfw);
        model.linkLibCpp();

        const run_cmd = b.addRunArtifact(model);
        const run_step = b.step("run", "Run the app");
        run_step.dependOn(&run_cmd.step);

        b.installArtifact(model);

        targets.append(model) catch @panic("OOM");
    }

    if (mem.eql(u8, project_name, "15_depth_testing")) {
        const depth_testing = b.addExecutable(.{
            .name = "LearnOpenGL",
            .optimize = optimize,
            .target = target,
        });
        depth_testing.addIncludePath(assimp.path("include"));
        depth_testing.addIncludePath(.{ .cwd_relative = "./glfw-3.4/include/" });
        depth_testing.addIncludePath(.{ .cwd_relative = "./glad/include/" });
        depth_testing.addIncludePath(.{ .cwd_relative = "./include/" });
        depth_testing.addCSourceFiles(.{
            .files = &.{
                "src/15_depth_testing/main.cxx",
                "glad/src/glad.c",
            },
        });
        depth_testing.linkLibrary(lib);
        depth_testing.linkLibrary(glfw);
        depth_testing.linkLibCpp();

        const run_cmd = b.addRunArtifact(depth_testing);
        const run_step = b.step("run", "Run the app");
        run_step.dependOn(&run_cmd.step);

        b.installArtifact(depth_testing);

        targets.append(depth_testing) catch @panic("OOM");
    }

    // generate compile_commands.json (for clangd)
    _ = zcc.createStep(b, "cdb", targets.toOwnedSlice() catch @panic("OOM"));
}

const unsupported_formats = [_][]const u8{
    "C4D", // fails to build, MSVC only
};

const sources = struct {
    const common = [_][]const u8{
        "code/CApi/AssimpCExport.cpp",
        "code/CApi/CInterfaceIOWrapper.cpp",
        "code/Common/AssertHandler.cpp",
        "code/Common/Assimp.cpp",
        "code/Common/Base64.cpp",
        "code/Common/BaseImporter.cpp",
        "code/Common/BaseProcess.cpp",
        "code/Common/Bitmap.cpp",
        "code/Common/CreateAnimMesh.cpp",
        "code/Common/Compression.cpp",
        "code/Common/DefaultIOStream.cpp",
        "code/Common/IOSystem.cpp",
        "code/Common/DefaultIOSystem.cpp",
        "code/Common/DefaultLogger.cpp",
        "code/Common/Exceptional.cpp",
        "code/Common/Exporter.cpp",
        "code/Common/Importer.cpp",
        "code/Common/ImporterRegistry.cpp",
        "code/Common/material.cpp",
        "code/Common/PostStepRegistry.cpp",
        "code/Common/RemoveComments.cpp",
        "code/Common/scene.cpp",
        "code/Common/SceneCombiner.cpp",
        "code/Common/ScenePreprocessor.cpp",
        "code/Common/SGSpatialSort.cpp",
        "code/Common/simd.cpp",
        "code/Common/SkeletonMeshBuilder.cpp",
        "code/Common/SpatialSort.cpp",
        "code/Common/StandardShapes.cpp",
        "code/Common/Subdivision.cpp",
        "code/Common/TargetAnimation.cpp",
        "code/Common/Version.cpp",
        "code/Common/VertexTriangleAdjacency.cpp",
        "code/Common/ZipArchiveIOSystem.cpp",
        "code/Geometry/GeometryUtils.cpp",
        "code/Material/MaterialSystem.cpp",
        "code/Pbrt/PbrtExporter.cpp",
        "code/PostProcessing/ArmaturePopulate.cpp",
        "code/PostProcessing/CalcTangentsProcess.cpp",
        "code/PostProcessing/ComputeUVMappingProcess.cpp",
        "code/PostProcessing/ConvertToLHProcess.cpp",
        "code/PostProcessing/DeboneProcess.cpp",
        "code/PostProcessing/DropFaceNormalsProcess.cpp",
        "code/PostProcessing/EmbedTexturesProcess.cpp",
        "code/PostProcessing/FindDegenerates.cpp",
        "code/PostProcessing/FindInstancesProcess.cpp",
        "code/PostProcessing/FindInvalidDataProcess.cpp",
        "code/PostProcessing/FixNormalsStep.cpp",
        "code/PostProcessing/GenBoundingBoxesProcess.cpp",
        "code/PostProcessing/GenFaceNormalsProcess.cpp",
        "code/PostProcessing/GenVertexNormalsProcess.cpp",
        "code/PostProcessing/ImproveCacheLocality.cpp",
        "code/PostProcessing/JoinVerticesProcess.cpp",
        "code/PostProcessing/LimitBoneWeightsProcess.cpp",
        "code/PostProcessing/MakeVerboseFormat.cpp",
        "code/PostProcessing/OptimizeGraph.cpp",
        "code/PostProcessing/OptimizeMeshes.cpp",
        "code/PostProcessing/PretransformVertices.cpp",
        "code/PostProcessing/ProcessHelper.cpp",
        "code/PostProcessing/RemoveRedundantMaterials.cpp",
        "code/PostProcessing/RemoveVCProcess.cpp",
        "code/PostProcessing/ScaleProcess.cpp",
        "code/PostProcessing/SortByPTypeProcess.cpp",
        "code/PostProcessing/SplitByBoneCountProcess.cpp",
        "code/PostProcessing/SplitLargeMeshes.cpp",
        "code/PostProcessing/TextureTransform.cpp",
        "code/PostProcessing/TriangulateProcess.cpp",
        "code/PostProcessing/ValidateDataStructure.cpp",
    };

    const libraries = struct {
        pub const unzip = [_][]const u8{
            "contrib/unzip/unzip.c",
            "contrib/unzip/ioapi.c",
            // "contrib/unzip/crypt.c",
        };
        pub const zip = [_][]const u8{
            "contrib/zip/src/zip.c",
        };
        pub const zlib = [_][]const u8{
            "contrib/zlib/inflate.c",
            "contrib/zlib/infback.c",
            "contrib/zlib/gzclose.c",
            "contrib/zlib/gzread.c",
            "contrib/zlib/inftrees.c",
            "contrib/zlib/gzwrite.c",
            "contrib/zlib/compress.c",
            "contrib/zlib/inffast.c",
            "contrib/zlib/uncompr.c",
            "contrib/zlib/gzlib.c",
            // assimpRoot() ++ "/contrib/zlib/contrib/testzlib/testzlib.c",
            // assimpRoot() ++ "/contrib/zlib/contrib/inflate86/inffas86.c",
            // assimpRoot() ++ "/contrib/zlib/contrib/masmx64/inffas8664.c",
            // assimpRoot() ++ "/contrib/zlib/contrib/infback9/infback9.c",
            // assimpRoot() ++ "/contrib/zlib/contrib/infback9/inftree9.c",
            // assimpRoot() ++ "/contrib/zlib/contrib/minizip/miniunz.c",
            // assimpRoot() ++ "/contrib/zlib/contrib/minizip/minizip.c",
            // assimpRoot() ++ "/contrib/zlib/contrib/minizip/unzip.c",
            // assimpRoot() ++ "/contrib/zlib/contrib/minizip/ioapi.c",
            // assimpRoot() ++ "/contrib/zlib/contrib/minizip/mztools.c",
            // assimpRoot() ++ "/contrib/zlib/contrib/minizip/zip.c",
            // assimpRoot() ++ "/contrib/zlib/contrib/minizip/iowin32.c",
            // assimpRoot() ++ "/contrib/zlib/contrib/puff/pufftest.c",
            // assimpRoot() ++ "/contrib/zlib/contrib/puff/puff.c",
            // assimpRoot() ++ "/contrib/zlib/contrib/blast/blast.c",
            // assimpRoot() ++ "/contrib/zlib/contrib/untgz/untgz.c",
            "contrib/zlib/trees.c",
            "contrib/zlib/zutil.c",
            "contrib/zlib/deflate.c",
            "contrib/zlib/crc32.c",
            "contrib/zlib/adler32.c",
        };
        pub const poly2tri = [_][]const u8{
            "contrib/poly2tri/poly2tri/common/shapes.cc",
            "contrib/poly2tri/poly2tri/sweep/sweep_context.cc",
            "contrib/poly2tri/poly2tri/sweep/advancing_front.cc",
            "contrib/poly2tri/poly2tri/sweep/cdt.cc",
            "contrib/poly2tri/poly2tri/sweep/sweep.cc",
        };
        pub const clipper = [_][]const u8{
            "contrib/clipper/clipper.cpp",
        };
        pub const openddlparser = [_][]const u8{
            "contrib/openddlparser/code/OpenDDLParser.cpp",
            "contrib/openddlparser/code/OpenDDLExport.cpp",
            "contrib/openddlparser/code/DDLNode.cpp",
            "contrib/openddlparser/code/OpenDDLCommon.cpp",
            "contrib/openddlparser/code/Value.cpp",
            "contrib/openddlparser/code/OpenDDLStream.cpp",
        };
    };
    pub const formats = struct {
        pub const @"3DS" = [_][]const u8{
            "code/AssetLib/3DS/3DSConverter.cpp",
            "code/AssetLib/3DS/3DSExporter.cpp",
            "code/AssetLib/3DS/3DSLoader.cpp",
        };
        pub const @"3MF" = [_][]const u8{
            "code/AssetLib/3MF/D3MFExporter.cpp",
            "code/AssetLib/3MF/D3MFImporter.cpp",
            "code/AssetLib/3MF/D3MFOpcPackage.cpp",
            "code/AssetLib/3MF/XmlSerializer.cpp",
        };
        pub const AC = [_][]const u8{
            "code/AssetLib/AC/ACLoader.cpp",
        };
        pub const AMF = [_][]const u8{
            "code/AssetLib/AMF/AMFImporter_Geometry.cpp",
            "code/AssetLib/AMF/AMFImporter_Material.cpp",
            "code/AssetLib/AMF/AMFImporter_Postprocess.cpp",
            "code/AssetLib/AMF/AMFImporter.cpp",
        };
        pub const ASE = [_][]const u8{
            "code/AssetLib/ASE/ASELoader.cpp",
            "code/AssetLib/ASE/ASEParser.cpp",
        };
        pub const Assbin = [_][]const u8{
            "code/AssetLib/Assbin/AssbinExporter.cpp",
            "code/AssetLib/Assbin/AssbinFileWriter.cpp",
            "code/AssetLib/Assbin/AssbinLoader.cpp",
        };
        pub const Assjson = [_][]const u8{
            "code/AssetLib/Assjson/cencode.c",
            "code/AssetLib/Assjson/json_exporter.cpp",
            "code/AssetLib/Assjson/mesh_splitter.cpp",
        };
        pub const Assxml = [_][]const u8{
            "code/AssetLib/Assxml/AssxmlExporter.cpp",
            "code/AssetLib/Assxml/AssxmlFileWriter.cpp",
        };
        pub const B3D = [_][]const u8{
            "code/AssetLib/B3D/B3DImporter.cpp",
        };
        pub const Blend = [_][]const u8{
            "code/AssetLib/Blender/BlenderBMesh.cpp",
            "code/AssetLib/Blender/BlenderCustomData.cpp",
            "code/AssetLib/Blender/BlenderDNA.cpp",
            "code/AssetLib/Blender/BlenderLoader.cpp",
            "code/AssetLib/Blender/BlenderModifier.cpp",
            "code/AssetLib/Blender/BlenderScene.cpp",
            "code/AssetLib/Blender/BlenderTessellator.cpp",
        };
        pub const BVH = [_][]const u8{
            "code/AssetLib/BVH/BVHLoader.cpp",
        };
        // pub const C4D = [_][]const u8{
        //     "code/AssetLib/C4D/C4DImporter.cpp",
        // };
        pub const COB = [_][]const u8{
            "code/AssetLib/COB/COBLoader.cpp",
        };
        pub const Collada = [_][]const u8{
            "code/AssetLib/Collada/ColladaExporter.cpp",
            "code/AssetLib/Collada/ColladaHelper.cpp",
            "code/AssetLib/Collada/ColladaLoader.cpp",
            "code/AssetLib/Collada/ColladaParser.cpp",
        };
        pub const CSM = [_][]const u8{
            "code/AssetLib/CSM/CSMLoader.cpp",
        };
        pub const DXF = [_][]const u8{
            "code/AssetLib/DXF/DXFLoader.cpp",
        };
        pub const FBX = [_][]const u8{
            "code/AssetLib/FBX/FBXAnimation.cpp",
            "code/AssetLib/FBX/FBXBinaryTokenizer.cpp",
            "code/AssetLib/FBX/FBXConverter.cpp",
            "code/AssetLib/FBX/FBXDeformer.cpp",
            "code/AssetLib/FBX/FBXDocument.cpp",
            "code/AssetLib/FBX/FBXDocumentUtil.cpp",
            "code/AssetLib/FBX/FBXExporter.cpp",
            "code/AssetLib/FBX/FBXExportNode.cpp",
            "code/AssetLib/FBX/FBXExportProperty.cpp",
            "code/AssetLib/FBX/FBXImporter.cpp",
            "code/AssetLib/FBX/FBXMaterial.cpp",
            "code/AssetLib/FBX/FBXMeshGeometry.cpp",
            "code/AssetLib/FBX/FBXModel.cpp",
            "code/AssetLib/FBX/FBXNodeAttribute.cpp",
            "code/AssetLib/FBX/FBXParser.cpp",
            "code/AssetLib/FBX/FBXProperties.cpp",
            "code/AssetLib/FBX/FBXTokenizer.cpp",
            "code/AssetLib/FBX/FBXUtil.cpp",
        };
        pub const glTF = [_][]const u8{
            "code/AssetLib/glTF/glTFCommon.cpp",
            "code/AssetLib/glTF/glTFExporter.cpp",
            "code/AssetLib/glTF/glTFImporter.cpp",
        };
        pub const glTF2 = [_][]const u8{
            "code/AssetLib/glTF2/glTF2Exporter.cpp",
            "code/AssetLib/glTF2/glTF2Importer.cpp",
        };
        pub const HMP = [_][]const u8{
            "code/AssetLib/HMP/HMPLoader.cpp",
        };
        pub const IFC = [_][]const u8{
            "code/AssetLib/IFC/IFCBoolean.cpp",
            "code/AssetLib/IFC/IFCCurve.cpp",
            "code/AssetLib/IFC/IFCGeometry.cpp",
            "code/AssetLib/IFC/IFCLoader.cpp",
            "code/AssetLib/IFC/IFCMaterial.cpp",
            "code/AssetLib/IFC/IFCOpenings.cpp",
            "code/AssetLib/IFC/IFCProfile.cpp",
            // "code/AssetLib/IFC/IFCReaderGen_4.cpp", // not used?
            "code/AssetLib/IFC/IFCReaderGen1_2x3.cpp",
            "code/AssetLib/IFC/IFCReaderGen2_2x3.cpp",
            "code/AssetLib/IFC/IFCUtil.cpp",
        };
        pub const Irr = [_][]const u8{
            "code/AssetLib/Irr/IRRLoader.cpp",
            "code/AssetLib/Irr/IRRShared.cpp",
        };
        pub const IrrMesh = [_][]const u8{
            "code/AssetLib/Irr/IRRMeshLoader.cpp",
            "code/AssetLib/Irr/IRRShared.cpp",
        };
        pub const IQM = [_][]const u8{
            "code/AssetLib/IQM/IQMImporter.cpp",
        };
        pub const LWO = [_][]const u8{
            "code/AssetLib/LWO/LWOAnimation.cpp",
            "code/AssetLib/LWO/LWOBLoader.cpp",
            "code/AssetLib/LWO/LWOLoader.cpp",
            "code/AssetLib/LWO/LWOMaterial.cpp",
            "code/AssetLib/LWS/LWSLoader.cpp",
        };
        pub const LWS = [_][]const u8{
            "code/AssetLib/M3D/M3DExporter.cpp",
            "code/AssetLib/M3D/M3DImporter.cpp",
            "code/AssetLib/M3D/M3DWrapper.cpp",
        };
        pub const M3D = [_][]const u8{};
        pub const MD2 = [_][]const u8{
            "code/AssetLib/MD2/MD2Loader.cpp",
        };
        pub const MD3 = [_][]const u8{
            "code/AssetLib/MD3/MD3Loader.cpp",
        };
        pub const MD5 = [_][]const u8{
            "code/AssetLib/MD5/MD5Loader.cpp",
            "code/AssetLib/MD5/MD5Parser.cpp",
        };
        pub const MDC = [_][]const u8{
            "code/AssetLib/MDC/MDCLoader.cpp",
        };
        pub const MDL = [_][]const u8{
            "code/AssetLib/MDL/HalfLife/HL1MDLLoader.cpp",
            "code/AssetLib/MDL/HalfLife/UniqueNameGenerator.cpp",
            "code/AssetLib/MDL/MDLLoader.cpp",
            "code/AssetLib/MDL/MDLMaterialLoader.cpp",
        };
        pub const MMD = [_][]const u8{
            "code/AssetLib/MMD/MMDImporter.cpp",
            "code/AssetLib/MMD/MMDPmxParser.cpp",
        };
        pub const MS3D = [_][]const u8{
            "code/AssetLib/MS3D/MS3DLoader.cpp",
        };
        pub const NDO = [_][]const u8{
            "code/AssetLib/NDO/NDOLoader.cpp",
        };
        pub const NFF = [_][]const u8{
            "code/AssetLib/NFF/NFFLoader.cpp",
        };
        pub const Obj = [_][]const u8{
            "code/AssetLib/Obj/ObjExporter.cpp",
            "code/AssetLib/Obj/ObjFileImporter.cpp",
            "code/AssetLib/Obj/ObjFileMtlImporter.cpp",
            "code/AssetLib/Obj/ObjFileParser.cpp",
        };
        pub const OFF = [_][]const u8{
            "code/AssetLib/OFF/OFFLoader.cpp",
        };
        pub const Ogre = [_][]const u8{
            "code/AssetLib/Ogre/OgreBinarySerializer.cpp",
            "code/AssetLib/Ogre/OgreImporter.cpp",
            "code/AssetLib/Ogre/OgreMaterial.cpp",
            "code/AssetLib/Ogre/OgreStructs.cpp",
            "code/AssetLib/Ogre/OgreXmlSerializer.cpp",
        };
        pub const OpenGEX = [_][]const u8{
            "code/AssetLib/OpenGEX/OpenGEXExporter.cpp",
            "code/AssetLib/OpenGEX/OpenGEXImporter.cpp",
        };
        pub const Ply = [_][]const u8{
            "code/AssetLib/Ply/PlyExporter.cpp",
            "code/AssetLib/Ply/PlyLoader.cpp",
            "code/AssetLib/Ply/PlyParser.cpp",
        };
        pub const Q3BSP = [_][]const u8{
            "code/AssetLib/Q3BSP/Q3BSPFileImporter.cpp",
            "code/AssetLib/Q3BSP/Q3BSPFileParser.cpp",
        };
        pub const Q3D = [_][]const u8{
            "code/AssetLib/Q3D/Q3DLoader.cpp",
        };
        pub const Raw = [_][]const u8{
            "code/AssetLib/Raw/RawLoader.cpp",
        };
        pub const SIB = [_][]const u8{
            "code/AssetLib/SIB/SIBImporter.cpp",
        };
        pub const SMD = [_][]const u8{
            "code/AssetLib/SMD/SMDLoader.cpp",
        };
        pub const Step = [_][]const u8{
            "code/AssetLib/Step/StepExporter.cpp",
        };
        pub const STEPParser = [_][]const u8{
            "code/AssetLib/STEPParser/STEPFileEncoding.cpp",
            "code/AssetLib/STEPParser/STEPFileReader.cpp",
        };
        pub const STL = [_][]const u8{
            "code/AssetLib/STL/STLExporter.cpp",
            "code/AssetLib/STL/STLLoader.cpp",
        };
        pub const Terragen = [_][]const u8{
            "code/AssetLib/Terragen/TerragenLoader.cpp",
        };
        pub const @"3D" = [_][]const u8{
            "code/AssetLib/Unreal/UnrealLoader.cpp",
        };
        pub const X = [_][]const u8{
            "code/AssetLib/X/XFileExporter.cpp",
            "code/AssetLib/X/XFileImporter.cpp",
            "code/AssetLib/X/XFileParser.cpp",
        };
        pub const X3D = [_][]const u8{
            "code/AssetLib/X3D/X3DExporter.cpp",
            "code/AssetLib/X3D/X3DImporter.cpp",
            "code/AssetLib/X3D/X3DImporter.cpp",
            "code/AssetLib/X3D/X3DImporter_Geometry2D.cpp",
            "code/AssetLib/X3D/X3DImporter_Geometry3D.cpp",
            "code/AssetLib/X3D/X3DImporter_Group.cpp",
            "code/AssetLib/X3D/X3DImporter_Light.cpp",
            "code/AssetLib/X3D/X3DImporter_Metadata.cpp",
            "code/AssetLib/X3D/X3DImporter_Networking.cpp",
            "code/AssetLib/X3D/X3DImporter_Postprocess.cpp",
            "code/AssetLib/X3D/X3DImporter_Rendering.cpp",
            "code/AssetLib/X3D/X3DImporter_Shape.cpp",
            "code/AssetLib/X3D/X3DImporter_Texturing.cpp",
            "code/AssetLib/X3D/X3DGeoHelper.cpp",
            "code/AssetLib/X3D/X3DXmlHelper.cpp",
        };
        pub const XGL = [_][]const u8{
            "code/AssetLib/XGL/XGLLoader.cpp",
        };
    };
};

const UpperCaseFormatter = std.fmt.Formatter(struct {
    pub fn format(
        string: []const u8,
        comptime fmt: []const u8,
        options: std.fmt.FormatOptions,
        writer: anytype,
    ) @TypeOf(writer).Error!void {
        _ = fmt;
        _ = options;

        var tmp: [256]u8 = undefined;
        var i: usize = 0;
        while (i < string.len) : (i += tmp.len) {
            try writer.writeAll(std.ascii.upperString(&tmp, string[i..@min(string.len, i + tmp.len)]));
        }
    }
}.format);

fn fmtUpperCase(string: []const u8) UpperCaseFormatter {
    return UpperCaseFormatter{ .data = string };
}
