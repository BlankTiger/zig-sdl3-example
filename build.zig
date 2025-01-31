const std = @import("std");
const LazyPath = std.Build.LazyPath;

// Although this function looks imperative, note that its job is to
// declaratively construct a build graph that will be executed by an external
// runner.
pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const sdl3_cmake_prepare = b.addSystemCommand(&[_][]const u8{
        "cmake",
        "-S",
        "./SDL",
        "-B",
        "./build",
        // "-DCMAKE_BUILD_TYPE=Release",
    });

    const sdl3_cmake_build = b.addSystemCommand(&[_][]const u8{
        "cmake",
        "--build",
        "./build",
        "--parallel",
        "8",
    });
    sdl3_cmake_build.step.dependOn(&sdl3_cmake_prepare.step);

    const lib = b.addStaticLibrary(.{
        .name = "zrec",
        .root_source_file = b.path("src/root.zig"),
        .target = target,
        .optimize = optimize,
    });
    b.installArtifact(lib);

    const exe = b.addExecutable(.{
        .name = "zrec",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });
    exe.step.dependOn(&sdl3_cmake_build.step);
    exe.addLibraryPath(LazyPath{ .cwd_relative = "build" });
    exe.addIncludePath(LazyPath{ .cwd_relative = "SDL/include" });
    exe.linkSystemLibrary("SDL3");
    exe.linkSystemLibrary("m");
    exe.linkLibC();
    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());

    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    const lib_unit_tests = b.addTest(.{
        .root_source_file = b.path("src/root.zig"),
        .target = target,
        .optimize = optimize,
    });

    const run_lib_unit_tests = b.addRunArtifact(lib_unit_tests);

    const exe_unit_tests = b.addTest(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    const run_exe_unit_tests = b.addRunArtifact(exe_unit_tests);

    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_lib_unit_tests.step);
    test_step.dependOn(&run_exe_unit_tests.step);
}
