class Aporia < Formula
  desc "Adaptive, high-performance Zsh theme for professionals"
  homepage "https://github.com/fr3on/aporia"
  url "https://github.com/fr3on/aporia/archive/refs/tags/1.1.3.tar.gz"
  sha256 "75458abc498da8b19eade352300ec9e9421636768bbc64f4c6d0622de744eb7d"
  license "MIT"

  def install
    # Install the theme and plugin files to the share directory
    share.install "aporia.zsh-theme"
    share.install "aporia.plugin.zsh"
    
    # Install the first-party plugins directory
    share.install "plugins" if File.directory? "plugins"
    
    # Also install auxiliary scripts
    share.install "uninstall.sh"

    # Create the "aporia-setup" helper script
    (bin/"aporia-setup").write <<~EOS
      #!/bin/zsh
      # Aporia Auto-Setup Helper
      ZSHRC="$HOME/.zshrc"
      THEME_PATH="#{opt_share}/aporia.zsh-theme"
      SOURCE_LINE="source $THEME_PATH"

      if grep -qF "$THEME_PATH" "$ZSHRC" 2>/dev/null; then
        echo "Aporia is already configured in $ZSHRC"
      else
        echo "Adding Aporia to $ZSHRC..."
        echo -e "\\n# Aporia Zsh Theme\\n$SOURCE_LINE" >> "$ZSHRC"
        echo "Successfully activated! Please restart your terminal or run: source ~/.zshrc"
      fi
    EOS
    chmod 0755, bin/"aporia-setup"
    
    # Create a symlink to make it easier to find
    pkgshare.install_symlink share/"aporia.zsh-theme" => "aporia.zsh-theme"
  end

  def caveats
    <<~EOS
      Aporia has been installed! To activate it automatically, run:
        aporia-setup

      Or manually add this to your .zshrc:
        source #{opt_share}/aporia.zsh-theme
    EOS
  end

  test do
    assert_match "aporia", shell_output("zsh -c 'source #{opt_share}/aporia.zsh-theme && echo $ZSH_THEME_NAME'").strip
  end
end
