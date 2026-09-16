# Homebrew formula template for sessmove.
#
# To serve this via a tap, create a repo named `homebrew-tap` under your
# GitHub account, copy this file there as Formula/sessmove.rb, and replace
# the VERSION/SHA placeholders (see packaging/README note in the main
# README "Install" section). Users then install with:
#
#   brew tap <user>/tap
#   brew install sessmove
#
# CI alternative: replace the url with the GitHub Release tarball of a
# tagged version and fill `sha256` from `shasum -a 256 <tarball>`.
class Sessmove < Formula
  desc "Move a project directory and rewrite every AI coding agent's local session/config references to it"
  homepage "https://github.com/fly88oj/sessmove"
  url "https://github.com/fly88oj/sessmove/archive/refs/tags/v1.0.0.tar.gz"
  sha256 "0000000000000000000000000000000000000000000000000000000000000000"
  license "GPL-3.0-or-later"

  livecheck do
    url :stable
    strategy :github_latest
  end

  depends_on "rust" => :build

  def install
    system "cargo", "install", *std_cargo_args
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/sessmove --version")
    assert_match version.to_s, shell_output("#{bin}/agentpath --version")
  end
end
