# Maintainer: Your Name <your.email@example.com>
pkgname=nf
pkgver=0.1.0
pkgrel=1
pkgdesc="Note Fast - A minimal terminal note-taking tool"
arch=('any')
url="https://github.com/KOUSTAV2409/nf"
license=('MIT')
depends=('bash')
optdepends=('fzf: for interactive TUI and menu mode')
source=("https://github.com/KOUSTAV2409/nf/archive/refs/tags/v$pkgver.tar.gz")
sha256sums=('SKIP')

package() {
  cd "$pkgname-$pkgver"
  install -Dm755 nf.sh "$pkgdir/usr/bin/nf"
  install -Dm644 LICENSE "$pkgdir/usr/share/licenses/$pkgname/LICENSE"
}
