class Nf < Formula
  desc "Note Fast - A minimal terminal note-taking tool"
  homepage "https://nf.iamk.xyz"
  url "https://github.com/KOUSTAV2409/nf/archive/refs/tags/v0.3.2.tar.gz"
  sha256 "0bbd8f467788de8064ec87dadb93781b7bdecc56c6a66be6eb9b5d9a18fea182"
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
