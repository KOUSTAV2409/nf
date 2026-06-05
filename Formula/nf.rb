class Nf < Formula
  desc "Note Fast - A minimal terminal note-taking tool"
  homepage "https://nf.iamk.xyz"
  url "https://github.com/KOUSTAV2409/nf/archive/refs/tags/v0.3.3.tar.gz"
  sha256 "8c0100cfce74b2b44d796e54b2d308f8457b498739a7ebc5f20d2440dfd9ef05"
  license "MIT"

  def install
    bin.install "nf.sh" => "nf"
    bash_completion.install "completions/nf.bash" => "nf"
    zsh_completion.install "completions/nf.zsh" => "_nf"
  end

  def post_install
    (var/"nf").mkpath
  end

  test do
    system "#{bin}/nf", "test note"
    assert_match "test note", shell_output("#{bin}/nf list")
  end
end
