# Maintainer: KOUSTAV <koustavganguly24@gmail.com>
pkgname=nf
pkgver=0.3.5
pkgrel=1
pkgdesc="Note Fast - A minimal terminal note-taking tool"
arch=('any')
url="https://github.com/KOUSTAV2409/nf"
license=('MIT')
depends=('bash')
optdepends=('fzf: for interactive TUI and menu mode')
source=("https://github.com/KOUSTAV2409/nf/archive/refs/tags/v$pkgver.tar.gz")
sha256sums=('5c57180ab0536f2ee836aa0a0ddb1fd52d53f2e821c6f146a1acd0ff283b9215')

package() {
  cd "$pkgname-$pkgver"
  install -Dm755 nf.sh "$pkgdir/usr/bin/nf"
  install -Dm644 completions/nf.bash "$pkgdir/usr/share/bash-completion/completions/nf"
  install -Dm644 completions/nf.zsh "$pkgdir/usr/share/zsh/site-functions/_nf"
  install -Dm644 LICENSE "$pkgdir/usr/share/licenses/$pkgname/LICENSE"
}
