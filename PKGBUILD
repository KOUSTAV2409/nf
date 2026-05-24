# Maintainer: Your Name <your.email@example.com>
pkgname=nf
pkgver=0.3.1
pkgrel=1
pkgdesc="Note Fast - A minimal terminal note-taking tool"
arch=('any')
url="https://github.com/KOUSTAV2409/nf"
license=('MIT')
depends=('bash')
optdepends=('fzf: for interactive TUI and menu mode')
source=("https://github.com/KOUSTAV2409/nf/archive/refs/tags/v$pkgver.tar.gz")
sha256sums=('30cae291b96c9a8832dc6c64699e50faaf265ba18932e4fabc6ff45bb0d3c0fe')

package() {
  cd "$pkgname-$pkgver"
  install -Dm755 nf.sh "$pkgdir/usr/bin/nf"
  install -Dm644 LICENSE "$pkgdir/usr/share/licenses/$pkgname/LICENSE"
}
