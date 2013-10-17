class Po4a < Formula
  homepage "http://po4a.alioth.debian.org/"
  url "http://ftp.debian.org/debian/pool/main/p/po4a/po4a_0.45.orig.tar.gz"
  sha1 "c38c32d96c2a25f3a6cc5d8afb1fbdde362b7c19"

  depends_on "gettext" => :build

  resource "Locale::Gettext" do
    url "http://search.cpan.org/CPAN/authors/id/P/PV/PVANDRY/gettext-1.05.tar.gz"
    mirror "http://search.mcpan.org/CPAN/authors/id/P/PV/PVANDRY/gettext-1.05.tar.gz"
    sha1 "705f519ad61b4a8c522d8aaf98425e0bd21709f2"
  end

  #resource "SGMLS" do
  #  url "http://search.cpan.org/CPAN/authors/id/R/RA/RAAB/SGMLSpm-1.1.tar.gz"
  #  mirror "http://search.mcpan.org/CPAN/authors/id/R/RA/RAAB/SGMLSpm-1.1.tar.gz"
  #  sha1 "31d4199d71d5d809f5847bac594c03348c82e2e2"
  #end

  resource "Text::WrapI18N" do
    url "http://search.cpan.org/CPAN/authors/id/K/KU/KUBOTA/Text-WrapI18N-0.06.tar.gz"
    mirror "http://search.mcpan.org/CPAN/authors/id/K/KU/KUBOTA/Text-WrapI18N-0.06.tar.gz"
    sha1 "f397756b8d0a090fdecbf9c854922c0d9825f284"
  end

  resource "Unicode::GCString" do
    url "http://search.cpan.org/CPAN/authors/id/N/NE/NEZUMI/Unicode-LineBreak-2014.06.tar.gz"
    mirror "http://search.mcpan.org/CPAN/authors/id/N/NE/NEZUMI/Unicode-LineBreak-2014.06.tar.gz"
    sha1 "8222276b221f503b9679204e4a9bd53f65f9a3ef"
  end

  def install
    ENV.prepend_create_path "PERL5LIB", libexec+"lib/perl5"
    #ENV.prepend_create_path "PERLLIB", '/usr/local/lib/perl5'  # for SGMLS

    resources.each do |r|
      r.stage do
        system "perl", "Makefile.PL", "INSTALL_BASE=#{libexec}"
        system "make", "install"
      end
    end

    %w[po4a po4a-gettextize po4a-normalize po4a-translate po4a-updatepo].each do |f|
      chmod 0644, f  # FIXME
      inreplace f, "use warnings", "use warnings;\nuse lib '#{lib}/perl5/site_perl';"
    end
    system "perl", "Build.PL", "--prefix", prefix
    system "./Build"
    system "./Build", "install"

    bin.env_script_all_files(libexec+"bin", "PERL5LIB" => ENV["PERL5LIB"])
  end

  test do
    system bin/"po4a", "--version"
    system bin/"po4a-build", "--version"
    system bin/"po4a-gettextize", "--version"
    system bin/"po4a-normalize", "--version"
    system bin/"po4a-translate", "--version"
    system bin/"po4a-updatepo", "--version"
    system bin/"po4aman-display-po", "-h"
    system bin/"po4apod-display-po", "-h"
  end
end
