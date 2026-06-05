class Nf < Formula
  desc "Note Fast - A minimal terminal note-taking tool"
  homepage "https://nf.iamk.xyz"
  url "https://github.com/KOUSTAV2409/nf/archive/refs/tags/v0.3.5.tar.gz"
  sha256 "5c57180ab0536f2ee836aa0a0ddb1fd52d53f2e821c6f146a1acd0ff283b9215"
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
