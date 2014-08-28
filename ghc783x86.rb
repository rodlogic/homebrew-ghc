require 'formula'

  class Ghc783x86 < Formula
    homepage "http://github.com/rodlogic/homebrew-ghc"
    url "http://www.haskell.org/ghc/dist/7.8.3/ghc-7.8.3-src.tar.xz"
    sha1 "4d7598f8bff3211708da654ec6dd342a2c95dc58"
    version '7.8.3x86'

    option "32-bit"

    # http://hackage.haskell.org/trac/ghc/ticket/6009
    depends_on :macos => :snow_leopard
    depends_on "gmp"
    depends_on "ghc783" => :build

    # These don't work inside of a `stable do` block
    if MacOS.version < :mavericks || build.build_32_bit?
      depends_on "gcc" if MacOS.version >= :mountain_lion
      env :std

      fails_with :clang do
        cause <<-EOS.undent
          Building with Clang configures GHC to use Clang as its preprocessor,
          which causes subsequent GHC-based builds to fail.
        EOS
      end
    end

    def install
      # ensure configure does not use Xcode 5 "gcc" which is actually clang
      system "./configure --prefix=#{prefix} --with-gcc=#{ENV.cc} --target=i386-apple-darwin --with-ld=/usr/bin/ld --with-nm=/usr/bin/nm --with-ar=/usr/bin/ar --with-ranlib=/usr/bin/ranlib"
      if MacOS.version <= :lion
        # __thread is not supported on Lion but configure enables it anyway.
        File.open("mk/config.h", "a") do |file|
          file.write("#undef CC_SUPPORTS_TLS")
        end
      end

      # -j1 fixes an intermittent race condition
      system "make", "-j1", "install"
      ENV.prepend_path "PATH", "#{prefix}/bin"
    end
  end
