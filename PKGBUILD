# Maintainer: KOUSTAV <koustavganguly24@gmail.com>
pkgname=nf
pkgver=0.3.3
pkgrel=1
pkgdesc="Note Fast - A minimal terminal note-taking tool"
arch=('any')
url="https://github.com/KOUSTAV2409/nf"
license=('MIT')
depends=('bash')
optdepends=('fzf: for interactive TUI and menu mode')
source=("https://github.com/KOUSTAV2409/nf/archive/refs/tags/v$pkgver.tar.gz")
sha256sums=('26086dd06de7bb5e0626deb11d62c9cc75b2fedfb42af07ea61e78ef131cb8f6')

package() {
  cd "$pkgname-$pkgver"
  install -Dm755 nf.sh "$pkgdir/usr/bin/nf"
  install -Dm644 completions/nf.bash "$pkgdir/usr/share/bash-completion/completions/nf"
  install -Dm644 completions/nf.zsh "$pkgdir/usr/share/zsh/site-functions/_nf"
  install -Dm644 LICENSE "$pkgdir/usr/share/licenses/$pkgname/LICENSE"
}
