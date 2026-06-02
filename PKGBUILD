# Maintainer: Your Name <your.email@example.com>
pkgname=nf
pkgver=0.3.2
pkgrel=1
pkgdesc="Note Fast - A minimal terminal note-taking tool"
arch=('any')
url="https://github.com/KOUSTAV2409/nf"
license=('MIT')
depends=('bash')
optdepends=('fzf: for interactive TUI and menu mode')
source=("https://github.com/KOUSTAV2409/nf/archive/refs/tags/v$pkgver.tar.gz")
sha256sums=('0bbd8f467788de8064ec87dadb93781b7bdecc56c6a66be6eb9b5d9a18fea182')

package() {
  cd "$pkgname-$pkgver"
  install -Dm755 nf.sh "$pkgdir/usr/bin/nf"
  install -Dm644 completions/nf.bash "$pkgdir/usr/share/bash-completion/completions/nf"
  install -Dm644 completions/nf.zsh "$pkgdir/usr/share/zsh/site-functions/_nf"
  install -Dm644 LICENSE "$pkgdir/usr/share/licenses/$pkgname/LICENSE"
}
