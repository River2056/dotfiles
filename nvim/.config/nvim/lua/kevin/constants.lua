local M = {}

-- M.home = vim.fn.has("macunix") == 1 and "~" or "C:/Users/H0268"
-- get home path from environment variable, set before use!
M.home = os.getenv("KEVIN_NVIM_HOME")

M.config_path = vim.fn.stdpath("config") -- :gsub("\\", "/")
M.java_debug_path = M.config_path .. "/java-debug/"
M.vscode_java_test_path = M.config_path .. "/vscode-java-test/"
M.lombok_path = M.home .. "/lombok.jar"

M.jdtls_jdk11_path = "C:/Program Files/Eclipse Adoptium/jdk-11.0.16.8-hotspot"
M.jdtls_jdk15_path = "C:/openjdk-15.0.2_windows-x64_bin/jdk-15.0.2"
M.jdtls_jdk17_path = "/Users/kevintung/.nix-profile/zulu-17.jdk/Contents/Home"
M.jdtls_jdk8_path = "C:/Program Files/Zulu/zulu-8"
M.jdtls_java_path = M.jdtls_jdk17_path .. "/bin/java"
M.jdtls_debug_port = 8000

return M
