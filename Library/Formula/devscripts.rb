class Devscripts < Formula
  homepage "http://packages.qa.debian.org/devscripts"
  url "http://ftp.debian.org/debian/pool/main/d/devscripts/devscripts_2.15.4.tar.xz"
  sha1 "8476fd0d5b1819759c91042a5d8460d75edbe9ef"

  depends_on "dpkg"
  depends_on :python3
  depends_on "coreutils" => :build
  depends_on "gettext" => :build
  depends_on "gnu-sed" => :build
  depends_on "po4a" => :build
  depends_on "xz" => :build

  resource "File::BaseDir" do
    url "http://search.cpan.org/CPAN/authors/id/P/PA/PARDUS/File-BaseDir-0.03.tar.gz"
    mirror "http://search.mcpan.org/CPAN/authors/id/P/PA/PARDUS/File-BaseDir-0.03.tar.gz"
    sha1 "901f56c06fd3b4a105bd24b8790ba95337d9aea7"
  end

  resource "File::DesktopEntry" do
    url "http://search.cpan.org/CPAN/authors/id/M/MI/MICHIELB/File-DesktopEntry-0.08.tar.gz"
    mirror "http://search.mcpan.org/CPAN/authors/id/M/MI/MICHIELB/File-DesktopEntry-0.08.tar.gz"
    sha1 "c2bd78e84a009ccc90f03126b96166ebb0e4a6d7"
  end

  resource "Parse::DebControl" do
    url "http://search.cpan.org/CPAN/authors/id/J/JA/JAYBONCI/Parse-DebControl-2.005.tar.gz"
    mirror "http://search.mcpan.org/CPAN/authors/id/J/JA/JAYBONCI/Parse-DebControl-2.005.tar.gz"
    sha1 "d22ae3a5c4511f1799d02987acbe8f6f8113a89e"
  end

  def install
    resources.each do |r|
      r.stage do
        system "perl", "Makefile.PL", "INSTALL_BASE=#{libexec}"
        system "make", "install"
      end
    end

    ENV.deparallelize
    ENV.prepend_create_path "PERL5LIB", libexec+"lib/perl5"
    ENV.prepend_create_path "PERL5LIB", "/usr/local/opt/dpkg/libexec/lib/perl5"
    ENV["PYTHONPATH"] = "#{prefix}/lib/python3.4/site-packages"
    inreplace(["scripts/Makefile", "po4a/Makefile"],
              "/usr/share/sgml/docbook/stylesheet/xsl/nwalsh/",
              "/usr/local/opt/docbook-xsl/docbook-xsl/")
    inreplace "Makefile" do |s|
      s.gsub! "\tinstall", "\tginstall"
    end
    inreplace "scripts/Makefile" do |s|
      s.gsub! "sed -i", "gsed -i"
      s.gsub! "\tinstall", "\tginstall"
      s.gsub! " --install-layout=deb", " --prefix=#{prefix}"
      s.remove_make_var! %w[LIBS]
      s.gsub! "cp $(LIBS)", "###"
    end
    inreplace "Makefile.common" do |s|
      s.change_make_var! "PERLMOD_DIR", share/"devscripts"
      s.change_make_var! "EXAMPLES_DIR", share/"devscripts"
    end
    inreplace "scripts/debuild.pl", "/usr/bin/X11", "/usr/local/bin"
    inreplace "scripts/bts.pl", "/etc/devscripts.conf", "#{etc}/devscripts.conf"

    system "make", "install", "PREFIX=#{prefix}", "SYSCONFDIR=#{prefix}/etc", "DESTDIR=/"

    # from debian/manpages
    man1.install Dir["scripts/*.1"]
    man5.install Dir["scripts/*.5"]

    # from debian/links
    ln_s "cvs-debi", bin/"cvs-debc"
    ln_s "debchange", bin/"dch"
    ln_s "debi", bin/"debc"
    ln_s "pts-subscribe", bin/"pts-unsubscribe"
    ln_s "debchange.1", man1/"dch.1"
    ln_s "pts-subscribe.1", man1/"pts-unsubscribe.1"
  end

  test do
    #system bin/"add-patch", "--version"
    system bin/"annotate-output", "cat", "/dev/null"
    #system bin/"archpath", "--version"
    system bin/"debuild", "--version"
  end
end
