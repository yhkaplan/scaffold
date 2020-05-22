class Scaffold < Formula
  desc "Tool for generating code from Stencil templates, similar to rails gen"
  homepage "https://github.com/yhkaplan/scaffold"
  url "https://github.com/yhkaplan/scaffold/archive/0.1.0.tar.gz"
  sha256 "8ed284359f5e93476d37c81f129bd251cd68b33cbd122f27b7d93ef2d61276f9"
  head "https://github.com/yhkaplan/scaffold.git"

  depends_on :xcode

  def install
    build_path = "#{buildpath}/.build/release/scaffold"
    ohai "Building Scaffold"
    system("swift build --configuration release --disable-sandbox --disable-package-manifest-caching")
    bin.install build_path
  end
end
