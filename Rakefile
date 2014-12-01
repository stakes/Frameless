desc "Run clean build with xctool"
task :build do
  run "clean build"
end

desc "Run clean test with xctool"
task :test do
  run "clean test"
end


private

def run(action = "clean build")
  sh("xctool -workspace Frameless.xcworkspace -scheme Frameless -sdk iphonesimulator #{action}")
end
