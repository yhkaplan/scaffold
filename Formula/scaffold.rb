class Scaffold < Formula
  desc "Tool for generating code from Stencil templates, similar to rails gen"
  homepage "https://github.com/yhkaplan/scaffold"
  url "https://github.com/yhkaplan/scaffold/archive/0.1.1.tar.gz"
  sha256 "983f25eb9321cbc901394ee1d63fa1ad29b3117f8025df4c5b1c3a91b771938f"
  head "https://github.com/yhkaplan/scaffold.git"

  depends_on :xcode

  def install
    build_path = "#{buildpath}/.build/release/scaffold"
    ohai "Building Scaffold"
    system("swift build --configuration release --disable-sandbox --disable-package-manifest-caching")
    bin.install build_path
  end
end
