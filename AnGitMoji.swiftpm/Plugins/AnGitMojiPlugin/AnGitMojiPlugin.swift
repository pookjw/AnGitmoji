import PackagePlugin

@main struct AnGitMojiPlugin: BuildToolPlugin {
    func createBuildCommands(context: PackagePlugin.PluginContext, target: PackagePlugin.Target) async throws -> [PackagePlugin.Command] {
        return [
            .prebuildCommand(
                displayName: "Test Pre-build Command",
                executable: .init("/bin/echo"),
                arguments: ["Hello World"],
                outputFilesDirectory: context.pluginWorkDirectory
            )
        ]
    }
}
