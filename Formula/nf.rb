class Nf < Formula
  desc "Note Fast - A minimal terminal note-taking tool"
  homepage "https://nf.iamk.xyz"
  url "https://github.com/KOUSTAV2409/nf/archive/refs/tags/v0.3.1.tar.gz"
  sha256 "cb05d2607fd137d4ae7789e8a9c815b17f32d591f8df57d50088423ea6d2303b"
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
