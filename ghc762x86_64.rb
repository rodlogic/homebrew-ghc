require 'formula'

  class Ghc762x86_64 < Formula
    homepage "http://haskell.org/ghc/"
    url "http://www.haskell.org/ghc/dist/7.6.2/ghc-7.6.2-x86_64-apple-darwin.tar.bz2"
    sha1 "c5f2c36badf2a1c79259ccb1b1f0dcb8ff801356"
    version '7.6.2-x86_64'

    # http://hackage.haskell.org/trac/ghc/ticket/6009
    depends_on :macos => :snow_leopard
    depends_on "gmp"

    # These don't work inside of a `stable do` block
    if MacOS.version < :mavericks
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
      system "./configure --prefix=#{prefix} --with-gcc=#{ENV.cc}"
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
