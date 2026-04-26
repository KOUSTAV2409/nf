# Maintainer: Your Name <your.email@example.com>
pkgname=nf
pkgver=0.3.0
pkgrel=1
pkgdesc="Note Fast - A minimal terminal note-taking tool"
arch=('any')
url="https://github.com/KOUSTAV2409/nf"
license=('MIT')
depends=('bash')
optdepends=('fzf: for interactive TUI and menu mode')
source=("https://github.com/KOUSTAV2409/nf/archive/refs/tags/v$pkgver.tar.gz")
sha256sums=('8e9ff3cfb1d99c2a1999599018dece3fd3d48dadca324fc93626fa807e448308')

package() {
  cd "$pkgname-$pkgver"
  install -Dm755 nf.sh "$pkgdir/usr/bin/nf"
  install -Dm644 LICENSE "$pkgdir/usr/share/licenses/$pkgname/LICENSE"
}
