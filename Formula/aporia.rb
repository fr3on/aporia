class Aporia < Formula
  desc "Adaptive, high-performance Zsh theme for professionals"
  homepage "https://github.com/fr3on/aporia"
  url "https://github.com/fr3on/aporia/archive/refs/tags/1.1.0.tar.gz"
  sha256 "7b72704d3f451fe0ff441bfce78335c31aa14baca48b648d3ba82d5523bf3675"
  license "MIT"

  def install
    # Install the theme and plugin files to the share directory
    share.install "aporia.zsh-theme"
    share.install "aporia.plugin.zsh"
    
    # Also install auxiliary scripts
    share.install "uninstall.sh"
    
    # Create a symlink to make it easier to find
    pkgshare.install_symlink share/"aporia.zsh-theme" => "aporia.zsh-theme"
  end

  def caveats
    <<~EOS
      To activate the Aporia theme, add the following to your .zshrc:
        source #{opt_share}/aporia.zsh-theme

      Alternatively, if you use a plugin manager:
        Zinit:    zinit ice pick"aporia.zsh-theme"; zinit light fr3on/aporia
        Antigen:  antigen theme fr3on/aporia
    EOS
  end

  test do
    assert_match "aporia", shell_output("zsh -c 'source #{opt_share}/aporia.zsh-theme && echo $ZSH_THEME_NAME'").strip
  end
end
