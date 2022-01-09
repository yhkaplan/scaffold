class Scaffold < Formula
  desc "Tool for generating code from Stencil templates, similar to rails gen"
  homepage "https://github.com/yhkaplan/scaffold"
  url "https://github.com/yhkaplan/scaffold/archive/0.3.0.tar.gz"
  sha256 "b5d67f03aa5bbe4508573d49a8e19163b62d64b40b959bb7d3485a1bc74381a5"
  head "https://github.com/yhkaplan/scaffold.git"

  depends_on :xcode

  def install
    build_path = "#{buildpath}/.build/release/scaffold"
    ohai "Building Scaffold"
    system("swift build --configuration release --disable-sandbox")
    bin.install build_path
  end
end
