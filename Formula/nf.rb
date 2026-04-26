class Nf < Formula
  desc "Note Fast - A minimal terminal note-taking tool"
  homepage "https://nf.iamk.xyz"
  url "https://github.com/KOUSTAV2409/nf/archive/refs/tags/v0.3.0.tar.gz"
  sha256 "8e9ff3cfb1d99c2a1999599018dece3fd3d48dadca324fc93626fa807e448308"
  license "MIT"

  def install
    bin.install "nf.sh" => "nf"
  end

  def post_install
    (var/"nf").mkpath
  end

  test do
    system "#{bin}/nf", "test note"
    assert_match "test note", shell_output("#{bin}/nf list")
  end
end
