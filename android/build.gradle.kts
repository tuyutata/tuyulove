// 统一途遇旅行Android插件及仓库配置，设置源码外构建目录。

buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath("com.android.tools.build:gradle:9.0.1")
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:2.2.20")
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// 构建输出由TuyuLove产品变量指定；普通开发和CI均可直接使用源码外目录。
val productBuildValue = System.getenv("TUYULOVE_BUILD_DIR")
    ?.takeIf { it.isNotBlank() }
    ?: "${System.getProperty("java.io.tmpdir")}/tuyulove/android"
val productBuildFile = rootProject.file(productBuildValue).canonicalFile
val productSourcePath = rootProject.projectDir.parentFile.canonicalFile.toPath()
require(productBuildFile.isAbsolute && !productBuildFile.toPath().startsWith(productSourcePath)) {
    "TUYULOVE_BUILD_DIR必须是TuyuLove源码外的绝对目录"
}
val newBuildDir: Directory = rootProject.layout.dir(rootProject.provider { productBuildFile }).get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
