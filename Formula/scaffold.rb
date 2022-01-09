class Scaffold < Formula
  desc "Tool for generating code from Stencil templates, similar to rails gen"
  homepage "https://github.com/yhkaplan/scaffold"
  url "https://github.com/yhkaplan/scaffold/archive/0.3.0.tar.gz"
  sha256 "af221a43c16c5a46e732bd793312652c547ebf11ce6cc70487ed5e8f845eceaf"
  head "https://github.com/yhkaplan/scaffold.git"

  depends_on :xcode

  def install
    build_path = "#{buildpath}/.build/release/scaffold"
    ohai "Building Scaffold"
    system("swift build --configuration release --disable-sandbox")
    bin.install build_path
  end
end
