class Scaffold < Formula
  desc "Tool for generating code from Stencil templates, similar to rails gen"
  homepage "https://github.com/yhkaplan/scaffold"
  url "https://github.com/yhkaplan/scaffold/archive/0.2.0.tar.gz"
  sha256 "621d32c6cf99f369881b9c028fb1543dd935ac6dcf0b7a17d8f4a9097a7ce4cd"
  head "https://github.com/yhkaplan/scaffold.git"

  depends_on :xcode

  def install
    build_path = "#{buildpath}/.build/release/scaffold"
    ohai "Building Scaffold"
    system("swift build --configuration release --disable-sandbox --disable-package-manifest-caching")
    bin.install build_path
  end
end
