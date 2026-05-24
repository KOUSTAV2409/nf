class Nf < Formula
  desc "Note Fast - A minimal terminal note-taking tool"
  homepage "https://nf.iamk.xyz"
  url "https://github.com/KOUSTAV2409/nf/archive/refs/tags/v0.3.1.tar.gz"
  sha256 "0857a0db55b1483e7b16462ef17f4c17b2bf57df30981bc95670fefe590bcf3d"
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
