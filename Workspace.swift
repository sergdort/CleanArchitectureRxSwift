import ProjectDescription
import ProjectDescriptionHelpers

let workspace = Workspace(
    name: "ModernCleanArchtecture",
    projects: ProjectName.allCases.map(\.projectPath)
)
