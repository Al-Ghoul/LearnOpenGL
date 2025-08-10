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

    // generate compile_commands.json (for clang)
    _ = zcc.createStep(b, "cdb", targets.toOwnedSlice() catch @panic("OOM"));
}
