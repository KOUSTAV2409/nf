class Nf < Formula
  desc "Note Fast - A minimal terminal note-taking tool"
  homepage "https://nf.iamk.xyz"
  url "https://github.com/KOUSTAV2409/nf/archive/refs/tags/v0.3.2.tar.gz"
  sha256 "26086dd06de7bb5e0626deb11d62c9cc75b2fedfb42af07ea61e78ef131cb8f6"
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
